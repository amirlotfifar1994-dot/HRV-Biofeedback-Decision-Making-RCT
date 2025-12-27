############################################################
# 07_H5_trial_level_coupling.R
# Exploratory analysis H5: trial-level cardiac–behavioral coupling (Section 8.8)
#
# Model:
#   Switch_After_Loss ~ DeltaIBI_z * Group + EV_diff + Trial_Num + RT_prev
#   with participant-level random effects.
#
# Expected columns in df_trial_level:
#   Participant_ID, Group, Switch_After_Loss (0/1), DeltaIBI_z, EV_diff, Trial_Num, RT_prev
############################################################

suppressPackageStartupMessages({
  library(dplyr)
  library(lme4)
  library(ggeffects)
  library(ggplot2)
})

# -----------------------------
# 1) Basic checks + cleaning
# -----------------------------
required_cols <- c(
  "Participant_ID", "Group", "Switch_After_Loss",
  "DeltaIBI_z", "EV_diff", "Trial_Num", "RT_prev"
)

missing_cols <- setdiff(required_cols, names(df_trial_level))
if (length(missing_cols) > 0) {
  stop("df_trial_level is missing required columns: ",
       paste(missing_cols, collapse = ", "))
}

df_h5 <- df_trial_level %>%
  mutate(
    Group = factor(Group),
    Participant_ID = factor(Participant_ID)
  ) %>%
  # keep only complete cases for model variables
  filter(
    !is.na(Switch_After_Loss),
    !is.na(DeltaIBI_z),
    !is.na(Group),
    !is.na(Participant_ID),
    !is.na(EV_diff),
    !is.na(Trial_Num),
    !is.na(RT_prev)
  ) %>%
  # ensure outcome is 0/1 numeric
  mutate(
    Switch_After_Loss = as.integer(Switch_After_Loss)
  )

# Set Control as reference level if present
if ("Control" %in% levels(df_h5$Group)) {
  df_h5 <- df_h5 %>% mutate(Group = relevel(Group, ref = "Control"))
}

# Optional: standardize continuous covariates for better convergence
df_h5 <- df_h5 %>%
  mutate(
    EV_diff_z   = as.numeric(scale(EV_diff)),
    Trial_Num_z = as.numeric(scale(Trial_Num)),
    RT_prev_z   = as.numeric(scale(RT_prev))
  )

# -----------------------------
# 2) Fit primary GLMM
# -----------------------------
# Random intercept + random slope for DeltaIBI_z (can be simplified if convergence issues)
model_H5 <- glmer(
  Switch_After_Loss ~ DeltaIBI_z * Group +
    EV_diff_z + Trial_Num_z + RT_prev_z +
    (1 + DeltaIBI_z | Participant_ID),
  data    = df_h5,
  family  = binomial(link = "logit"),
  control = glmerControl(
    optimizer = "bobyqa",
    optCtrl   = list(maxfun = 2e5)
  )
)

cat("\n--- H5 GLMM summary ---\n")
print(summary(model_H5))

# If convergence warnings occur, fit a simpler random-effects structure as sensitivity:
if (!is.null(model_H5@optinfo$conv$lme4$messages)) {
  cat("\nConvergence warning detected. Fitting simpler model (random intercept only) as sensitivity...\n")
  model_H5_simple <- glmer(
    Switch_After_Loss ~ DeltaIBI_z * Group +
      EV_diff_z + Trial_Num_z + RT_prev_z +
      (1 | Participant_ID),
    data    = df_h5,
    family  = binomial(link = "logit"),
    control = glmerControl(
      optimizer = "bobyqa",
      optCtrl   = list(maxfun = 2e5)
    )
  )
  cat("\n--- H5 (simple RE) summary ---\n")
  print(summary(model_H5_simple))
}

# -----------------------------
# 3) Predicted probabilities for plotting
# -----------------------------
# Predicted P(switch) across DeltaIBI_z by Group
pred_H5 <- ggpredict(
  model_H5,
  terms = c("DeltaIBI_z [-2:2]", "Group")
)

p_H5 <- ggplot(pred_H5, aes(x = x, y = predicted, color = group, fill = group)) +
  geom_line(linewidth = 1.1) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.18, colour = NA) +
  labs(
    x = "Cardiac deceleration (ΔIBI, z-scored)",
    y = "P(Switch after loss)",
    title = "H5: Trial-level cardiac–behavioral coupling (ΔIBI × Group)"
  )

print(p_H5)

# Optional: save plot
# ggsave("H5_predicted_switch_probabilities.png", p_H5, width = 7, height = 5, dpi = 300)
