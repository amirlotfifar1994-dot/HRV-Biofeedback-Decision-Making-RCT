data {
  int<lower=1> N;                           // Number of subjects
  int<lower=1> T;                           // Maximum number of trials
  int<lower=1,upper=T> Tsubj[N];            // Number of valid trials per subject
  array[N, T] int<lower=-1,upper=2> choice; // 1=Arm A, 2=Arm B, -1=missing
  array[N, T] real outcome;                 // +10 or -10 (observed)
  array[N] int<lower=1,upper=2> group;      // 1=Biofeedback, 2=Control
}

parameters {
  // Group-level hyperparameters: (α⁺, α⁻, log(β), κ)
  vector[4] mu_pr[2];
  vector<lower=0>[4] sigma;

  // Subject-level non-centered raw parameters
  matrix[N, 4] z;
}

transformed parameters {
  vector<lower=0,upper=1>[N] alpha_pos;
  vector<lower=0,upper=1>[N] alpha_neg;
  vector<lower=0>[N] beta;
  vector[N] kappa;

  for (i in 1:N) {
    alpha_pos[i] = Phi_approx(mu_pr[group[i], 1] + sigma[1] * z[i, 1]);
    alpha_neg[i] = Phi_approx(mu_pr[group[i], 2] + sigma[2] * z[i, 2]);
    beta[i]      = exp(mu_pr[group[i], 3] + sigma[3] * z[i, 3]); // β > 0
    kappa[i]     =      mu_pr[group[i], 4] + sigma[4] * z[i, 4];
  }
}

model {
  // Priors: weakly informative
  for (g in 1:2) {
    mu_pr[g, 1] ~ normal(0, 1.0);     // probit(α⁺)
    mu_pr[g, 2] ~ normal(0, 1.0);     // probit(α⁻)
    mu_pr[g, 3] ~ normal(0.5, 0.5);   // log(β)
    mu_pr[g, 4] ~ normal(0, 1.0);     // κ
  }
  sigma ~ cauchy(0, 2.5);             // half-Cauchy (via <lower=0>)

  to_vector(z) ~ normal(0, 1);

  // Likelihood
  for (i in 1:N) {
    vector[2] Q;
    int prev_choice;

    Q = rep_vector(0.0, 2);   // Q_A, Q_B initialized to 0
    prev_choice = -1;         // no previous choice at start

    for (t in 1:Tsubj[i]) {
      if (choice[i, t] != -1) {

        real Q_diff = Q[1] - Q[2];

        // Symmetric perseveration: stay-bias toward previous choice
        // logit is for choosing A (arm 1)
        real pers_bonus = (prev_choice == -1) ? 0.0
                         : (prev_choice == 1 ?  kappa[i]
                                            : -kappa[i]);

        real logit_p_A = beta[i] * Q_diff + pers_bonus;

        target += categorical_logit_lpmf(choice[i, t] | [logit_p_A, 0.0]');

        {
          real PE = outcome[i, t] - Q[choice[i, t]];
          if (PE >= 0) Q[choice[i, t]] += alpha_pos[i] * PE;
          else         Q[choice[i, t]] += alpha_neg[i] * PE;
        }

        prev_choice = choice[i, t];
      }
    }
  }
}

generated quantities {
  // Subject-level pointwise log-likelihoods (LOO at subject level)
  vector[N] log_lik;

  // Convenience summaries
  real alpha_pos_BF_mean      = Phi_approx(mu_pr[1, 1]);
  real alpha_neg_BF_mean      = Phi_approx(mu_pr[1, 2]);
  real beta_BF_mean           = exp(mu_pr[1, 3]);
  real kappa_BF_mean          = mu_pr[1, 4];

  real alpha_pos_Control_mean = Phi_approx(mu_pr[2, 1]);
  real alpha_neg_Control_mean = Phi_approx(mu_pr[2, 2]);
  real beta_Control_mean      = exp(mu_pr[2, 3]);
  real kappa_Control_mean     = mu_pr[2, 4];

  for (i in 1:N) {
    vector[2] Q;
    int prev_choice;

    log_lik[i] = 0.0;
    Q = rep_vector(0.0, 2);
    prev_choice = -1;

    for (t in 1:Tsubj[i]) {
      if (choice[i, t] != -1) {

        real Q_diff = Q[1] - Q[2];
        real pers_bonus = (prev_choice == -1) ? 0.0
                         : (prev_choice == 1 ?  kappa[i]
                                            : -kappa[i]);
        real logit_p_A = beta[i] * Q_diff + pers_bonus;

        log_lik[i] += categorical_logit_lpmf(choice[i, t] | [logit_p_A, 0.0]');

        {
          real PE = outcome[i, t] - Q[choice[i, t]];
          if (PE >= 0) Q[choice[i, t]] += alpha_pos[i] * PE;
          else         Q[choice[i, t]] += alpha_neg[i] * PE;
        }

        prev_choice = choice[i, t];
      }
    }
  }
}
