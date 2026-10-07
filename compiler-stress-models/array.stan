data {
  array[2, 2] complex input_arr;
  complex_matrix[2, 2] input_mat;
}
generated quantities {
  real a11r = get_real(input_arr[1][1]);
  real a11i = get_imag(input_arr[1][1]);
  real a12r = get_real(input_arr[1][2]);
  real a12i = get_imag(input_arr[1][2]);
  real a21r = get_real(input_arr[2][1]);
  real a21i = get_imag(input_arr[2][1]);
  real a22r = get_real(input_arr[2][2]);
  real a22i = get_imag(input_arr[2][2]);

  real m11r = get_real(input_mat[1][1]);
  real m11i = get_imag(input_mat[1][1]);
  real m12r = get_real(input_mat[1][2]);
  real m12i = get_imag(input_mat[1][2]);
  real m21r = get_real(input_mat[2][1]);
  real m21i = get_imag(input_mat[2][1]);
  real m22r = get_real(input_mat[2][2]);
  real m22i = get_imag(input_mat[2][2]);
}
