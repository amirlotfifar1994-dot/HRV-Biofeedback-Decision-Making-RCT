############################################################
# protocol_adherence_monitoring.R
# Section 10.2 — Intervention fidelity + protocol deviations
############################################################

# Helper: safe CSV append (write header only once)
append_csv <- function(df_row, file) {
  dir.create(dirname(file), showWarnings = FALSE, recursive = TRUE)
  write.table(
    df_row,
    file = file,
    sep = ",",
    row.names = FALSE,
    col.names = !file.exists(file),
    append = file.exists(file)
  )
}

# Summarize adherence for ONE participant/session
# df_intervention: time-series during intervention
# Expected columns (Biofeedback):
#   timestamp (POSIXct or numeric), breathing_rate_bpm, coherence (0-100, optional)
# Expected columns (Control):
#   timestamp, breathing_rate_bpm
summarize_adherence <- function(df_intervention,
                               participant_id,
                               group,
                               target_rf_bpm = NA_real_,
                               control_target_bpm = 15,
                               rf_tolerance_bpm = 0.5,
                               control_tolerance_bpm = 1.0,
                               green_threshold = 70,
                               green_target_pct = 50,
                               major_green_min_pct = 30,
                               major_rf_deviation_bpm = 2.0,
                               major_control_deviation_bpm = 2.0) {

  stopifnot(is.data.frame(df_intervention))
  stopifnot(all(c("breathing_rate_bpm") %in% names(df_intervention)))

  grp <- tolower(as.character(group))

  # Session duration (minutes)
  if ("timestamp" %in% names(df_intervention)) {
    ts <- df_intervention$timestamp
    # Allow numeric timestamps too
    dur_min <- as.numeric(difftime(max(ts, na.rm = TRUE), min(ts, na.rm = TRUE), units = "mins"))
    if (is.na(dur_min) || is.infinite(dur_min)) dur_min <- NA_real_
  } else {
    dur_min <- NA_real_
  }

  mean_br <- mean(df_intervention$breathing_rate_bpm, na.rm = TRUE)
  sd_br   <- sd(df_intervention$breathing_rate_bpm, na.rm = TRUE)

  # Initialize outputs
  pct_in_target <- NA_real_
  pct_green     <- NA_real_
  deviation_class <- "None"
  deviation_reason <- ""

  if (grp %in% c("biofeedback", "hrv-bf", "bf")) {

    if (is.na(target_rf_bpm)) stop("For Biofeedback group, target_rf_bpm must be provided.")

    # % time within RF ± tolerance
    in_target <- df_intervention$breathing_rate_bpm >= (target_rf_bpm - rf_tolerance_bpm) &
                 df_intervention$breathing_rate_bpm <= (target_rf_bpm + rf_tolerance_bpm)
    pct_in_target <- mean(in_target, na.rm = TRUE) * 100

    # % time in green zone (if coherence exists)
    if ("coherence" %in% names(df_intervention)) {
      pct_green <- mean(df_intervention$coherence >= green_threshold, na.rm = TRUE) * 100
    }

    # Classify deviations (aligned to your protocol logic)
    # Major examples in your text:
    # - <30% green time OR mean breathing deviates > ±2 bpm from RF
    major <- FALSE
    minor <- FALSE
    reasons <- c()

    if (!is.na(pct_green) && pct_green < major_green_min_pct) {
      major <- TRUE
      reasons <- c(reasons, sprintf("GreenZone<%s%%", major_green_min_pct))
    } else if (!is.na(pct_green) && pct_green < green_target_pct) {
      minor <- TRUE
      reasons <- c(reasons, sprintf("GreenZone<%s%%", green_target_pct))
    }

    if (abs(mean_br - target_rf_bpm) > major_rf_deviation_bpm) {
      major <- TRUE
      reasons <- c(reasons, sprintf("MeanBreathRate>|%s| bpm from RF", major_rf_deviation_bpm))
    }

    if (major) deviation_class <- "Major"
    else if (minor) deviation_class <- "Minor"
    deviation_reason <- paste(reasons, collapse = "; ")

  } else if (grp %in% c("control", "active control", "paced")) {

    in_target <- df_intervention$breathing_rate_bpm >= (control_target_bpm - control_tolerance_bpm) &
                 df_intervention$breathing_rate_bpm <= (control_target_bpm + control_tolerance_bpm)
    pct_in_target <- mean(in_target, na.rm = TRUE) * 100

    major <- FALSE
    minor <- FALSE
    reasons <- c()

    if (abs(mean_br - control_target_bpm) > major_control_deviation_bpm) {
      major <- TRUE
      reasons <- c(reasons, sprintf("MeanBreathRate>|%s| bpm from control target", major_control_deviation_bpm))
    } else if (abs(mean_br - control_target_bpm) > control_tolerance_bpm) {
      minor <- TRUE
      reasons <- c(reasons, sprintf("MeanBreathRate outside ±%s bpm target band", control_tolerance_bpm))
    }

    if (major) deviation_class <- "Major"
    else if (minor) deviation_class <- "Minor"
    deviation_reason <- paste(reasons, collapse = "; ")

  } else {
    stop("Unknown group label. Use 'Biofeedback' or 'Control'.")
  }

  out <- data.frame(
    Participant_ID = participant_id,
    Group = group,
    Target_RF_BPM = target_rf_bpm,
    Mean_BreathingRate = mean_br,
    SD_BreathingRate = sd_br,
    Pct_In_Target_Band = pct_in_target,
    Pct_GreenZone = pct_green,
    Session_Duration_Min = dur_min,
    Deviation_Class = deviation_class,
    Deviation_Reason = deviation_reason,
    Timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )

  out
}

# Log adherence row
log_adherence <- function(adherence_row,
                          file = "logs/protocol_adherence_log.csv") {
  append_csv(adherence_row, file)
}
