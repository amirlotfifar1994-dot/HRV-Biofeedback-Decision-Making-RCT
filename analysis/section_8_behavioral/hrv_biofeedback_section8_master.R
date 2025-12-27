############################################################
# hrv_biofeedback_section8_master.R
# Master script to reproduce all Section 8 analyses
############################################################

# 1. Setup and packages
source("00_setup_and_packages.R")

# 2. Descriptives and baseline comparisons (Section 8.2)
source("01_descriptives_and_baseline.R")

# 3. Manipulation check: ΔlogRMSSD (Section 8.3)
source("02_manipulation_check_deltaHRV.R")

# 4. Primary analysis H1 (Section 8.4)
source("03_H1_performance_EVrel.R")

# 5. Primary analysis H2 (Section 8.5)
source("04_H2_mediation_deltaHRV.R")

# 6. Primary analysis H3 – RL parameters (Section 8.6)
#    Requires that RL model has been fit and `posterior` + `df_parameters`
#    have been created beforehand (from the Stan code in Section 9).
source("05_H3_RL_parameters.R")

# 7. Exploratory analysis H4 (Section 8.7)
source("06_H4_individual_differences.R")

# 8. Exploratory analysis H5 (Section 8.8)
source("07_H5_trial_level_coupling.R")

# 9. Bayesian sensitivity analysis for H1 (Section 8.9)
source("08_H1_bayesian_sensitivity.R")

# 10. Planned sensitivity analyses (Section 8.10)
source("09_sensitivity_analyses.R")

# 11. Missing data handling (Section 8.11)
source("10_missing_data_MICE.R")

cat("\nAll Section 8 analyses completed.\n")
