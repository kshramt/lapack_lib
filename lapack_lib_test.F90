program main
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, non_intrinsic:: lapack_lib, only: mul

   implicit none

   if(mul(2, 3) /= 6) error stop
   if(all(mul([1, 2], 3) /= [3, 6])) error stop
   if(mul([1, 2], [3, 4]) /= 11) error stop

   stop
end program main
