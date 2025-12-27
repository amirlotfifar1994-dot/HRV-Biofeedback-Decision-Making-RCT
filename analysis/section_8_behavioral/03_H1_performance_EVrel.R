############################################################
# 03_H1_performance_EVrel.R
# Primary analysis H1: group effect on EV_rel (Section 8.4)
############################################################

# Model: EV_rel ~ Group + baseline_logRMSSD + mean_resp_rate +
#                  resp_variance + Age + Sex

model_H1 <- lm(
  EV_rel ~ Group + baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Sex,
  data = df
)

summary_H1 <- summary(model_H1)
print(summary_H1)

# Extract p-value for Group effect (Biofeedback vs. Control)
p_H1 <- coef(summary_H1)["GroupBiofeedback", "Pr(>|t|)"]
cat("H1: p-value for Group effect on EV_rel =", p_H1, "\n")

# Effect size: Cohen's d for EV_rel by group
H1_d <- cohen.d(EV_rel ~ Group, data = df, pooled = TRUE, paired = FALSE)
print(H1_d)

# Optional: equivalence test for H1 if p_H1 is non-significant ------------

if (p_H1 >= 0.05) {
  cat("\nH1 non-significant, running TOST equivalence test on EV_rel...\n")

  n_Biofeedback <- sum(df$Group == "Biofeedback")
  n_Control    <- sum(df$Group == "Control")

  TOST_H1 <- TOSTtwo(
    m1 = mean(df$EV_rel[df$Group == "Biofeedback"], na.rm = TRUE),
    m2 = mean(df$EV_rel[df$Group == "Control"], na.rm = TRUE),
    sd1 = sd(df$EV_rel[df$Group == "Biofeedback"], na.rm = TRUE),
    sd2 = sd(df$EV_rel[df$Group == "Control"], na.rm = TRUE),
    n1 = n_Biofeedback,
    n2 = n_Control,
    low_eqbound_d  = -0.30,
    high_eqbound_d =  0.30,
    alpha = 0.05
  )

  print(TOST_H1)
}
