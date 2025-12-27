############################################################
# rl_computational_modeling_master.R
# Section 9 — End-to-end RL modeling pipeline
############################################################

suppressPackageStartupMessages({
  library(dplyr)
})

source("fit_rl_model.R")
source("convergence_diagnostics.R")
source("bayesian_analysis.R")
source("hypothesis_testing.R")
# Optional:
# source("parameter_recovery_simulation.R")
# source("model_comparison.R")

stan_data <- build_stan_data_from_trials(df_trial_level, T = 360)

fit <- fit_dual_alpha_model(
  stan_data = stan_data,
  stan_file = "dual_alpha_rl.stan",
  chains = 4, iter = 4000, warmup = 2000,
  seed = 20251124,
  adapt_delta = 0.95, max_treedepth = 12
)

saveRDS(fit, file = "dual_alpha_fit.rds")

diag <- run_convergence_diagnostics(fit)

ppc <- posterior_predictive_checks(
  fit = fit,
  df_trial_level = df_trial_level,
  draws = 200,
  p_high_default = 0.80,
  p_low_default = 0.20
)

h3 <- test_H3_parameters(fit)

cat("\nSection 9 pipeline completed.\n")
