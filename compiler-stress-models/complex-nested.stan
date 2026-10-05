data {
  array[2] tuple(int, array[2] tuple(real, array[3] complex_vector[2])) input;
}
generated quantities {
  int a11 = input[1].1;
  real a1211 = input[1].2[1].1;
  real a121211r = get_real(input[1].2[1].2[1][1]);
  real a121211i = get_imag(input[1].2[1].2[1][1]);
  real a121212r = get_real(input[1].2[1].2[1][2]);
  real a121212i = get_imag(input[1].2[1].2[1][2]);
  real a121221r = get_real(input[1].2[1].2[2][1]);
  real a121221i = get_imag(input[1].2[1].2[2][1]);
  real a121222r = get_real(input[1].2[1].2[2][2]);
  real a121222i = get_imag(input[1].2[1].2[2][2]);
  real a121231r = get_real(input[1].2[1].2[3][1]);
  real a121231i = get_imag(input[1].2[1].2[3][1]);
  real a121232r = get_real(input[1].2[1].2[3][2]);
  real a121232i = get_imag(input[1].2[1].2[3][2]);

  real a1221 = input[1].2[2].1;
  real a122211r = get_real(input[1].2[2].2[1][1]);
  real a122211i = get_imag(input[1].2[2].2[1][1]);
  real a122212r = get_real(input[1].2[2].2[1][2]);
  real a122212i = get_imag(input[1].2[2].2[1][2]);
  real a122221r = get_real(input[1].2[2].2[2][1]);
  real a122221i = get_imag(input[1].2[2].2[2][1]);
  real a122222r = get_real(input[1].2[2].2[2][2]);
  real a122222i = get_imag(input[1].2[2].2[2][2]);
  real a122231r = get_real(input[1].2[2].2[3][1]);
  real a122231i = get_imag(input[1].2[2].2[3][1]);
  real a122232r = get_real(input[1].2[2].2[3][2]);
  real a122232i = get_imag(input[1].2[2].2[3][2]);

  int a21 = input[2].1;
  real a221211r = get_real(input[2].2[1].2[1][1]);
  real a221211i = get_imag(input[2].2[1].2[1][1]);
  real a221212r = get_real(input[2].2[1].2[1][2]);
  real a221212i = get_imag(input[2].2[1].2[1][2]);
  real a221221r = get_real(input[2].2[1].2[2][1]);
  real a221221i = get_imag(input[2].2[1].2[2][1]);
  real a221222r = get_real(input[2].2[1].2[2][2]);
  real a221222i = get_imag(input[2].2[1].2[2][2]);
  real a221231r = get_real(input[2].2[1].2[3][1]);
  real a221231i = get_imag(input[2].2[1].2[3][1]);
  real a221232r = get_real(input[2].2[1].2[3][2]);
  real a221232i = get_imag(input[2].2[1].2[3][2]);

  real a2221 = input[2].2[2].1;
  real a222211r = get_real(input[2].2[2].2[1][1]);
  real a222211i = get_imag(input[2].2[2].2[1][1]);
  real a222212r = get_real(input[2].2[2].2[1][2]);
  real a222212i = get_imag(input[2].2[2].2[1][2]);
  real a222221r = get_real(input[2].2[2].2[2][1]);
  real a222221i = get_imag(input[2].2[2].2[2][1]);
  real a222222r = get_real(input[2].2[2].2[2][2]);
  real a222222i = get_imag(input[2].2[2].2[2][2]);
  real a222231r = get_real(input[2].2[2].2[3][1]);
  real a222231i = get_imag(input[2].2[2].2[3][1]);
  real a222232r = get_real(input[2].2[2].2[3][2]);
  real a222232i = get_imag(input[2].2[2].2[3][2]);
}
