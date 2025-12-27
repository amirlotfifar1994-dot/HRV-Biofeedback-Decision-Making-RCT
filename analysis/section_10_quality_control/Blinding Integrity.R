############################################################
# blinding_integrity.R
# Section 10.4 — Create analyst-blinded dataset + separate key
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

create_blinded_dataset <- function(df,
                                  id_col = "Participant_ID",
                                  group_col = "Group",
                                  blinded_col = "Group_Blind",
                                  seed = 20251124,
                                  file_blinded = "exports/participant_data_blinded.csv",
                                  file_key = "exports/group_blinding_key.csv") {

  stopifnot(is.data.frame(df))
  stopifnot(all(c(id_col, group_col) %in% names(df)))

  set.seed(seed)

  # Map the *actual* groups to "Group 1" / "Group 2"
  groups <- unique(as.character(df[[group_col]]))
  if (length(groups) != 2) stop("Expected exactly 2 groups in df[[group_col]].")

  mapping <- data.frame(
    True_Group = groups,
    Blind_Code = sample(c("Group 1", "Group 2"), size = 2, replace = FALSE),
    Timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )

  df_blinded <- df
  df_blinded[[blinded_col]] <- mapping$Blind_Code[match(as.character(df[[group_col]]), mapping$True_Group)]
  df_blinded[[group_col]] <- NULL  # remove true group label

  dir.create(dirname(file_blinded), showWarnings = FALSE, recursive = TRUE)
  write.table(df_blinded, file_blinded, sep = ",", row.names = FALSE)

  dir.create(dirname(file_key), showWarnings = FALSE, recursive = TRUE)
  write.table(mapping, file_key, sep = ",", row.names = FALSE)

  invisible(list(blinded = df_blinded, key = mapping))
}

log_unblinding_event <- function(participant_id,
                                 reason,
                                 personnel,
                                 file = "logs/unblinding_log.csv") {
  row <- data.frame(
    Participant_ID = participant_id,
    Reason = reason,
    Personnel = personnel,
    Timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )
  append_csv(row, file)
}
