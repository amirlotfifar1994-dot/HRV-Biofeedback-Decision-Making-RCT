############################################################
# 08_H1_bayesian_sensitivity.R
# Bayesian sensitivity analysis for H1 (Section 8.9)
############################################################

# Weakly informative priors for H1 model
priors_H1 <- c(
  prior(normal(0,   0.5), class = "b"),          # Regression coefficients
  prior(exponential(1),  class = "sigma"),       # Residual SD
  prior(normal(0.75, 0.2), class = "Intercept")  # Intercept (based on pilot)
)

# Full model with Group effect
model_H1_bayes <- brm(
  EV_rel ~ Group + baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Sex,
  data   = df,
  prior  = priors_H1,
  family = gaussian(),
  chains = 4,
  iter   = 4000,
  warmup = 2000,
  cores  = 4,
  seed   = 20251124,
  backend = "cmdstanr"
)

summary(model_H1_bayes)
plot(model_H1_bayes)                 # Trace plots
pp_check(model_H1_bayes, ndraws = 100)  # Posterior predictive checks

# Posterior for Group effect ----------------------------------------------

post_draws <- posterior::as_draws_df(model_H1_bayes)

# Assuming factor coding: GroupBiofeedback vs Control (reference)
post_group <- post_draws |>
  dplyr::select(b_GroupBiofeedback)

p_positive <- mean(post_group$b_GroupBiofeedback > 0)
cat("P(Group effect > 0 | data) =", p_positive, "\n")

# 95% credible interval
posterior_summary(model_H1_bayes, variable = "b_GroupBiofeedback")

# Null model without Group -------------------------------------------------

model_H1_null <- brm(
  EV_rel ~ baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Sex,
  data   = df,
  prior  = priors_H1,
  family = gaussian(),
  chains = 4,
  iter   = 4000,
  cores  = 4,
  seed   = 20251124,
  backend = "cmdstanr"
)

# Bayes factor via bridge sampling
BF_H1 <- bayes_factor(model_H1_bayes, model_H1_null,
                      log = FALSE, repetitions = 10)

print(BF_H1)

# LOO-CV comparison (optional)
loo_H1      <- loo(model_H1_bayes)
loo_H1_null <- loo(model_H1_null)

print(loo_H1)
print(loo_H1_null)
