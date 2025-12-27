############################################################
# 04_H2_mediation_deltaHRV.R
# Primary analysis H2: mediation by ΔlogRMSSD (Section 8.5)
############################################################

# Path a: Group -> delta_logRMSSD
model_a <- lm(
  delta_logRMSSD ~ Group + baseline_logRMSSD +
    mean_resp_rate + resp_variance + Age + Sex,
  data = df
)

# Path b + c': EV_rel ~ Group + delta_logRMSSD + covariates
model_b <- lm(
  EV_rel ~ Group + delta_logRMSSD + baseline_logRMSSD +
    mean_resp_rate + resp_variance + Age + Sex,
  data = df
)

summary(model_a)
summary(model_b)

# Mediation analysis with bootstrapping
set.seed(20251124)

mediation_results <- mediate(
  model.m = model_a,
  model.y = model_b,
  treat   = "Group",
  mediator = "delta_logRMSSD",
  boot    = TRUE,
  sims    = 5000,
  boot.ci.type = "bca"
)

summary(mediation_results)

# Save key outputs
ACME_H2  <- mediation_results$d0
ACME_CI  <- mediation_results$d0.ci
ADE_H2   <- mediation_results$z0
Total_H2 <- mediation_results$tau.coef

cat("\nH2 - ACME (indirect effect) =", ACME_H2,
    "95% CI =", ACME_CI[1], "to", ACME_CI[2], "\n")

# Optional sensitivity models with alternative mediators can be added
# e.g., Δresp_rate, ΔPANAS_positive, etc.
