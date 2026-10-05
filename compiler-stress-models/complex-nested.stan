data {
  array[2] tuple(int, array[2] tuple(real, array[3] complex_vector[2])) a;

  array[2, 2] tuple(int, tuple(real, array[2] complex_matrix[2, 3])) b;
}
generated quantities {
  int a11 = a[1].1;
  real a1211 = a[1].2[1].1;
  real a121211r = get_real(a[1].2[1].2[1][1]);
  real a121211i = get_imag(a[1].2[1].2[1][1]);
  real a121212r = get_real(a[1].2[1].2[1][2]);
  real a121212i = get_imag(a[1].2[1].2[1][2]);
  real a121221r = get_real(a[1].2[1].2[2][1]);
  real a121221i = get_imag(a[1].2[1].2[2][1]);
  real a121222r = get_real(a[1].2[1].2[2][2]);
  real a121222i = get_imag(a[1].2[1].2[2][2]);
  real a121231r = get_real(a[1].2[1].2[3][1]);
  real a121231i = get_imag(a[1].2[1].2[3][1]);
  real a121232r = get_real(a[1].2[1].2[3][2]);
  real a121232i = get_imag(a[1].2[1].2[3][2]);

  real a1221 = a[1].2[2].1;
  real a122211r = get_real(a[1].2[2].2[1][1]);
  real a122211i = get_imag(a[1].2[2].2[1][1]);
  real a122212r = get_real(a[1].2[2].2[1][2]);
  real a122212i = get_imag(a[1].2[2].2[1][2]);
  real a122221r = get_real(a[1].2[2].2[2][1]);
  real a122221i = get_imag(a[1].2[2].2[2][1]);
  real a122222r = get_real(a[1].2[2].2[2][2]);
  real a122222i = get_imag(a[1].2[2].2[2][2]);
  real a122231r = get_real(a[1].2[2].2[3][1]);
  real a122231i = get_imag(a[1].2[2].2[3][1]);
  real a122232r = get_real(a[1].2[2].2[3][2]);
  real a122232i = get_imag(a[1].2[2].2[3][2]);

  int a21 = a[2].1;
  real a221211r = get_real(a[2].2[1].2[1][1]);
  real a221211i = get_imag(a[2].2[1].2[1][1]);
  real a221212r = get_real(a[2].2[1].2[1][2]);
  real a221212i = get_imag(a[2].2[1].2[1][2]);
  real a221221r = get_real(a[2].2[1].2[2][1]);
  real a221221i = get_imag(a[2].2[1].2[2][1]);
  real a221222r = get_real(a[2].2[1].2[2][2]);
  real a221222i = get_imag(a[2].2[1].2[2][2]);
  real a221231r = get_real(a[2].2[1].2[3][1]);
  real a221231i = get_imag(a[2].2[1].2[3][1]);
  real a221232r = get_real(a[2].2[1].2[3][2]);
  real a221232i = get_imag(a[2].2[1].2[3][2]);

  real a2221 = a[2].2[2].1;
  real a222211r = get_real(a[2].2[2].2[1][1]);
  real a222211i = get_imag(a[2].2[2].2[1][1]);
  real a222212r = get_real(a[2].2[2].2[1][2]);
  real a222212i = get_imag(a[2].2[2].2[1][2]);
  real a222221r = get_real(a[2].2[2].2[2][1]);
  real a222221i = get_imag(a[2].2[2].2[2][1]);
  real a222222r = get_real(a[2].2[2].2[2][2]);
  real a222222i = get_imag(a[2].2[2].2[2][2]);
  real a222231r = get_real(a[2].2[2].2[3][1]);
  real a222231i = get_imag(a[2].2[2].2[3][1]);
  real a222232r = get_real(a[2].2[2].2[3][2]);
  real a222232i = get_imag(a[2].2[2].2[3][2]);

  int b11 = b[1, 1].1;
  real b1121 = b[1, 1].2.1;
  real b1122111r = get_real(b[1][1].2.2[1][1][1]);
  real b1122111i = get_imag(b[1][1].2.2[1][1][1]);
  real b1122112r = get_real(b[1][1].2.2[1][1][2]);
  real b1122112i = get_imag(b[1][1].2.2[1][1][2]);
  real b1122113r = get_real(b[1][1].2.2[1][1][3]);
  real b1122113i = get_imag(b[1][1].2.2[1][1][3]);

  real b1122121r = get_real(b[1][1].2.2[1][2][1]);
  real b1122121i = get_imag(b[1][1].2.2[1][2][1]);
  real b1122122r = get_real(b[1][1].2.2[1][2][2]);
  real b1122122i = get_imag(b[1][1].2.2[1][2][2]);
  real b1122123r = get_real(b[1][1].2.2[1][2][3]);
  real b1122123i = get_imag(b[1][1].2.2[1][2][3]);

  real b1122211r = get_real(b[1][1].2.2[2][1][1]);
  real b1122211i = get_imag(b[1][1].2.2[2][1][1]);
  real b1122212r = get_real(b[1][1].2.2[2][1][2]);
  real b1122212i = get_imag(b[1][1].2.2[2][1][2]);
  real b1122213r = get_real(b[1][1].2.2[2][1][3]);
  real b1122213i = get_imag(b[1][1].2.2[2][1][3]);
  real b1122221r = get_real(b[1][1].2.2[2][2][1]);
  real b1122221i = get_imag(b[1][1].2.2[2][2][1]);
  real b1122222r = get_real(b[1][1].2.2[2][2][2]);
  real b1122222i = get_imag(b[1][1].2.2[2][2][2]);
  real b1122223r = get_real(b[1][1].2.2[2][2][3]);
  real b1122223i = get_imag(b[1][1].2.2[2][2][3]);

  real b1221 = b[1, 2].2.1;
  real b1222111r = get_real(b[1][2].2.2[1][1][1]);
  real b1222111i = get_imag(b[1][2].2.2[1][1][1]);
  real b1222112r = get_real(b[1][2].2.2[1][1][2]);
  real b1222112i = get_imag(b[1][2].2.2[1][1][2]);
  real b1222113r = get_real(b[1][2].2.2[1][1][3]);
  real b1222113i = get_imag(b[1][2].2.2[1][1][3]);

  real b1222121r = get_real(b[1][2].2.2[1][2][1]);
  real b1222121i = get_imag(b[1][2].2.2[1][2][1]);
  real b1222122r = get_real(b[1][2].2.2[1][2][2]);
  real b1222122i = get_imag(b[1][2].2.2[1][2][2]);
  real b1222123r = get_real(b[1][2].2.2[1][2][3]);
  real b1222123i = get_imag(b[1][2].2.2[1][2][3]);

  real b1222211r = get_real(b[1][2].2.2[2][1][1]);
  real b1222211i = get_imag(b[1][2].2.2[2][1][1]);
  real b1222212r = get_real(b[1][2].2.2[2][1][2]);
  real b1222212i = get_imag(b[1][2].2.2[2][1][2]);
  real b1222213r = get_real(b[1][2].2.2[2][1][3]);
  real b1222213i = get_imag(b[1][2].2.2[2][1][3]);
  real b1222221r = get_real(b[1][2].2.2[2][2][1]);
  real b1222221i = get_imag(b[1][2].2.2[2][2][1]);
  real b1222222r = get_real(b[1][2].2.2[2][2][2]);
  real b1222222i = get_imag(b[1][2].2.2[2][2][2]);
  real b1222223r = get_real(b[1][2].2.2[2][2][3]);
  real b1222223i = get_imag(b[1][2].2.2[2][2][3]);

  int b21 = b[2, 1].1;
  real b2211 = b[2, 1].2.1;
  real b2212111r = get_real(b[2][1].2.2[1][1][1]);
  real b2212111i = get_imag(b[2][1].2.2[1][1][1]);
  real b2212112r = get_real(b[2][1].2.2[1][1][2]);
  real b2212112i = get_imag(b[2][1].2.2[1][1][2]);
  real b2212113r = get_real(b[2][1].2.2[1][1][3]);
  real b2212113i = get_imag(b[2][1].2.2[1][1][3]);

  real b2212121r = get_real(b[2][1].2.2[1][2][1]);
  real b2212121i = get_imag(b[2][1].2.2[1][2][1]);
  real b2212122r = get_real(b[2][1].2.2[1][2][2]);
  real b2212122i = get_imag(b[2][1].2.2[1][2][2]);
  real b2212123r = get_real(b[2][1].2.2[1][2][3]);
  real b2212123i = get_imag(b[2][1].2.2[1][2][3]);

  real b2212211r = get_real(b[2][1].2.2[2][1][1]);
  real b2212211i = get_imag(b[2][1].2.2[2][1][1]);
  real b2212212r = get_real(b[2][1].2.2[2][1][2]);
  real b2212212i = get_imag(b[2][1].2.2[2][1][2]);
  real b2212213r = get_real(b[2][1].2.2[2][1][3]);
  real b2212213i = get_imag(b[2][1].2.2[2][1][3]);
  real b2212221r = get_real(b[2][1].2.2[2][2][1]);
  real b2212221i = get_imag(b[2][1].2.2[2][2][1]);
  real b2212222r = get_real(b[2][1].2.2[2][2][2]);
  real b2212222i = get_imag(b[2][1].2.2[2][2][2]);
  real b2212223r = get_real(b[2][1].2.2[2][2][3]);
  real b2212223i = get_imag(b[2][1].2.2[2][2][3]);

  real b2221 = b[2][2].2.1;
  real b2222111r = get_real(b[2][2].2.2[1][1][1]);
  real b2222111i = get_imag(b[2][2].2.2[1][1][1]);
  real b2222112r = get_real(b[2][2].2.2[1][1][2]);
  real b2222112i = get_imag(b[2][2].2.2[1][1][2]);
  real b2222113r = get_real(b[2][2].2.2[1][1][3]);
  real b2222113i = get_imag(b[2][2].2.2[1][1][3]);

  real b2222121r = get_real(b[2][2].2.2[1][2][1]);
  real b2222121i = get_imag(b[2][2].2.2[1][2][1]);
  real b2222122r = get_real(b[2][2].2.2[1][2][2]);
  real b2222122i = get_imag(b[2][2].2.2[1][2][2]);
  real b2222123r = get_real(b[2][2].2.2[1][2][3]);
  real b2222123i = get_imag(b[2][2].2.2[1][2][3]);

  real b2222211r = get_real(b[2][2].2.2[2][1][1]);
  real b2222211i = get_imag(b[2][2].2.2[2][1][1]);
  real b2222212r = get_real(b[2][2].2.2[2][1][2]);
  real b2222212i = get_imag(b[2][2].2.2[2][1][2]);
  real b2222213r = get_real(b[2][2].2.2[2][1][3]);
  real b2222213i = get_imag(b[2][2].2.2[2][1][3]);
  real b2222221r = get_real(b[2][2].2.2[2][2][1]);
  real b2222221i = get_imag(b[2][2].2.2[2][2][1]);
  real b2222222r = get_real(b[2][2].2.2[2][2][2]);
  real b2222222i = get_imag(b[2][2].2.2[2][2][2]);
  real b2222223r = get_real(b[2][2].2.2[2][2][3]);
  real b2222223i = get_imag(b[2][2].2.2[2][2][3]);
}
