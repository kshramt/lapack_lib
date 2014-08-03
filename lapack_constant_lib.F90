module lapack_constant_lib
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT

   implicit none

   private

   Integer, parameter, public:: SIZE_KIND = kind(0)
   Integer(kind=SIZE_KIND), parameter, public:: ONE = 1
end module lapack_constant_lib
