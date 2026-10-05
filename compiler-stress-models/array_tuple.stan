data {
  array[2, 2] tuple(real, array[2, 2] real) input_arr;
  array[2, 2] tuple(matrix[2, 2], real) input_mat;
}
generated quantities {
  real a111 = input_arr[1, 1].1;
  real a11211 = input_arr[1, 1].2[1][1];
  real a11212 = input_arr[1, 1].2[1][2];
  real a11221 = input_arr[1, 1].2[2][1];
  real a11222 = input_arr[1, 1].2[2][2];
  real a121 = input_arr[1, 2].1;
  real a12211 = input_arr[1, 2].2[1][1];
  real a12212 = input_arr[1, 2].2[1][2];
  real a12221 = input_arr[1, 2].2[2][1];
  real a12222 = input_arr[1, 2].2[2][2];

  real a211 = input_arr[2, 1].1;
  real a21211 = input_arr[2, 1].2[1][1];
  real a21212 = input_arr[2, 1].2[1][2];
  real a21221 = input_arr[2, 1].2[2][1];
  real a21222 = input_arr[2, 1].2[2][2];
  real a221 = input_arr[2, 2].1;
  real a22211 = input_arr[2, 2].2[1][1];
  real a22212 = input_arr[2, 2].2[1][2];
  real a22221 = input_arr[2, 2].2[2][1];
  real a22222 = input_arr[2, 2].2[2][2];

  real m11111 = input_mat[1, 1].1[1][1];
  real m11112 = input_mat[1, 1].1[1][2];
  real m11121 = input_mat[1, 1].1[2][1];
  real m11122 = input_mat[1, 1].1[2][2];
  real m112 = input_mat[1, 1].2;
  real m12111 = input_mat[1, 2].1[1][1];
  real m12112 = input_mat[1, 2].1[1][2];
  real m12121 = input_mat[1, 2].1[2][1];
  real m12122 = input_mat[1, 2].1[2][2];
  real m122 = input_mat[1, 2].2;

  real m21111 = input_mat[2, 1].1[1][1];
  real m21112 = input_mat[2, 1].1[1][2];
  real m21121 = input_mat[2, 1].1[2][1];
  real m21122 = input_mat[2, 1].1[2][2];
  real m212 = input_mat[2, 1].2;
  real m22111 = input_mat[2, 2].1[1][1];
  real m22112 = input_mat[2, 2].1[1][2];
  real m22121 = input_mat[2, 2].1[2][1];
  real m22122 = input_mat[2, 2].1[2][2];
  real m222 = input_mat[2, 2].2;
}
