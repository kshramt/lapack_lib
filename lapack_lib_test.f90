#include "lapack_lib.h"
program main
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: INT8, INT64
   use, non_intrinsic:: lapack_lib, only: mul, TR_C, TR_T, TR_N
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: array_lib, only: eye

   implicit none

   Complex:: c22(3, 5)

   TEST(almost_equal(mul(2, 3), 6))
   TEST(almost_equal(mul([1, 2], [3, 4]), 11))
   TEST(all(almost_equal(mul(reshape([1, 2, 3, 4, 5, 6], [2, 3]), [3, 4, 5]), [40, 52])))
   TEST(any(almost_equal(mul(reshape(int([1, 2, 3, 4, 5, 6], kind=INT64), int([2, 3], kind=INT8)), reshape([1, 1, 1, -1, -1, -1], [3, 2])), reshape([9, 12, -9, -12], [2, 2]))))
   TEST(kind(mul(reshape(int([1, 2, 3, 4, 5, 6], kind=INT64), [2, 3]), reshape(int([1, 1, 1, -1, -1, -1], kind=INT8), [3, 2]))) == INT64)
   TEST(almost_equal(mul([1, 2], [3.0, 4.0]), 11.0))

   TEST(all(almost_equal(mul(reshape([1, 2], [1, 2]), reshape([3, 4], [2, 1])), 11)))
   TEST(all(almost_equal(mul(real(reshape([1, 2], [1, 2])), reshape([3, 4], [2, 1])), 11.0)))

   TEST(all(almost_equal(mul(reshape([1, 2], [1, 2]), real(reshape([3, 4], [2, 1]))), 11.0)))
   TEST(all(almost_equal(mul(reshape([1, 2], [1, 2]), real(reshape([3, 4], [2, 1])), TR_N, TR_N), 11.0)))
   TEST(all(almost_equal(mul(reshape([1, 2], [2, 1]), real(reshape([3, 4], [2, 1])), TR_T, TR_N), 11.0)))
   c22 = mul(eye(4, 3), mul((0, 1), eye(5, 4)), TR_T, TR_C)
   TEST(all(almost_equal(shape(mul(eye(4, 3), mul((0, 1), eye(5, 4)), TR_T, TR_C)), shape(c22))))
   TEST(all(almost_equal(mul((0, 1), eye(2)), reshape([(0, 1), (0, 0), (0, 0), (0, 1)], [2, 2]))))
   TEST(all(almost_equal(mul(1, (0, 1)*eye(2)), reshape([(0, 1), (0, 0), (0, 0), (0, 1)], [2, 2]))))
   TEST(all(almost_equal(mul((0, 1), eye(2)), reshape([(0, 1), (0, 0), (0, 0), (0, 1)], [2, 2]))))
   TEST(all(almost_equal(mul(eye(2), eye(2)), eye(2))))
   TEST(all(almost_equal(mul(eye(2), eye(2), TR_T, TR_T), eye(2))))
   TEST(all(almost_equal(mul(mul((0, 1), eye(2)), mul((0, 1), eye(2))), reshape([(-1, 0), (0, 0), (0, 0), (-1, 0)], [2, 2]))))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__
   stop
end program main
