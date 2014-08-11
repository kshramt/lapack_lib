module lapack_interface_lib
   implicit none

   private
   public:: sgemm, dgemm, cgemm, zgemm
   public:: sgemv, dgemv, cgemv, zgemv
   public:: sdot, ddot, cdotc, zdotc


   interface
      subroutine sgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
         use, intrinsic:: iso_fortran_env, only: P => REAL32
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Character(len=1), intent(in):: transa, transb
         Integer(kind=SIZE_KIND), intent(in):: m, n, k, lda, ldb, ldc
         Real(kind=P), intent(in):: alpha, a(lda, *), b(ldb, *), beta, c(ldc, *)
      end subroutine sgemm

      subroutine dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
         use, intrinsic:: iso_fortran_env, only: P => REAL64
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Character(len=1), intent(in):: transa, transb
         Integer(kind=SIZE_KIND), intent(in):: m, n, k, lda, ldb, ldc
         Real(kind=P), intent(in):: alpha, a(lda, *), b(ldb, *), beta, c(ldc, *)
      end subroutine dgemm

      subroutine cgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
         use, intrinsic:: iso_fortran_env, only: P => REAL32
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Character(len=1), intent(in):: transa, transb
         Integer(kind=SIZE_KIND), intent(in):: m, n, k, lda, ldb, ldc
         Complex(kind=P), intent(in):: alpha, a(lda, *), b(ldb, *), beta, c(ldc, *)
      end subroutine cgemm

      subroutine zgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
         use, intrinsic:: iso_fortran_env, only: P => REAL64
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Character(len=1), intent(in):: transa, transb
         Integer(kind=SIZE_KIND), intent(in):: m, n, k, lda, ldb, ldc
         Complex(kind=P), intent(in):: alpha, a(lda, *), b(ldb, *), beta, c(ldc, *)
      end subroutine zgemm


      subroutine sgemv(trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
         use, intrinsic:: iso_fortran_env, only: P => REAL32
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Character(len=1), intent(in):: trans
         Integer(kind=SIZE_KIND), intent(in):: m, n, lda, incx, incy
         Real(kind=P), intent(in):: alpha, a(lda, *), x(n), beta, y(n)
      end subroutine sgemv

      subroutine dgemv(trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
         use, intrinsic:: iso_fortran_env, only: P => REAL64
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Character(len=1), intent(in):: trans
         Integer(kind=SIZE_KIND), intent(in):: m, n, lda, incx, incy
         Real(kind=P), intent(in):: alpha, a(lda, *), x(n), beta, y(n)
      end subroutine dgemv

      subroutine cgemv(trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
         use, intrinsic:: iso_fortran_env, only: P => REAL32
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Character(len=1), intent(in):: trans
         Integer(kind=SIZE_KIND), intent(in):: m, n, lda, incx, incy
         Complex(kind=P), intent(in):: alpha, a(lda, *), x(n), beta, y(n)
      end subroutine cgemv

      subroutine zgemv(trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
         use, intrinsic:: iso_fortran_env, only: P => REAL64
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Character(len=1), intent(in):: trans
         Integer(kind=SIZE_KIND), intent(in):: m, n, lda, incx, incy
         Complex(kind=P), intent(in):: alpha, a(lda, *), x(n), beta, y(n)
      end subroutine zgemv



      function sdot(n, x, incx, y, incy) result(res)
         use, intrinsic:: iso_fortran_env, only: P => REAL32
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Integer(kind=SIZE_KIND), intent(in):: n
         Real(kind=P), intent(in):: x(*)
         Integer(kind=SIZE_KIND), intent(in):: incx
         Real(kind=P), intent(in):: y(*)
         Integer(kind=SIZE_KIND), intent(in):: incy
         Real(kind=P):: res
      end function sdot
   end interface

   interface ddot
      function ddot(n, x, incx, y, incy) result(res)
         use, intrinsic:: iso_fortran_env, only: P => REAL64
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Integer(kind=SIZE_KIND), intent(in):: n
         Real(kind=P), intent(in):: x(*)
         Integer(kind=SIZE_KIND), intent(in):: incx
         Real(kind=P), intent(in):: y(*)
         Integer(kind=SIZE_KIND), intent(in):: incy
         Real(kind=P):: res
      end function ddot
   end interface ddot

   interface cdotc
      function cdotc(n, x, incx, y, incy) result(res)
         use, intrinsic:: iso_fortran_env, only: P => REAL32
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Integer(kind=SIZE_KIND), intent(in):: n
         Complex(kind=P), intent(in):: x(*)
         Integer(kind=SIZE_KIND), intent(in):: incx
         Complex(kind=P), intent(in):: y(*)
         Integer(kind=SIZE_KIND), intent(in):: incy
         Complex(kind=P):: res
      end function cdotc
   end interface cdotc

   interface zdotc
      function zdotc(n, x, incx, y, incy) result(res)
         use, intrinsic:: iso_fortran_env, only: P => REAL64
         use, non_intrinsic:: lapack_constant_lib, only: SIZE_KIND
         Integer(kind=SIZE_KIND), intent(in):: n
         Complex(kind=P), intent(in):: x(*)
         Integer(kind=SIZE_KIND), intent(in):: incx
         Complex(kind=P), intent(in):: y(*)
         Integer(kind=SIZE_KIND), intent(in):: incy
         Complex(kind=P):: res
      end function zdotc
   end interface zdotc
end module lapack_interface_lib
