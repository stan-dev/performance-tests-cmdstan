// regression test for https://github.com/stan-dev/stan/issues/3437
data {
  array[2] tuple(real, complex) d;
  array[2] tuple(complex, real) e;
  tuple(real, complex) f;
}
generated quantities {
  real d11 = d[1].1;
  real d12r = get_real(d[1].2);
  real d12i = get_imag(d[1].2);
  real d21 = d[2].1;
  real d22r = get_real(d[2].2);
  real d22i = get_imag(d[2].2);
  real e11r = get_real(e[1].1);
  real e11i = get_imag(e[1].1);
  real e12 = e[1].2;
  real e21r = get_real(e[2].1);
  real e21i = get_imag(e[2].1);
  real e22 = e[2].2;
  real f1 = f.1;
  real f2r = get_real(f.2);
  real f2i = get_imag(f.2);
}
