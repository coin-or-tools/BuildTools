
###########################################################################
#                       COIN_CHK_LAPACK                                   #
###########################################################################

# COIN_CHK_LAPACK([client packages])

# This macro checks for a LAPACK library and adds the information necessary
# to use it to the _LFLAGS and _PCFILES variables of the client packages
# passed as a space-separated list in parameter $1. These correspond to
# Libs.private and Requires.private, respectively, in a .pc file.

# The macro does not consider or set compile flags. The macro finds some
# implementation of LAPACK for code that requires only the ability to link. If
# you want to write code targeted to a specific implementation of LAPACK, you
# should use CHK_LIBHDR & related to find it.

# The algorithm first looks for command line parameters --with-lapack
# and --with-lapack-lflags. If nothing is found, system-specific default
# locations are checked, followed by some generic defaults.  A link check
# is used to determine whether default locations work and to determine the
# name mangling scheme of the Lapack library.

AC_DEFUN([AC_COIN_CHK_LAPACK],
[
  AC_MSG_CHECKING(for LAPACK)

dnl Make sure the necessary variables exist for each client package.
  m4_foreach_w([myvar],[$1],
    [AC_SUBST(m4_toupper(myvar)_LFLAGS)
     AC_SUBST(m4_toupper(myvar)_PCFILES)
    ])

dnl Set up command line arguments with DEF_PRIM_ARGS. cflags is deliberately
dnl not provided.
  AC_COIN_DEF_PRIM_ARGS([lapack],yes,yes,no,no)

dnl Assume the worst and persist in the face of failure.
  coin_has_lapack=no
  lapack_keep_looking=yes

dnl Look for user-specified lapack flags and try them if present. Pay
dnl attention if the user says 'no' on the command lin.
  if test "$with_lapack" != "no" ; then
    if test -n "$with_lapack_lflags" ; then
      AC_COIN_TRY_LINK([dorhr_col],[$with_lapack_lflags],[],
        [coin_has_lapack=yes
         lapack_what="user-specified ($with_lapack_lflags)"
         lapack_keep_looking=no
         lapack_lflags=$with_lapack_lflags],
        [AC_MSG_ERROR([Cannot link to user-specified Lapack $with_lapack_lflags.])])
    fi
  else
    lapack_keep_looking=no
    lapack_what="user-specified"
  fi

dnl If we didn't find anything, try a few more guesses for optimized
dnl blas/lapack libs (based on build system type).
dnl
dnl To use static MKL libs on Linux/Darwin, one would need to enclose the libs
dnl into -Wl,--start-group ... -Wl,--end-group. Unfortunately, libtool does
dnl not write these flags into the dependency_libs of the .la file, so linking
dnl an executable fails. See also
dnl https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=159760&repeatmerged=yes
dnl So for now the checks below will only work for shared MKL libs on
dnl Linux/Darwin.

  if test "$lapack_keep_looking" = yes ; then
    case $build in
      *-linux*)
        AC_COIN_TRY_LINK([dorhr_col],
          [-lmkl_core -lmkl_intel_lp64 -lmkl_sequential -lm],[],
          [coin_has_lapack=yes
           lapack_lflags="-lmkl_core -lmkl_intel_lp64 -lmkl_sequential -lm"
           lapack_what="Intel MKL ($lapack_lflags)"
          ])
      ;;

dnl Ideally, we would use -library=sunperf, but it is an imperfect world.
dnl Studio cc does not recognise -library, it wants -xlic_lib. Studio 12
dnl CC does not recognise -xlic_lib. Libtool does not like -xlic_lib
dnl anyway. Sun claims that CC and cc will understand -library in Studio
dnl 13. The main extra function of -xlic_lib and -library is to arrange
dnl for the Fortran run-time libraries to be linked for C++ and C. We
dnl can arrange that explicitly.
      *-*-solaris*)
        AC_COIN_TRY_LINK([dorhr_col],
          [-lsunperf],[],
          [coin_has_lapack=yes
           lapack_lflags=-lsunperf
           lapack_what="Sun Performance Library ($lapack_lflags)"
         ])
      ;;

      *-cygwin* | *-mingw* | *-msys*)
dnl Check for 64-bit sequential MKL in $LIB
dnl TODO We may want to add an option to check for parallel MKL or switch to
dnl it by default?
        old_IFS="$IFS"
        IFS=";"
        coin_mkl=""
        for d in $LIB ; do
          # turn $d into unix-style short path (no spaces); cannot do -us,
          # so first do -ws, then -u
          d=`cygpath -ws "$d"`
          d=`cygpath -u "$d"`
          if test "$enable_shared" = yes ; then
            if test -e "$d/mkl_core_dll.lib" ; then
              coin_mkl="$d/mkl_intel_lp64_dll.lib $d/mkl_sequential_dll.lib $d/mkl_core_dll.lib"
              break
            fi
          else
            if test -e "$d/mkl_core.lib" ; then
              coin_mkl="$d/mkl_intel_lp64.lib $d/mkl_sequential.lib $d/mkl_core.lib"
              break
            fi
          fi
        done
        IFS="$old_IFS"
        if test -n "$coin_mkl" ; then
           AC_COIN_TRY_LINK([dorhr_col],[$coin_mkl],[],
               [coin_has_lapack=yes
                lapack_lflags="$coin_mkl"
                lapack_what="Intel MKL ($lapack_lflags)"
               ])
        fi
      ;;

      *-darwin*)
        AC_COIN_TRY_LINK([dorhr_col],
          [-lmkl_core -lmkl_intel_lp64 -lmkl_sequential -lm],[],
          [coin_has_lapack=yes
           lapack_lflags="-lmkl_core -lmkl_intel_lp64 -lmkl_sequential -lm"
           lapack_what="Intel MKL ($lapack_lflags)"
          ],
          [],[no])
        if test "$coin_has_lapack" = no ; then
          AC_COIN_TRY_LINK([dorhr_col],
            [-framework Accelerate],[],
            [coin_has_lapack=yes
             lapack_lflags="-framework Accelerate"
             lapack_what="Accelerate framework ($lapack_lflags)"
            ])
        fi
      ;;
    esac
    if test "$coin_has_lapack" = yes ; then
      lapack_keep_looking=no
    fi
  fi

dnl If none of the above worked, check whether lapack.pc blas.pc exists and
dnl links. We check for both to ensure that blas lib also appears on link line
dnl in case someone wants to use Blas functions but tests only for Lapack.
  if test "$lapack_keep_looking" = yes ; then
    AC_COIN_CHK_MOD_EXISTS([lapack],[lapack blas],
      [lapack_what="generic module (lapack.pc blas.pc)"
       AC_COIN_TRY_LINK([dorhr_col],[],[lapack],
        [coin_has_lapack=yes
         lapack_keep_looking=no
         lapack_pcfiles="lapack blas"],
        [AC_MSG_WARN([lapack.pc and blas.pc present, but could not find dorhr_col when trying to link with LAPACK.])])])
  fi
dnl TODO do we need another check with lapack.pc only?

dnl If none of the above worked, try the generic -llapack -lblas as last
dnl resort.  We check for both to ensure that blas lib also appears on
dnl link line in case someone wants to use Blas functions but tests only
dnl for Lapack.
  if test "$lapack_keep_looking" = yes ; then
    AC_COIN_TRY_LINK([dorhr_col],[-llapack -lblas],[],
      [coin_has_lapack=yes
       lapack_lflags="-llapack -lblas"
       lapack_what="generic library ($lapack_lflags)"])
  fi
dnl TODO do we need another check with -llapack only?

dnl Inform the user of the result.
  case "$coin_has_lapack" in
    yes)
      AC_MSG_RESULT([$coin_has_lapack: $lapack_what])
      ;;
    no)
      if test -n "$lapack_what" ; then
        AC_MSG_RESULT([$coin_has_lapack ($lapack_what)])
      else
        AC_MSG_RESULT([$coin_has_lapack])
      fi
      ;;
    *)
      AC_MSG_WARN([CHK_LAPACK: unexpected result '$coin_has_lapack'])
      ;;
  esac

dnl Create an automake conditional COIN_HAS_LAPACK.
  AM_CONDITIONAL(COIN_HAS_LAPACK,[test $coin_has_lapack = yes])

dnl If we've located the package, define preprocessor symbol COIN_HAS_LAPACK
dnl and COIN_LAPACK_FUNC[_] and augment the necessary variables for the
dnl client packages.
  if test $coin_has_lapack = yes ; then
    AC_DEFINE(m4_toupper(AC_PACKAGE_NAME)_HAS_LAPACK,[1],
      [Define to 1 if the LAPACK package is available])
    AC_COIN_DEFINENAMEMANGLING(m4_toupper(AC_PACKAGE_NAME)_LAPACK,
      ${dorhr_col_namemangling})
    m4_foreach_w([myvar],[$1],
      [if test -n "$lapack_pcfiles" ; then
        m4_toupper(myvar)_PCFILES="$lapack_pcfiles $m4_toupper(myvar)_PCFILES"
       fi
       m4_toupper(myvar)_LFLAGS="$lapack_lflags $m4_toupper(myvar)_LFLAGS"
      ])
  fi
]) # AC_COIN_CHK_LAPACK
