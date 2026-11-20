
functions {
  int find_interval(real x0, vector cuts) {
    int i = 1;
    while (i <= rows(cuts)) {
      if (x0 < cuts[i]) return i;
      i += 1;
    }
    return 0;
  }
  real widen(real s) {
    return 2 * s;
  }
  int next_index(int i) {
    return i * 1;
  }
  real noise_rng() {
    return normal_rng(0, 1);
  }
}
data {
  vector[4] cuts;
  real<lower=0> s;
  real x;
  real y;
}
parameters {
  real<lower=0, upper=1> a;
  real tau;
}
model {
  target += find_interval(a, cuts) * a;
  tau ~ normal(0, widen(s));
}
generated quantities {
  int interval = find_interval(a, cuts);
  int n = 0;
  {
    int i = 0;
    while (next_index(i) < 3) {
      i += 1;
      n += 1;
      if (n < 10) continue;
    }
  }
  real first = x;
  real copied;
  {
    real c = first;
    first = y;
    copied = c;
  }
  int both = 0.5 > normal_rng(0, 1) && noise_rng() > 0;
}
