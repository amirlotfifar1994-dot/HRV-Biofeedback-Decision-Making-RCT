############################################################
# 06_H4_individual_differences.R
# Exploratory analysis H4: ΔlogRMSSD ~ EV_rel (Section 8.7)
############################################################

# Pearson correlation between ΔHRV and EV_rel
cor_H4 <- cor.test(
  ~ delta_logRMSSD + EV_rel,
  data   = df,
  method = "pearson"
)

print(cor_H4)

# Bootstrap CI for correlation --------------------------------------------

boot_fun <- function(data, indices) {
  d <- data[indices, ]
  cor(d$delta_logRMSSD, d$EV_rel, use = "complete.obs")
}

set.seed(20251124)

boot_cor <- boot::boot(
  data      = df,
  statistic = boot_fun,
  R         = 10000
)

boot_ci <- boot::boot.ci(boot_cor, type = "bca")
print(boot_ci)

# Visualization -----------------------------------------------------------

p_H4 <- ggplot(df, aes(x = delta_logRMSSD, y = EV_rel, color = Group)) +
  geom_point(alpha = 0.6, size = 2.8) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    x = "Δ log(RMSSD)",
    y = "Relative Expected Value (EV_rel)",
    title = "Individual differences: HRV change vs. performance"
  )

print(p_H4)

# Optional: interaction model (does correlation differ by group?) ---------

model_H4_interaction <- lm(
  EV_rel ~ delta_logRMSSD * Group +
    baseline_logRMSSD + Age + Sex,
  data = df
)

summary(model_H4_interaction)
