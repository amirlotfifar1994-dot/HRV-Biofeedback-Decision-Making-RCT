############################################################
# behavioral_data_quality_checks.R
# Section 10.1.2 — Behavioral QC (timeouts, RT, choice entropy)
############################################################

entropy_bits_binary <- function(choices, levels = c("A", "B")) {
  x <- choices[!is.na(choices)]
  if (length(x) == 0) return(NA_real_)

  p <- sapply(levels, function(lv) mean(x == lv))
  # Safe entropy in bits: treat 0*log2(0) as 0
  h <- 0
  for (pi in p) {
    if (!is.na(pi) && pi > 0) h <- h - (pi * log2(pi))
  }
  h
}

behavioral_qc <- function(df_trials,
                          participant_id = NA,
                          timeout_ms = 2500,
                          min_rt_ms = 200,
                          redflag_timeout_pct = 20,
                          redflag_mean_rt_ms = 400,
                          redflag_entropy_bits = 0.5,
                          trial_rt_col = "RT",
                          choice_col = "Choice") {

  stopifnot(is.data.frame(df_trials))
  stopifnot(all(c(trial_rt_col, choice_col) %in% names(df_trials)))

  rt <- df_trials[[trial_rt_col]]
  ch <- df_trials[[choice_col]]

  # Timeouts: RT > timeout_ms OR NA
  is_timeout <- is.na(rt) | rt > timeout_ms
  timeout_rate_pct <- mean(is_timeout) * 100

  # Valid RTs: between min_rt_ms and timeout_ms
  valid_rt <- rt[!is_timeout & !is.na(rt) & rt >= min_rt_ms]
  mean_rt <- if (length(valid_rt) > 0) mean(valid_rt) else NA_real_

  # Entropy: assumes choices coded as "A"/"B" (or map beforehand)
  ent_bits <- entropy_bits_binary(ch, levels = c("A", "B"))

  flags <- c()
  if (!is.na(timeout_rate_pct) && timeout_rate_pct > redflag_timeout_pct) {
    flags <- c(flags, sprintf("TimeoutRate>%.1f%%", redflag_timeout_pct))
  }
  if (!is.na(mean_rt) && mean_rt < redflag_mean_rt_ms) {
    flags <- c(flags, sprintf("MeanRT<%dms", redflag_mean_rt_ms))
  }
  if (!is.na(ent_bits) && ent_bits < redflag_entropy_bits) {
    flags <- c(flags, sprintf("Entropy<%.2fbits", redflag_entropy_bits))
  }

  out <- data.frame(
    Participant_ID = participant_id,
    N_Trials = nrow(df_trials),
    TimeoutRate_Pct = timeout_rate_pct,
    MeanRT_Valid = mean_rt,
    ChoiceEntropy_Bits = ent_bits,
    Flags = paste(flags, collapse = "; "),
    Timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )

  out
}

# Optional: append to a QC log
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

log_behavioral_qc <- function(qc_row, file = "logs/behavioral_qc_log.csv") {
  append_csv(qc_row, file)
}
