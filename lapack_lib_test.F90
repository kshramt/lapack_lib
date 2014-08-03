program main
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: INT8, INT64
   use, non_intrinsic:: lapack_lib, only: mul

   implicit none

   if(mul(2, 3) /= 6) error stop
   if(any(mul([1, 2], 3) /= [3, 6])) error stop
   if(mul([1, 2], [3, 4]) /= 11) error stop
   if(any(mul(reshape([1, 2, 3, 4, 5, 6], [2, 3]), [3, 4, 5]) /= [40, 52])) error stop
   if(any(mul(reshape(int([1, 2, 3, 4, 5, 6], kind=INT64), int([2, 3], kind=INT8)), reshape([1, 1, 1, -1, -1, -1], [3, 2])) /= reshape([9, 12, -9, -12], [2, 2]))) error stop
   if(kind(mul(reshape(int([1, 2, 3, 4, 5, 6], kind=INT64), [2, 3]), reshape(int([1, 1, 1, -1, -1, -1], kind=INT8), [3, 2]))) /= INT64) error stop
   if(mul([1, 2], [3.0, 4.0]) /= 11) error stop
   if(mul([1, 2, 3], [3.0, 4.0, 5.0]) /= 11) error stop
   stop
end program main
