############################################################
# parameter_recovery_simulation.R
# Section 9.6.2 — Parameter recovery (hierarchical simulation + refit)
############################################################

suppressPackageStartupMessages({
  library(rstan)
  library(dplyr)
  library(ggplot2)
})

source("simulate_rl_data.R")

qnorm_safe <- function(p) qnorm(pmin(pmax(p, 1e-6), 1 - 1e-6))

run_parameter_recovery <- function(stan_file = "dual_alpha_rl.stan",
                                   N = 50,
                                   T = 360,
                                   p_high = 0.80,
                                   p_low  = 0.20,
                                   seed = 20251124,
                                   chains = 4,
                                   iter = 2000,
                                   warmup = 1000,
                                   adapt_delta = 0.95,
                                   max_treedepth = 12) {

  set.seed(seed)

  optimal_arm <- make_optimal_arm_schedule(T = T)

  mu_pr_true <- array(0, dim = c(2, 4))
  sigma_true <- c(0.4, 0.4, 0.3, 0.6)

  alpha_pos_mean_BF <- 0.35
  alpha_neg_mean_BF <- 0.35
  beta_mean_BF      <- 3.5
  kappa_mean_BF     <- 0.3

  alpha_pos_mean_C  <- 0.30
  alpha_neg_mean_C  <- 0.45
  beta_mean_C       <- 3.0
  kappa_mean_C      <- 0.6

  mu_pr_true[1, 1] <- qnorm_safe(alpha_pos_mean_BF)
  mu_pr_true[1, 2] <- qnorm_safe(alpha_neg_mean_BF)
  mu_pr_true[1, 3] <- log(beta_mean_BF)
  mu_pr_true[1, 4] <- kappa_mean_BF

  mu_pr_true[2, 1] <- qnorm_safe(alpha_pos_mean_C)
  mu_pr_true[2, 2] <- qnorm_safe(alpha_neg_mean_C)
  mu_pr_true[2, 3] <- log(beta_mean_C)
  mu_pr_true[2, 4] <- kappa_mean_C

  group_vec <- rep(c(1L, 2L), length.out = N)

  z <- matrix(rnorm(N * 4), nrow = N, ncol = 4)

  alpha_pos_true <- numeric(N)
  alpha_neg_true <- numeric(N)
  beta_true      <- numeric(N)
  kappa_true     <- numeric(N)

  for (i in 1:N) {
    g <- group_vec[i]
    alpha_pos_true[i] <- pnorm(mu_pr_true[g, 1] + sigma_true[1] * z[i, 1])
    alpha_neg_true[i] <- pnorm(mu_pr_true[g, 2] + sigma_true[2] * z[i, 2])
    beta_true[i]      <- exp(mu_pr_true[g, 3] + sigma_true[3] * z[i, 3])
    kappa_true[i]     <-      mu_pr_true[g, 4] + sigma_true[4] * z[i, 4]
  }

  choice_arr  <- array(-1L, dim = c(N, T))
  outcome_arr <- array(0.0, dim = c(N, T))
  Tsubj <- rep(T, N)

  for (i in 1:N) {
    sim <- simulate_one_subject(
      T = T,
      Tsubj = T,
      alpha_pos = alpha_pos_true[i],
      alpha_neg = alpha_neg_true[i],
      beta      = beta_true[i],
      kappa     = kappa_true[i],
      p_high = p_high,
      p_low  = p_low,
      optimal_arm = optimal_arm
    )
    choice_arr[i, ]  <- sim$choice
    outcome_arr[i, ] <- sim$outcome
  }

  stan_data <- list(
    N = N,
    T = T,
    Tsubj = Tsubj,
    choice = choice_arr,
    outcome = outcome_arr,
    group = group_vec
  )

  fit <- rstan::stan(
    file    = stan_file,
    data    = stan_data,
    chains  = chains,
    iter    = iter,
    warmup  = warmup,
    seed    = seed,
    control = list(adapt_delta = adapt_delta, max_treedepth = max_treedepth)
  )

  post <- rstan::extract(fit, pars = c("alpha_pos", "alpha_neg", "beta", "kappa"))

  alpha_pos_hat <- colMeans(post$alpha_pos)
  alpha_neg_hat <- colMeans(post$alpha_neg)
  beta_hat      <- colMeans(post$beta)
  kappa_hat     <- colMeans(post$kappa)

  rec <- tibble(
    Participant = 1:N,
    Group = factor(group_vec, levels = c(1, 2), labels = c("Biofeedback", "Control")),
    alpha_pos_true = alpha_pos_true, alpha_pos_hat = alpha_pos_hat,
    alpha_neg_true = alpha_neg_true, alpha_neg_hat = alpha_neg_hat,
    beta_true      = beta_true,      beta_hat      = beta_hat,
    kappa_true     = kappa_true,     kappa_hat     = kappa_hat
  )

  cor_alpha_pos <- cor(rec$alpha_pos_true, rec$alpha_pos_hat)
  cor_alpha_neg <- cor(rec$alpha_neg_true, rec$alpha_neg_hat)
  cor_beta      <- cor(rec$beta_true,      rec$beta_hat)
  cor_kappa     <- cor(rec$kappa_true,     rec$kappa_hat)

  cat("\n--- Parameter recovery (correlations across participants) ---\n")
  cat("alpha_pos:", cor_alpha_pos, "\n")
  cat("alpha_neg:", cor_alpha_neg, "\n")
  cat("beta     :", cor_beta, "\n")
  cat("kappa    :", cor_kappa, "\n")

  p_alpha_pos <- ggplot(rec, aes(x = alpha_pos_true, y = alpha_pos_hat, color = Group)) +
    geom_point(alpha = 0.7) +
    geom_smooth(method = "lm", se = FALSE) +
    labs(title = "Parameter recovery: alpha_pos", x = "True", y = "Recovered (posterior mean)") +
    theme_minimal()

  p_beta <- ggplot(rec, aes(x = beta_true, y = beta_hat, color = Group)) +
    geom_point(alpha = 0.7) +
    geom_smooth(method = "lm", se = FALSE) +
    labs(title = "Parameter recovery: beta", x = "True", y = "Recovered (posterior mean)") +
    theme_minimal()

  print(p_alpha_pos)
  print(p_beta)

  invisible(list(
    fit = fit,
    rec = rec,
    cor = c(alpha_pos = cor_alpha_pos, alpha_neg = cor_alpha_neg, beta = cor_beta, kappa = cor_kappa),
    stan_data = stan_data
  ))
}
