############################################################
# model_comparison.R
# Section 9.6.3 — Model comparison via LOO (subject-level)
############################################################

suppressPackageStartupMessages({
  library(rstan)
  library(loo)
})

extract_log_lik_matrix <- function(fit) {
  ll <- rstan::extract(fit, pars = "log_lik")$log_lik
  if (is.null(dim(ll))) stop("Could not extract log_lik (expected draws x N).")
  ll
}

run_model_comparison_loo <- function(fit_dual,
                                    fit_single_alpha = NULL,
                                    fit_no_pers = NULL) {

  loo_dual <- loo::loo(extract_log_lik_matrix(fit_dual))
  loos <- list(dual_alpha = loo_dual)

  if (!is.null(fit_single_alpha)) {
    loos$single_alpha <- loo::loo(extract_log_lik_matrix(fit_single_alpha))
  }
  if (!is.null(fit_no_pers)) {
    loos$no_perseveration <- loo::loo(extract_log_lik_matrix(fit_no_pers))
  }

  if (length(loos) < 2) {
    cat("Only one model provided. LOO computed for dual_alpha only.\n")
    return(invisible(loos))
  }

  comp <- loo::loo_compare(loos)
  print(comp)

  invisible(list(loo = loos, comparison = comp))
}
