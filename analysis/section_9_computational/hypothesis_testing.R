############################################################
# hypothesis_testing.R
# Section 9.7 — Hypothesis testing on RL parameters (H3a–H3c)
############################################################

suppressPackageStartupMessages({
  library(rstan)
  library(HDInterval)
})

test_H3_parameters <- function(fit) {
  post <- rstan::extract(fit)

  beta_BF      <- post$beta_BF_mean
  beta_Control <- post$beta_Control_mean

  alpha_pos_BF      <- post$alpha_pos_BF_mean
  alpha_neg_BF      <- post$alpha_neg_BF_mean
  alpha_pos_Control <- post$alpha_pos_Control_mean
  alpha_neg_Control <- post$alpha_neg_Control_mean

  kappa_BF      <- post$kappa_BF_mean
  kappa_Control <- post$kappa_Control_mean

  diff_beta <- beta_BF - beta_Control
  p_H3a <- mean(diff_beta > 0)
  hdi_H3a <- HDInterval::hdi(diff_beta, credMass = 0.95)

  asym_BF <- abs(alpha_pos_BF - alpha_neg_BF)
  asym_C  <- abs(alpha_pos_Control - alpha_neg_Control)
  diff_asym <- asym_BF - asym_C
  p_H3b <- mean(diff_asym < 0)
  hdi_H3b <- HDInterval::hdi(diff_asym, credMass = 0.95)

  diff_kappa <- kappa_BF - kappa_Control
  p_H3c <- mean(diff_kappa < 0)
  hdi_H3c <- HDInterval::hdi(diff_kappa, credMass = 0.95)

  cat("\n--- H3 posterior contrasts ---\n")
  cat("H3a (beta): P(BF > Control) =", p_H3a, " | 95% HDI =", hdi_H3a, "\n")
  cat("H3b (|α+−α−|): P(BF < Control) =", p_H3b, " | 95% HDI =", hdi_H3b, "\n")
  cat("H3c (kappa): P(BF < Control) =", p_H3c, " | 95% HDI =", hdi_H3c, "\n")

  invisible(list(
    H3a = list(p = p_H3a, hdi = hdi_H3a, diff = diff_beta),
    H3b = list(p = p_H3b, hdi = hdi_H3b, diff = diff_asym),
    H3c = list(p = p_H3c, hdi = hdi_H3c, diff = diff_kappa)
  ))
}
