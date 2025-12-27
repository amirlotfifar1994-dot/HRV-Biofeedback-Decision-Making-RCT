############################################################
# safety_monitoring.R
# Section 10.3 — Adverse events logging + stopping rules helpers
############################################################

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

log_adverse_event <- function(participant_id,
                              phase,
                              event_type,
                              severity = c("Mild", "Moderate", "Severe"),
                              relatedness = c("Unrelated", "Possibly", "Probably"),
                              details = "",
                              file = "logs/adverse_events_log.csv") {

  severity <- match.arg(severity)
  relatedness <- match.arg(relatedness)

  row <- data.frame(
    Participant_ID = participant_id,
    Phase = phase,
    Event_Type = event_type,
    Severity = severity,
    Relatedness = relatedness,
    Details = details,
    Timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )

  append_csv(row, file)
  invisible(row)
}

# Study-level stopping rule helper:
# If > threshold_pct of participants have related/possibly-related AEs → pause for review
evaluate_stopping_rule <- function(n_total_participants,
                                  n_related_events_participants,
                                  threshold_pct = 0.10) {

  if (n_total_participants <= 0) stop("n_total_participants must be > 0")

  rate <- n_related_events_participants / n_total_participants
  list(
    n_total = n_total_participants,
    n_related = n_related_events_participants,
    rate = rate,
    threshold = threshold_pct,
    stop_recommended = (rate > threshold_pct)
  )
}
