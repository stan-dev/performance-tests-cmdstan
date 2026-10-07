data {
  array[2, 3] real input_arr;
  array[2, 3] tuple(real,) input_tup;
}
generated quantities {
  real a11 = input_arr[1][1];
  real a12 = input_arr[1][2];
  real a13 = input_arr[1][3];
  real a21 = input_arr[2][1];
  real a22 = input_arr[2][2];
  real a23 = input_arr[2][3];

  real t11 = input_tup[1][1].1;
  real t12 = input_tup[1][2].1;
  real t13 = input_tup[1][3].1;
  real t21 = input_tup[2][1].1;
  real t22 = input_tup[2][2].1;
  real t23 = input_tup[2][3].1;
}
