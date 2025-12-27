############################################################
# simulate_rl_data.R
# Section 9 — Helpers for simulating reversal learning data
############################################################

suppressPackageStartupMessages({
  library(dplyr)
})

make_optimal_arm_schedule <- function(T = 360, block_size = 60, reversal_within_block = 30) {
  if (T != 360) warning("This helper assumes the protocol's 6×60 structure; adjust if needed.")
  optimal <- integer(T)
  current_opt <- 1L

  for (t in 1:T) {
    optimal[t] <- current_opt
    if (t %in% c(90, 210, 330)) {
      current_opt <- ifelse(current_opt == 1L, 2L, 1L)
    }
  }
  optimal
}

make_EVrel_windows <- function() {
  stable <- c(1:60, 121:180, 241:300)
  pre    <- c(61:88, 181:208, 301:328)
  post   <- c(96:120, 216:240, 336:360)
  sort(unique(c(stable, pre, post)))
}

compute_EV_rel <- function(choice_vec, optimal_arm, idx = make_EVrel_windows()) {
  valid_idx <- idx[choice_vec[idx] %in% c(1L, 2L)]
  if (length(valid_idx) == 0) return(NA_real_)
  mean(choice_vec[valid_idx] == optimal_arm[valid_idx])
}

simulate_one_subject <- function(T = 360,
                                 Tsubj = 360,
                                 alpha_pos, alpha_neg, beta, kappa,
                                 p_high = 0.80, p_low = 0.20,
                                 optimal_arm = make_optimal_arm_schedule(T)) {

  choice  <- rep(-1L, T)
  outcome <- rep(0.0, T)
  Q <- c(0.0, 0.0)
  prev_choice <- -1L

  for (t in 1:Tsubj) {
    pA <- ifelse(optimal_arm[t] == 1L, p_high, p_low)
    pB <- ifelse(optimal_arm[t] == 2L, p_high, p_low)

    Q_diff <- Q[1] - Q[2]
    pers_bonus <- if (prev_choice == -1L) 0.0 else if (prev_choice == 1L) kappa else -kappa
    logit_pA <- beta * Q_diff + pers_bonus
    probA <- 1.0 / (1.0 + exp(-logit_pA))

    a <- sample(c(1L, 2L), size = 1, prob = c(probA, 1 - probA))
    choice[t] <- a

    p_reward <- if (a == 1L) pA else pB
    reward <- rbinom(1, size = 1, prob = p_reward)
    out <- ifelse(reward == 1, 10.0, -10.0)
    outcome[t] <- out

    PE <- out - Q[a]
    if (PE >= 0) Q[a] <- Q[a] + alpha_pos * PE
    else         Q[a] <- Q[a] + alpha_neg * PE

    prev_choice <- a
  }

  list(choice = choice, outcome = outcome)
}
