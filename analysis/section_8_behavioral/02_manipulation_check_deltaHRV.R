############################################################
# 02_manipulation_check_deltaHRV.R
# Manipulation check: ΔlogRMSSD by group (Section 8.3)
############################################################

# ΔHRV = post - baseline (already computed as delta_logRMSSD in df)

# Welch's t-test for difference between groups
tt_delta <- t.test(delta_logRMSSD ~ Group, data = df, var.equal = FALSE)
print(tt_delta)

# Effect size (Cohen's d)
delta_d <- cohen.d(delta_logRMSSD ~ Group, data = df)
print(delta_d)

# Optional: equivalence test if manipulation appears "null" ---------------
# Smallest effect size of interest (SESOI) for manipulation, e.g. d = 0.30
# Adjust the SESOI if you want a different threshold.

n_Biofeedback <- sum(df$Group == "Biofeedback")
n_Control    <- sum(df$Group == "Control")

if (tt_delta$p.value >= 0.05) {
  cat("\nΔHRV manipulation non-significant, running TOST equivalence test...\n")

  library(TOSTER)

  TOST_delta <- TOSTtwo(
    m1 = mean(df$delta_logRMSSD[df$Group == "Biofeedback"], na.rm = TRUE),
    m2 = mean(df$delta_logRMSSD[df$Group == "Control"], na.rm = TRUE),
    sd1 = sd(df$delta_logRMSSD[df$Group == "Biofeedback"], na.rm = TRUE),
    sd2 = sd(df$delta_logRMSSD[df$Group == "Control"], na.rm = TRUE),
    n1 = n_Biofeedback,
    n2 = n_Control,
    low_eqbound_d  = -0.30,
    high_eqbound_d =  0.30,
    alpha = 0.05
  )

  print(TOST_delta)
}
