transformed data {
  int<lower=0> N = 10;
  int<lower=0> K = 3;
}
parameters {
  simplex[N] x;
  sum_to_zero_vector[N] y;
  cholesky_factor_corr[K] L;
}
model {
  x ~ dirichlet(rep_vector(1, N));
  y ~ normal(0, 1);
  L ~ lkj_corr_cholesky(2);
}
