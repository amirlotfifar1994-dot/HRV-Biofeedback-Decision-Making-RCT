############################################################
# pre_registration_compliance.R
# Section 10.5 — Protocol deviations log (prereg compliance)
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

log_protocol_deviation <- function(participant_id = NA,
                                   deviation_type = c("Minor", "Major"),
                                   phase = "",
                                   description = "",
                                   rationale = "",
                                   potential_impact = "",
                                   decided_by = "",
                                   file = "logs/protocol_deviations_log.csv") {

  deviation_type <- match.arg(deviation_type)

  row <- data.frame(
    Participant_ID = participant_id,
    Deviation_Type = deviation_type,
    Phase = phase,
    Description = description,
    Rationale = rationale,
    Potential_Impact = potential_impact,
    Decided_By = decided_by,
    Timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )

  append_csv(row, file)
  invisible(row)
}
