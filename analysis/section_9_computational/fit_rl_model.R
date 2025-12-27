############################################################
# fit_rl_model.R
# Section 9 — RL model fitting helpers (Stan / rstan)
############################################################

suppressPackageStartupMessages({
  library(dplyr)
  library(rstan)
})

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

build_stan_data_from_trials <- function(df_trial_level, T = NULL) {
  required <- c("Participant_ID", "Trial_Num", "Choice", "Outcome", "Group")
  miss <- setdiff(required, names(df_trial_level))
  if (length(miss) > 0) stop("df_trial_level missing columns: ", paste(miss, collapse = ", "))

  df <- df_trial_level %>%
    mutate(
      Participant_ID = as.character(Participant_ID),
      Trial_Num      = as.integer(Trial_Num)
    ) %>%
    arrange(Participant_ID, Trial_Num)

  ids <- unique(df$Participant_ID)
  N <- length(ids)
  if (is.null(T)) T <- max(df$Trial_Num, na.rm = TRUE)

  choice_mat  <- matrix(-1L, nrow = N, ncol = T)
  outcome_mat <- matrix(0.0, nrow = N, ncol = T)
  Tsubj       <- integer(N)
  group_vec   <- integer(N)

  map_group <- function(g) {
    if (is.numeric(g)) {
      if (!all(g %in% c(1, 2))) stop("Group numeric must be 1 or 2.")
      return(as.integer(g))
    }
    gs <- tolower(as.character(g))
    if (grepl("bio", gs)) return(1L)
    if (grepl("control", gs)) return(2L)
    stop("Group must be numeric 1/2 or contain 'bio' / 'control'. Got: ", g)
  }

  map_choice <- function(x) {
    if (is.na(x)) return(NA_integer_)
    if (is.numeric(x)) {
      xi <- as.integer(x)
      if (xi %in% c(1L, 2L)) return(xi)
      if (xi %in% c(0L, 1L)) return(xi + 1L)
      stop("Choice numeric must be 0/1 or 1/2. Got: ", x)
    }
    xs <- toupper(trimws(as.character(x)))
    if (xs %in% c("A", "LEFT"))  return(1L)
    if (xs %in% c("B", "RIGHT")) return(2L)
    stop("Choice must be 0/1, 1/2, or 'A'/'B'. Got: ", x)
  }

  for (i in seq_along(ids)) {
    pid <- ids[i]
    tmp <- df %>% filter(Participant_ID == pid) %>% arrange(Trial_Num)

    group_vec[i] <- map_group(tmp$Group[1])

    tmp <- tmp %>% filter(!is.na(Trial_Num), Trial_Num >= 1, Trial_Num <= T)
    Tsubj[i] <- nrow(tmp)

    for (j in seq_len(nrow(tmp))) {
      t <- tmp$Trial_Num[j]
      choice_mat[i, t]  <- ifelse(is.na(tmp$Choice[j]), -1L, map_choice(tmp$Choice[j]))
      outcome_mat[i, t] <- as.numeric(tmp$Outcome[j])
    }
  }

  list(
    N      = N,
    T      = T,
    Tsubj  = Tsubj,
    choice = array(choice_mat, dim = c(N, T)),
    outcome = array(outcome_mat, dim = c(N, T)),
    group  = group_vec,
    ids    = ids
  )
}

fit_dual_alpha_model <- function(stan_data,
                                 stan_file = "dual_alpha_rl.stan",
                                 chains = 4, iter = 4000, warmup = 2000,
                                 seed = 20251124,
                                 adapt_delta = 0.95, max_treedepth = 12) {

  if (!file.exists(stan_file)) stop("Stan file not found: ", stan_file)

  rstan::stan(
    file    = stan_file,
    data    = stan_data,
    chains  = chains,
    iter    = iter,
    warmup  = warmup,
    seed    = seed,
    control = list(adapt_delta = adapt_delta, max_treedepth = max_treedepth)
  )
}
