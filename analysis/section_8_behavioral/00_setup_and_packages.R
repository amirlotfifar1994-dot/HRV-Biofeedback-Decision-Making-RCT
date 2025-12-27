############################################################
# 00_setup_and_packages.R
# Global options and required packages for all analyses
############################################################

# Set a global seed for reproducibility
set.seed(20251124)

# Core statistical and data handling packages
library(effsize)       # Effect sizes (e.g., Cohen's d)
library(lme4)          # (G)LMMs
library(mediation)     # Causal mediation analysis
library(TOSTER)        # Equivalence tests (TOST)
library(brms)          # Bayesian regression models (Stan backend)
library(BayesFactor)   # Bayes factors for simple designs
library(ggplot2)       # Visualization
library(dplyr)         # Data manipulation
library(tidyr)         # Data reshaping
library(mice)          # Multiple imputation for missing data
library(boot)          # Bootstrap procedures
library(ggeffects)     # Marginal effects / predicted probabilities
library(HDInterval)    # Highest density intervals (HDI)
library(loo)           # LOO-CV and WAIC
library(posterior)     # Working with posterior draws

# Optional but helpful
# library(DescTools)   # Extra descriptive stats (if needed)

# A simple ggplot theme for consistency
theme_set(theme_minimal())
