############################################################
# 09_sensitivity_analyses.R
# Planned sensitivity analyses (Section 8.10)
############################################################

# 8.10.1 Alternative HRV metrics ------------------------------------------
# Re-run H1 and H2 using logSDNN and logHF instead of logRMSSD.

# H1 with logSDNN
model_H1_logSDNN <- lm(
  EV_rel ~ Group + logSDNN + mean_resp_rate +
    resp_variance + Age + Sex,
  data = df
)

summary(model_H1_logSDNN)

# H1 with logHF
model_H1_logHF <- lm(
  EV_rel ~ Group + logHF + mean_resp_rate +
    resp_variance + Age + Sex,
  data = df
)

summary(model_H1_logHF)

# 8.10.2 Inclusion/exclusion of subclinical psychopathology ---------------

df_no_subclinical <- df |>
  dplyr::filter(BDI_II < 14, GAD_7 < 10)

# Re-run H1 on subset
model_H1_no_subclinical <- lm(
  EV_rel ~ Group + baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Sex,
  data = df_no_subclinical
)

summary(model_H1_no_subclinical)

# 8.10.3 Menstrual cycle phase (for female participants) ------------------

df_female <- df |>
  dplyr::filter(Sex == "Female")

# Example: Cycle_Phase is a factor (e.g., Follicular, Luteal, etc.)
model_H1_cycle <- lm(
  EV_rel ~ Group + baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Cycle_Phase,
  data = df_female
)

summary(model_H1_cycle)

# 8.10.4 Trial exclusion window sensitivity for EV_rel --------------------
# Assume you can recompute EV_rel under different exclusion rules
# and store them as EV_rel_conservative, EV_rel_liberal, EV_rel_full.

# Conservative exclusion
model_H1_conservative <- lm(
  EV_rel_conservative ~ Group + baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Sex,
  data = df
)

# Liberal exclusion
model_H1_liberal <- lm(
  EV_rel_liberal ~ Group + baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Sex,
  data = df
)

# No exclusion
model_H1_full <- lm(
  EV_rel_full ~ Group + baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Sex,
  data = df
)

summary(model_H1_conservative)
summary(model_H1_liberal)
summary(model_H1_full)

# 8.10.5 Respiration-corrected HRV ----------------------------------------
# Outline:
#  1. Fit model RR_interval ~ respiration_phase (and/or rate)
#  2. Take residuals as "respiration-corrected" RR
#  3. Recompute RMSSD from residuals
#  4. Use log(corrected_RMSSD) in H1/H2

# This depends heavily on raw beat-to-beat data structure; here is only a sketch.

# Example (pseudo-code, not directly runnable without beat-level data):
# corrected_model <- lm(RR_interval ~ Resp_Phase, data = df_beats)
# df_beats$resid_RR <- resid(corrected_model)
# -> aggregate residual RMSSD per participant and phase, then merge into df
# -> use that new variable (e.g., logRMSSD_corrected) in place of baseline_logRMSSD

# 8.10.6 ITT vs Per-Protocol ----------------------------------------------

# ITT: all randomized participants already in df
model_H1_ITT <- lm(
  EV_rel ~ Group + baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Sex,
  data = df
)

summary(model_H1_ITT)

# Per-protocol: e.g., only participants with good adherence
# Example adherence criterion: Coherence_time >= 0.70 (dummy variable name)
df_per_protocol <- df |>
  dplyr::filter(Adherence_flag == 1)

model_H1_PP <- lm(
  EV_rel ~ Group + baseline_logRMSSD + mean_resp_rate +
    resp_variance + Age + Sex,
  data = df_per_protocol
)

summary(model_H1_PP)
