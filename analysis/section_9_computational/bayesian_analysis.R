############################################################
# bayesian_analysis.R
# Section 9.6.1 — Posterior predictive checks (PPC)
############################################################

suppressPackageStartupMessages({
  library(dplyr)
  library(rstan)
  library(ggplot2)
})

posterior_predictive_checks <- function(fit,
                                       df_trial_level,
                                       draws = 200,
                                       p_high_default = 0.80,
                                       p_low_default = 0.20) {

  source("simulate_rl_data.R")
  source("fit_rl_model.R")

  stan_data <- build_stan_data_from_trials(df_trial_level)
  N <- stan_data$N
  T <- stan_data$T

  optimal_arm <- make_optimal_arm_schedule(T = T)
  idx_ev <- make_EVrel_windows()

  EV_obs <- numeric(N)
  for (i in seq_len(N)) {
    EV_obs[i] <- compute_EV_rel(stan_data$choice[i, ], optimal_arm, idx_ev)
  }

  post <- rstan::extract(fit, pars = c("alpha_pos", "alpha_neg", "beta", "kappa"))
  S <- dim(post$beta)[1]
  if (draws > S) draws <- S
  draw_idx <- sample.int(S, size = draws, replace = FALSE)

  EV_sim <- matrix(NA_real_, nrow = draws, ncol = N)

  for (s in seq_along(draw_idx)) {
    k <- draw_idx[s]
    for (i in 1:N) {
      sim <- simulate_one_subject(
        T = T,
        Tsubj = stan_data$Tsubj[i],
        alpha_pos = post$alpha_pos[k, i],
        alpha_neg = post$alpha_neg[k, i],
        beta      = post$beta[k, i],
        kappa     = post$kappa[k, i],
        p_high = p_high_default,
        p_low  = p_low_default,
        optimal_arm = optimal_arm
      )
      EV_sim[s, i] <- compute_EV_rel(sim$choice, optimal_arm, idx_ev)
    }
  }

  EV_sim_mean <- colMeans(EV_sim, na.rm = TRUE)

  df_plot <- tibble(
    EV_rel = c(EV_obs, EV_sim_mean),
    Type   = rep(c("Observed", "Simulated (posterior mean)"), each = N)
  )

  p1 <- ggplot(df_plot, aes(x = EV_rel, fill = Type)) +
    geom_density(alpha = 0.35) +
    labs(
      x = "EV_rel",
      y = "Density",
      title = "Posterior Predictive Check: EV_rel (observed vs simulated)"
    ) +
    theme_minimal()

  print(p1)

  invisible(list(EV_obs = EV_obs, EV_sim = EV_sim, plot = p1, stan_data = stan_data))
}
