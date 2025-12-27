############################################################
# 10_missing_data_MICE.R
# Missing data handling (Section 8.11)
############################################################

# Inspect missingness pattern ---------------------------------------------

missing_pattern <- mice::md.pattern(df)
print(missing_pattern)

# Primary approach: complete case analysis (for main paper) ---------------

df_complete <- df |>
  dplyr::filter(
    !is.na(EV_rel),
    !is.na(baseline_logRMSSD),
    !is.na(delta_logRMSSD),
    !is.na(mean_resp_rate),
    !is.na(resp_variance),
    !is.na(Age),
    !is.na(Sex)
  )

# Sensitivity: multiple imputation if missingness is substantial ----------

# Define variables to include in the imputation model
vars_for_imputation <- c(
  "EV_rel", "baseline_logRMSSD", "delta_logRMSSD",
  "mean_resp_rate", "resp_variance",
  "Age", "Sex", "BMI", "BDI_II", "GAD_7", "PSQI", "IPAQ_MET",
  "Group"
)

imputation_data <- df[, vars_for_imputation]

set.seed(20251124)

imp <- mice(
  imputation_data,
  m      = 50,
  method = "pmm",
  maxit  = 20,
  seed   = 20251124
)

# Example: re-fit H1 in each imputed dataset and pool results --------------

fit_H1_imp <- with(
  imp,
  lm(EV_rel ~ Group + baseline_logRMSSD + mean_resp_rate +
       resp_variance + Age + Sex)
)

H1_pooled <- pool(fit_H1_imp)
summary(H1_pooled)
