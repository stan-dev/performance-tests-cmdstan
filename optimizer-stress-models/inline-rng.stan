functions {
  real self_diff(real x) {
    return x - x;
  }
}
generated quantities {
  real z = self_diff(normal_rng(0, 5));
  if (z != 0.0) {
    fatal_error("whoops!");
  }
}
