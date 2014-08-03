module lapack_interface_lib
   implicit none

   private
   public:: sdot, ddot, cdotc, zdotc


   interface
      pure function sdot(n, x, incx, y, incy) result(res)
         use, intrinsic:: iso_fortran_env, only: REAL32
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Integer(kind=SIZE_KIND), intent(in):: n
         Real(kind=REAL32), intent(in):: x(*)
         Integer(kind=SIZE_KIND), intent(in):: incx
         Real(kind=REAL32), intent(in):: y(*)
         Integer(kind=SIZE_KIND), intent(in):: incy
         Real(kind=REAL32):: res
      end function sdot
   end interface

   interface ddot
      pure function ddot(n, x, incx, y, incy) result(res)
         use, intrinsic:: iso_fortran_env, only: REAL64
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Integer(kind=SIZE_KIND), intent(in):: n
         Real(kind=REAL64), intent(in):: x(*)
         Integer(kind=SIZE_KIND), intent(in):: incx
         Real(kind=REAL64), intent(in):: y(*)
         Integer(kind=SIZE_KIND), intent(in):: incy
         Real(kind=REAL64):: res
      end function ddot
   end interface ddot

   interface cdotc
      pure function cdotc(n, x, incx, y, incy) result(res)
         use, intrinsic:: iso_fortran_env, only: REAL32
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Integer(kind=SIZE_KIND), intent(in):: n
         Complex(kind=REAL32), intent(in):: x(*)
         Integer(kind=SIZE_KIND), intent(in):: incx
         Complex(kind=REAL32), intent(in):: y(*)
         Integer(kind=SIZE_KIND), intent(in):: incy
         Complex(kind=REAL32):: res
      end function cdotc
   end interface cdotc

   interface zdotc
      pure function zdotc(n, x, incx, y, incy) result(res)
         use, intrinsic:: iso_fortran_env, only: REAL64
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Integer(kind=SIZE_KIND), intent(in):: n
         Complex(kind=REAL64), intent(in):: x(*)
         Integer(kind=SIZE_KIND), intent(in):: incx
         Complex(kind=REAL64), intent(in):: y(*)
         Integer(kind=SIZE_KIND), intent(in):: incy
         Complex(kind=REAL64):: res
      end function zdotc
   end interface zdotc
end module lapack_interface_lib
