functions {
  matrix sign_fix(matrix a) {
    int d = rows(a);
    matrix[d, d] out = a;
    for (j in 1 : d) {
      if (a[1, j] < 0) {
        out[ : , j] = -a[ : , j];
      }
    }
    return out;
  }
}
data {
  int<lower=2> d;
  matrix[d, d] L;
  matrix[d, d] U;
}
generated quantities {
  matrix[d, d] a = sign_fix(L * U);
}
