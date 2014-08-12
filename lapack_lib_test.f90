#include "lapack_lib.h"
program main
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: INT8, INT64
   use, non_intrinsic:: lapack_lib, only: mul
   use, non_intrinsic:: comparable_lib, only: almost_equal

   implicit none

   TEST(almost_equal(mul(2, 3), 6))
   TEST(almost_equal(mul([1, 2], [3, 4]), 11))
   TEST(all(almost_equal(mul(reshape([1, 2, 3, 4, 5, 6], [2, 3]), [3, 4, 5]), [40, 52])))
   TEST(any(almost_equal(mul(reshape(int([1, 2, 3, 4, 5, 6], kind=INT64), int([2, 3], kind=INT8)), reshape([1, 1, 1, -1, -1, -1], [3, 2])), reshape([9, 12, -9, -12], [2, 2]))))
   TEST(kind(mul(reshape(int([1, 2, 3, 4, 5, 6], kind=INT64), [2, 3]), reshape(int([1, 1, 1, -1, -1, -1], kind=INT8), [3, 2]))) == INT64)
   TEST(almost_equal(mul([1, 2], [3.0, 4.0]), 11.0))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__
   stop
end program main
