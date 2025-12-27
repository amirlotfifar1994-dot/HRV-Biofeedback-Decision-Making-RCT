############################################################
# 05_H3_RL_parameters.R
# Primary analysis H3: group differences in RL parameters (Section 8.6)
############################################################

# Assumed objects:
#  - df_parameters: one row per participant with columns:
#       Group, alpha_pos, alpha_neg, beta, kappa
#  - posterior: a list or draws with group-level parameters, e.g.:
#       alpha_pos_BF_mean, alpha_neg_BF_mean,
#       alpha_pos_Control_mean, alpha_neg_Control_mean,
#       beta_BF_mean, beta_Control_mean,
#       kappa_BF_mean, kappa_Control_mean
#    as in the generated quantities of the Stan model.

# Example: compute posterior differences from Stan-generated quantities ----

# If you extracted with rstan::extract(fit):
# posterior <- rstan::extract(fit)

alpha_pos_BF      <- posterior$alpha_pos_BF_mean
alpha_pos_Control <- posterior$alpha_pos_Control_mean
alpha_neg_BF      <- posterior$alpha_neg_BF_mean
alpha_neg_Control <- posterior$alpha_neg_Control_mean
beta_BF           <- posterior$beta_BF_mean
beta_Control      <- posterior$beta_Control_mean
kappa_BF          <- posterior$kappa_BF_mean
kappa_Control     <- posterior$kappa_Control_mean

# H3a: β_Biofeedback > β_Control
diff_beta  <- beta_BF - beta_Control
p_H3a      <- mean(diff_beta > 0)
hdi_H3a    <- HDInterval::hdi(diff_beta, credMass = 0.95)

cat("H3a: P(β_BF > β_Control) =", p_H3a, "\n")
print(hdi_H3a)

# H3b: |α+ − α−|_BF < |α+ − α−|_Control
alpha_asymm_BF      <- abs(alpha_pos_BF - alpha_neg_BF)
alpha_asymm_Control <- abs(alpha_pos_Control - alpha_neg_Control)
diff_asymm          <- alpha_asymm_BF - alpha_asymm_Control
p_H3b               <- mean(diff_asymm < 0)
hdi_H3b             <- HDInterval::hdi(diff_asymm, credMass = 0.95)

cat("H3b: P(|α+−α−|_BF < |α+−α−|_Control) =", p_H3b, "\n")
print(hdi_H3b)

# H3c: κ_BF < κ_Control
diff_kappa <- kappa_BF - kappa_Control
p_H3c      <- mean(diff_kappa < 0)
hdi_H3c    <- HDInterval::hdi(diff_kappa, credMass = 0.95)

cat("H3c: P(κ_BF < κ_Control) =", p_H3c, "\n")
print(hdi_H3c)

# Optional: Bayes Factors using subject-level parameters -------------------

# Example: use BayesFactor on participant-level beta estimates
# (This is an approximation; main inference is from hierarchical model.)

library(BayesFactor)

beta_BF_subjects     <- df_parameters$beta[df_parameters$Group == "Biofeedback"]
beta_Control_subjects <- df_parameters$beta[df_parameters$Group == "Control"]

BF_beta <- ttestBF(
  x = beta_BF_subjects,
  y = beta_Control_subjects,
  nullInterval = NULL
)

print(BF_beta)

# Effect sizes for parameters (Cohen's d) ----------------------------------

beta_d <- cohen.d(beta ~ Group, data = df_parameters)
print(beta_d)

# You can similarly compute d for alpha_asymmetry and kappa if desired.
