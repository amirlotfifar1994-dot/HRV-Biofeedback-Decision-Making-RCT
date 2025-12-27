# Heart Rate Variability Biofeedback and Adaptive Decision-Making: A Pre-Registered RCT

[![OSF Preregistration](https://img.shields.io/badge/OSF-Preregistered-blue)](https://doi.org/10.17605/OSF.IO/YCE74)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stan](https://img.shields.io/badge/Stan-2.26+-red.svg)](https://mc-stan.org/)
[![R](https://img.shields.io/badge/R-4.3+-blue.svg)](https://www.r-project.org/)

##  Study Overview

This repository contains the **complete pre-registered protocol and analysis code** for a randomized controlled trial (RCT) investigating the causal effects of heart rate variability (HRV) biofeedback training on adaptive decision-making in a probabilistic reversal learning task.

**Pre-registration:** https://doi.org/10.17605/OSF.IO/YCE74  
**OSF Project:** https://osf.io/cjs86/

### Key Features
- ✅ **Pre-registered protocol** (OSF: [link])
- ✅ **Hierarchical Bayesian reinforcement learning modeling** (Stan)
- ✅ **Dual-alpha Q-learning with perseveration**
- ✅ **Trial-level cardiac-behavioral coupling analysis**
- ✅ **Comprehensive quality control procedures**
- ✅ **Fully reproducible analysis pipeline**

---

##  Research Questions

**Primary Hypothesis (H1):** Does acute resonance-frequency HRV biofeedback causally improve adaptive decision-making performance (EV_rel) compared to an active control condition?

**Mechanistic Hypotheses (H3):**
- **H3a:** HRV-BF increases inverse temperature (β) → reduced decision noise
- **H3b:** HRV-BF reduces learning rate asymmetry |α⁺ − α⁻| → balanced learning
- **H3c:** HRV-BF reduces perseveration (κ) → increased cognitive flexibility

**Exploratory Hypothesis (H5):** Trial-level cardiac deceleration following negative feedback predicts adaptive switching behavior, with stronger coupling in the HRV-BF group.

---

##  Repository Structure

```
HRV-Biofeedback-Decision-Making-RCT/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── requirements.txt                   # R package dependencies
│
├── protocol/
│   ├── OSF_Protocol_Full.pdf         # Complete pre-registered protocol
│   └── Protocol_Summary.md           # Brief protocol summary
│
├── analysis/
│   ├── section_8_behavioral/         # Behavioral analyses (H1, H2, H4, H5)
│   │   ├── 00_setup_and_packages.R
│   │   ├── 01_descriptives_and_baseline.R
│   │   ├── 02_manipulation_check_deltaHRV.R
│   │   ├── 03_H1_performance_EVrel.R
│   │   ├── 04_H2_mediation_deltaHRV.R
│   │   ├── 05_H3_RL_parameters.R
│   │   ├── 06_H4_individual_differences.R
│   │   ├── 07_H5_trial_level_coupling.R
│   │   ├── 08_H1_bayesian_sensitivity.R
│   │   ├── 09_sensitivity_analyses.R
│   │   ├── 10_missing_data_MICE.R
│   │   └── hrv_biofeedback_section8_master.R
│   │
│   ├── section_9_computational/      # RL modeling (H3)
│   │   ├── dual_alpha_rl.stan        # Hierarchical Bayesian RL model
│   │   ├── fit_rl_model.R
│   │   ├── convergence_diagnostics.R
│   │   ├── bayesian_analysis.R
│   │   ├── hypothesis_testing.R
│   │   ├── model_comparison.R
│   │   ├── parameter_recovery_simulation.R
│   │   ├── simulate_rl_data.R
│   │   └── rl_computational_modeling_master.R
│   │
│   └── section_10_quality_control/   # QC procedures
│       ├── behavioral_data_quality_checks.R
│       ├── protocol_adherence_monitoring.R
│       ├── safety_monitoring.R
│       ├── blinding_integrity.R
│       └── pre_registration_compliance.R
│
├── simulations/                       # Parameter recovery & validation
│   ├── parameter_recovery_simulation.R
│   └── simulate_rl_data.R
│
└── logs/                              # Quality control logs (generated during study)
    ├── adverse_events_log.csv
    ├── behavioral_qc_log.csv
    ├── protocol_adherence_log.csv
    ├── protocol_deviations_log.csv
    └── unblinding_log.csv
```

---

##  Getting Started

### Prerequisites

**R version:** 4.3.1 or higher  
**Stan version:** 2.26 or higher

### Installation

1. Clone this repository:
```bash
git clone https://github.com/amirlotfifar1994-dot/HRV-Biofeedback-Decision-Making-RCT.git
cd HRV-Biofeedback-Decision-Making-RCT
```

2. Install required R packages:
```r
# Core packages
install.packages(c(
  "rstan", "brms", "lme4", "mediation", 
  "BayesFactor", "ggplot2", "dplyr", "tidyr",
  "effsize", "TOSTER", "mice", "boot",
  "HDInterval", "loo", "posterior", "bayesplot",
  "ggeffects"
))

# Stan configuration
rstan::rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
```

3. Verify Stan installation:
```r
library(rstan)
example(stan_model, run.dontrun = TRUE)
```

---

##  Reproducing Analyses

### Option 1: Run Complete Pipeline

```r
# Set working directory to repository root
setwd("path/to/HRV-Biofeedback-Decision-Making-RCT")

# Load your data (structure detailed in protocol)
# df <- readRDS("data/participant_data.rds")
# df_trial_level <- readRDS("data/trial_level_data.rds")

# Run all Section 8 analyses (behavioral + mediation)
source("analysis/section_8_behavioral/hrv_biofeedback_section8_master.R")

# Run all Section 9 analyses (RL modeling)
source("analysis/section_9_computational/rl_computational_modeling_master.R")
```

### Option 2: Run Individual Analyses

```r
# Example: H1 (primary performance analysis)
source("analysis/section_8_behavioral/00_setup_and_packages.R")
source("analysis/section_8_behavioral/03_H1_performance_EVrel.R")

# Example: H3 (RL parameter analysis)
source("analysis/section_9_computational/fit_rl_model.R")
source("analysis/section_9_computational/hypothesis_testing.R")
```

### Parameter Recovery Simulation

```r
# Validate model before fitting to real data
source("analysis/section_9_computational/parameter_recovery_simulation.R")

results <- run_parameter_recovery(
  stan_file = "analysis/section_9_computational/dual_alpha_rl.stan",
  N = 50,
  T = 360,
  chains = 4,
  iter = 2000
)
```

---

##  Computational Model

### Dual-Alpha Q-Learning with Perseveration

**Value Learning:**
```
Q_chosen(t+1) = Q_chosen(t) + α × PE(t)

where:
  α = α⁺  if PE ≥ 0 (reward)
  α = α⁻  if PE < 0 (loss)
  PE = outcome - Q_chosen
```

**Action Selection (Softmax):**
```
P(choose A) = 1 / (1 + exp(−β × (Q_A − Q_B) − κ × I_prev_choice))

where:
  β = inverse temperature (exploitation vs. exploration)
  κ = perseveration weight (tendency to repeat previous choice)
```

**Hierarchical Structure:**
- Group-level hyperparameters: `μ_pr[group, param]`, `σ[param]`
- Individual-level parameters: `α_i⁺, α_i⁻, β_i, κ_i`
- Non-centered parameterization for MCMC efficiency

---

## Expected Outputs

### Behavioral Analyses
- Primary outcome: `EV_rel` (relative expected value)
- Mediation analysis: `ΔlogRMSSD` → `EV_rel`
- Trial-level coupling: `ΔIBI × Group` predicting adaptive switching

### Computational Analyses
- Posterior distributions for group-level RL parameters
- Parameter recovery correlations (target: r > 0.90)
- Posterior predictive checks (observed vs. simulated behavior)
- Model comparison (LOO-CV) across alternative specifications

### Quality Control
- Physiological artifact rates (ECG, respiration)
- Protocol adherence metrics (intervention fidelity)
- Adverse events log
- Missing data patterns

---

##  Citation

If you use this protocol or code, please cite:

```bibtex
@misc{lotfifar2024hrv,
  title={Heart Rate Variability Biofeedback and Adaptive Decision-Making: 
         A Randomized Controlled Trial with Hierarchical Bayesian Modeling},
  author={Lotfifar, Amirmohammad and Mohammadi, Melika Dabbagh},
  year={2024},
  publisher={OSF Preprints},
  doi={10.17605/OSF.IO/xxxxx},
  url={https://osf.io/xxxxx}
}
```

**Analysis Code:**
```bibtex
@software{lotfifar2024hrv_code,
  author={Lotfifar, Amirmohammad and Mohammadi, Melika Dabbagh},
  title={HRV Biofeedback RCT: Analysis Code},
  year={2024},
  publisher={GitHub},
  url={https://github.com/amirlotfifar1994-dot/HRV-Biofeedback-Decision-Making-RCT}
}
```

---

##  Study Status

- [x] Protocol finalized and pre-registered (OSF)
- [x] Analysis code implemented and validated
- [ ] Ethics approval obtained
- [ ] Data collection in progress
- [ ] Manuscript in preparation

**Study Location:** University laboratory in Italy (to be finalized upon Master's/PhD program acceptance in 2026)

---

##  Authors & Contributors

**Principal Investigator:**  
Amirmohammad Lotfifar  
Email: amirlotfifar1994@gmail.com  
ORCID: [0009-0006-7577-6892](https://orcid.org/0009-0006-7577-6892)  
GitHub: [@amirlotfifar1994-dot](https://github.com/amirlotfifar1994-dot)

**Co-Principal Investigator:**  
Melika Dabbagh Mohammadi  
Email: melikamohamadi2000@gmail.com

**Conflict of Interest Disclosure:**  
The Principal Investigator and Co-Principal Investigator are married. This relationship has been fully disclosed to the Ethics Committee and will be declared in all publications.

---

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Protocol & Analysis Code:** MIT License (open source)  
**Data:** Will be made publicly available upon manuscript acceptance (de-identified, OSF repository)

---

##  Acknowledgments

- **Theoretical Framework:** Neurovisceral Integration Model (Thayer & Lane, 2000)
- **Computational Modeling:** Reinforcement learning framework (Daw, 2011; Gershman, 2016)
- **Software:** Stan Development Team, R Core Team, PsychoPy developers

---

##  Contact

For questions about the study protocol or analysis code:
- 📧 Email: amirlotfifar1994@gmail.com
- 💬 GitHub Issues: [Open an issue](https://github.com/amirlotfifar1994-dot/HRV-Biofeedback-Decision-Making-RCT/issues)
- 🔗 OSF Project: [https://osf.io/cjs86/](https://osf.io/cjs86/)

---

##  Updates

- **2024-12-27:** Repository created, protocol pre-registered, analysis code released
- **TBD:** Ethics approval obtained
- **TBD:** Data collection initiated
- **TBD:** Results published

---

**Last updated:** December 27, 2024
