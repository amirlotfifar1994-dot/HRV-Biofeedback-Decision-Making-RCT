############################################################
# 01_descriptives_and_baseline.R
# Descriptive statistics and baseline comparisons (Section 8.2)
############################################################

# Expect df to contain one row per participant
# Key columns (example): ID, Group, Age, Sex, BMI, baseline_logRMSSD,
#                        BDI_II, GAD_7, PSQI, IPAQ_MET

# Quick sanity check
str(df)

# Descriptive statistics by group -----------------------------------------

baseline_summary <- df %>%
  group_by(Group) %>%
  summarise(
    n              = n(),
    Age_mean       = mean(Age, na.rm = TRUE),
    Age_sd         = sd(Age, na.rm = TRUE),
    BMI_mean       = mean(BMI, na.rm = TRUE),
    BMI_sd         = sd(BMI, na.rm = TRUE),
    HRV_mean       = mean(baseline_logRMSSD, na.rm = TRUE),
    HRV_sd         = sd(baseline_logRMSSD, na.rm = TRUE),
    BDI_mean       = mean(BDI_II, na.rm = TRUE),
    BDI_sd         = sd(BDI_II, na.rm = TRUE),
    GAD_mean       = mean(GAD_7, na.rm = TRUE),
    GAD_sd         = sd(GAD_7, na.rm = TRUE),
    PSQI_mean      = mean(PSQI, na.rm = TRUE),
    PSQI_sd        = sd(PSQI, na.rm = TRUE),
    IPAQ_median    = median(IPAQ_MET, na.rm = TRUE),
    IPAQ_IQR       = IQR(IPAQ_MET, na.rm = TRUE)
  )

print(baseline_summary)

# Baseline tests: continuous variables ------------------------------------

# Age
tt_age  <- t.test(Age ~ Group, data = df)
print(tt_age)

# BMI
tt_bmi  <- t.test(BMI ~ Group, data = df)
print(tt_bmi)

# Baseline logRMSSD
tt_hrv  <- t.test(baseline_logRMSSD ~ Group, data = df)
print(tt_hrv)

# Example non-parametric alternative if needed (commented out)
# wilcox.test(IPAQ_MET ~ Group, data = df)

# Baseline tests: categorical variables -----------------------------------

# Sex by Group
sex_table <- table(df$Sex, df$Group)
print(sex_table)

if (all(sex_table >= 5)) {
  chi_sex <- chisq.test(sex_table)
  print(chi_sex)
} else {
  fisher_sex <- fisher.test(sex_table)
  print(fisher_sex)
}
