############################################################
# convergence_diagnostics.R
# Section 9 — MCMC convergence + sampling diagnostics
############################################################

suppressPackageStartupMessages({
  library(rstan)
  library(bayesplot)
  library(posterior)
})

run_convergence_diagnostics <- function(fit,
                                       pars_trace = c("mu_pr[1,1]", "mu_pr[1,2]", "mu_pr[1,3]", "mu_pr[1,4]"),
                                       pars_pairs = c("mu_pr[1,1]", "mu_pr[1,2]", "mu_pr[1,3]", "mu_pr[1,4]")) {

  draws <- posterior::as_draws_df(fit)
  summ <- posterior::summarise_draws(draws)

  max_rhat <- max(summ$rhat, na.rm = TRUE)
  min_ess  <- min(summ$ess_bulk, na.rm = TRUE)

  cat("\n--- Convergence diagnostics ---\n")
  cat("Max R-hat:", max_rhat, "\n")
  cat("Min ESS (bulk):", min_ess, "\n")

  sp <- rstan::get_sampler_params(fit, inc_warmup = FALSE)
  n_div <- sum(vapply(sp, function(x) sum(x[, "divergent__"]), numeric(1)))
  cat("Total divergent transitions:", n_div, "\n")

  print(bayesplot::mcmc_trace(fit, pars = pars_trace))
  print(bayesplot::mcmc_pairs(fit, pars = pars_pairs))

  invisible(list(summary = summ, max_rhat = max_rhat, min_ess = min_ess, n_div = n_div))
}
