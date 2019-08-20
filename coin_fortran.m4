
###########################################################################
#                  Fortran Utility Macros                                 #
###########################################################################
# Macros that help with building Fortran code or simply linking to Fortran
# code.
###########################################################################

# Due to the way AC_REQUIRE is implemented (REQUIREd macros are expanded
# before the body of the topmost unexpanded macro) it's impossible to use
# any variation of nested macro calls to invoke COIN_PROG_F77 to check
# for a compiler, then conditionally invoke the macros required for a fully
# functional environment based on the value of the shell variable F77.  If your
# configuration requires that you handle both cases (working compiler and
# no compiler) you need to invoke COIN_PROG_F77 from configure.ac, then test
# the value of the variable F77 and invoke the appropriate follow-on macro, as
#
#   AC_COIN_PROG_F77
#   if test "$F77" != "unavailable" ; then
#     AC_COIN_F77_SETUP
#   else
#     AC_COIN_F77_WRAPPERS
#   fi
#
# If all you want to do is link to Fortran libraries from C/C++ code
# and you have no intention of compiling Fortran code, just invoke
# AC_COIN_F77_WRAPPERS.
#
# If a working Fortran compiler is necessary and you would like configuration
# to abort if a working compiler can't be found, try
#
#   AC_COIN_PROG_F77
#   if test "$F77" != "unavailable" ; then
#     AC_COIN_F77_SETUP
#   else
#     AC_MSG_ERROR([cannot find a working Fortran compiler!])
#   fi

###########################################################################
#                   COIN_PROG_F77                                         #
###########################################################################

# COIN_PROG_F77 will find a Fortran compiler, or set F77 to unavailable. Alone,
# this is not sufficient to actually build Fortran code. For that, use
# COIN_F77_SETUP.

# Unlike C/C++, automake doesn't mess with AC_PROG_F77.

AC_DEFUN_ONCE([AC_COIN_PROG_F77],
[
  # AC_MSG_NOTICE([In COIN_PROG_F77])
  AC_REQUIRE([AC_COIN_ENABLE_MSVC])

# If enable-msvc, then test only for Intel (on Windows) Fortran compiler

  if test $enable_msvc = yes ; then
    comps="ifort"
  else
    # TODO old buildtools was doing some $build specific logic here, do we still
    # need this?
    comps="gfortran ifort g95 fort77 f77 f95 f90 g77 pgf90 pgf77 ifc frt af77 xlf_r fl32"
  fi
  AC_PROG_F77([$comps])

# Allow for the possibility that there is no Fortran compiler on the system.

  if test "${F77:-unavailable}" = unavailable ; then
    F77=unavailable
    AC_MSG_NOTICE([No Fortran compiler available.])
  fi
  AM_CONDITIONAL([COIN_HAS_F77], test "$F77" != "unavailable")
  # AC_MSG_NOTICE([Leaving COIN_PROG_F77])
])


###########################################################################
#                   COIN_PROG_FC                                          #
###########################################################################

AC_DEFUN_ONCE([AC_COIN_PROG_FC],
[
  AC_REQUIRE([AC_COIN_ENABLE_MSVC])

  # TODO
  AC_MSG_ERROR(["AC_COIN_PROG_FC not implemented yet"])
])


###########################################################################
#                   COIN_F77_SETUP                                        #
###########################################################################

# Do the necessary work to make it possible to compile Fortran object files
# and invoke Fortran functions from C/C++ code. Requires a working Fortran
# compiler, otherwise configure will fail. See comments at top of file.
#
# If all you want to do is link to Fortran code, try AC_COIN_F77_WRAPPERS.

AC_DEFUN([AC_COIN_F77_SETUP],
[
  # AC_MSG_NOTICE([In COIN_F77_SETUP])

# F77_WRAPPERS will trigger the necessary F77 setup macros (F77_MAIN,
# F77_LIBRARY_LDFLAGS, etc.)

  AC_F77_WRAPPERS
  AC_PROG_F77_C_O
  if test $ac_cv_prog_f77_c_o = no ; then
    F77="$am_aux_dir/compile $F77"
  fi
  # AC_MSG_NOTICE([Leaving COIN_F77_SETUP])
])

# COIN_F77_WRAPPERS (lib,func)
# -------------------------------------------------------------------------
# Determine C/C++ name mangling without a Fortran compiler, to allow linking
# with Fortran libraries on systems where there's no working Fortran compiler.
#  lib ($1) a library we're attempting to link to
#  func ($2) a function within that library

# Ideally, the function name will contain an embedded underscore but the
# macro doesn't require that because typical COIN use cases (BLAS, LAPACK)
# don't have any names with embedded underscores. The default is `no extra
# underscore' (because this is tested first and will succeed if the name
# has no embedded underscore).

# The possibilities amount to
# { lower / upper case } X (no) trailing underscore X (no) extra underscore
# where the extra underscore is applied to name with an embedded underscore.

# ac_cv_f77_mangling is documented, so should be fairly safe to use.

# The trick here is to avoid any of the documented F77_ macros, as they all
# eventually REQUIRE a macro that requires a functioning Fortran compiler.

# -------------------------------------------------------------------------

AC_DEFUN([AC_COIN_F77_WRAPPERS],
[ 
  # AC_MSG_NOTICE([In COIN_F77_WRAPPERS])
  AC_CACHE_CHECK(
    [Fortran name mangling scheme],
    [ac_cv_f77_mangling],
    [ac_save_LIBS=$LIBS
     LIBS="-l$1"
     for ac_case in "lower case" "upper case" ; do
       for ac_trail in "underscore" "no underscore" ; do
         for ac_extra in "no extra underscore" "extra underscore" ; do
           ac_cv_f77_mangling="${ac_case}, ${ac_trail}, ${ac_extra}"
           # AC_MSG_NOTICE([Attempting link for $ac_cv_f77_mangling])
           case $ac_case in
             "lower case")
               ac_name=m4_tolower($2)
               ;;
             "upper case")
               ac_name=m4_toupper($2)
               ;;
           esac
           if test "$ac_trail" = underscore ; then
             ac_name=${ac_name}_
           fi
           # AC_MSG_CHECKING([$2 -> $ac_name])
           AC_LINK_IFELSE(
             [AC_LANG_PROGRAM(
                [#ifdef __cplusplus
                  extern "C"
                 #endif
                 void $ac_name();],
                [$ac_name()])],
             [ac_result=success],
             [ac_result=failure])
           # AC_MSG_RESULT([$result])
           if test $ac_result = success ; then
             break 3
           fi
         done
       done
     done
     if test "$ac_result" = "failure" ; then
       ac_cv_f77_mangling=unknown
     fi
     LIBS=$ac_save_LIBS])

# Invoke the second-level internal autoconf macro _AC_FC_WRAPPERS to give the
# functionality of AC_F77_WRAPPERS.

  if test "$ac_cv_f77_mangling" != unknown ; then
    AC_LANG_PUSH([Fortran 77])
    _AC_FC_WRAPPERS
    AC_LANG_POP([Fortran 77])
  else
    AC_MSG_WARN([Unable to determine correct Fortran name mangling scheme])
  fi
  # AC_MSG_NOTICE([Done COIN_F77_WRAPPERS])
])


# COIN_F77_FUNC(ftn_name,c_name)
# -------------------------------------------------------------------------
# Sets the shell variable c_name to the appropriate mangle of the Fortran
# function ftn_name.
#
# Duplicates the direct result of F77_FUNC by invoking the second level
# internal autoconf macro. This sidesteps a REQUIRE of a macro chain that
# requires a functioning Fortran compiler. This macro requires that
# ac_cv_f77_mangling be defined, either by invoking F77_WRAPPERS (if a Fortran
# compiler exists) or COIN_F77_WRAPPERS (if a Fortran compiler does not exist).
# -------------------------------------------------------------------------

AC_DEFUN([AC_COIN_F77_FUNC],
[ AC_LANG_PUSH(Fortran 77)
  _AC_FC_FUNC($1,$2)
  AC_LANG_POP(Fortran 77)
])


# COIN_TRY_FLINK(fname,[action if success],[action if failure])

# Auxilliary macro to test if a Fortran function fname can be linked, given
# the current settings of LIBS.  We determine from the context (ac_ext, the
# source file extension), what the currently active programming language is,
# and cast the name accordingly.  The first argument is the name of the
# function/subroutine, the second argument is the actions taken when the
# test works, and the third argument is the actions taken if the test fails.
# Note that we're using COIN_F77_FUNC rather than F77_FUNC to avoid triggering
# macros that require a working Fortran compiler.

AC_DEFUN([AC_COIN_TRY_FLINK],
[ # AC_MSG_NOTICE([In COIN_TRY_FLINK])
  case $ac_ext in
    f)
      AC_TRY_LINK(,[      call $1],[flink_try=yes],[flink_try=no])
      ;;
    c)
      coin_need_flibs=no
      flink_try=no
      AC_COIN_F77_FUNC($1,cfunc$1)
      # AC_MSG_NOTICE([COIN_TRY_FLINK: $1 -> $cfunc$1])
      AC_LINK_IFELSE(
        [AC_LANG_PROGRAM([void $cfunc$1();],[$cfunc$1()])],
        [flink_try=yes],
        [if test x"$FLIBS" != x ; then
           flink_save_libs="$LIBS"
           LIBS="$LIBS $FLIBS"
           AC_LINK_IFELSE(
             [AC_LANG_PROGRAM([void $cfunc$1();],[$cfunc$1()])],
             [coin_need_flibs=yes
              flink_try=yes]
           )
           LIBS="$flink_save_libs"
         fi
        ]
      )
      ;;
    cc|cpp)
      coin_need_flibs=no
      flink_try=no
      AC_COIN_F77_FUNC($1,cfunc$1)
      AC_LINK_IFELSE(
        [AC_LANG_PROGRAM([extern "C" {void $cfunc$1();}],[$cfunc$1()])],
        [flink_try=yes],
        [if test x"$FLIBS" != x ; then
           flink_save_libs="$LIBS"
           LIBS="$LIBS $FLIBS"
           AC_LINK_IFELSE(
             [AC_LANG_PROGRAM([extern "C" {void $cfunc$1();}],[$cfunc$1()])],
             [coin_need_flibs=yes
              flink_try=yes]
           )
           LIBS="$flink_save_libs"
         fi
        ]
      )
      ;;
  esac
  if test $flink_try = yes ; then
    $2
  else
    $3
  fi
  # AC_MSG_NOTICE([Done COIN_TRY_FLINK])
]) # AC_COIN_TRY_FLINK


###########################################################################
#                       COIN_CHK_PKG_FLINK                                #
###########################################################################

# This is a helper macro, common code for checking if a library can be linked.
#   COIN_CHK_PKG_FLINK(varname,func,extra_libs)
# If func can be linked with extra_libs, varname is set to extra_libs,
# possibly augmented with $FLIBS if these are required. If func cannot be
# linked, varname is set to the null string.

AC_DEFUN([AC_COIN_CHK_PKG_FLINK],
[
  coin_save_LIBS="$LIBS"
  LIBS="$3 $LIBS"
  AC_COIN_TRY_FLINK([$2],
    [if test $coin_need_flibs = no ; then
       $1="$3"
     else
       $1="$3 $FLIBS"
     fi
     AC_MSG_RESULT([yes: $[]$1])],
    [$1=
     AC_MSG_RESULT([no])])
  LIBS="$coin_save_LIBS"
])

###########################################################################
#                         COIN_CHK_BLAS                                   #
###########################################################################

# COIN_CHK_BLAS([client packages],[nolinkcheck])

# This macro checks for a BLAS library and adds the information necessary to
# use it to the _LFLAGS, _CFLAGS, and _PCFILES variables of the client packages
# passed as a space-separated list in parameter $1. These correspond to
# Libs.private, Cflags.private, and Requires.private, respectively, in a .pc
# file.

# The algorithm first invokes FIND_PRIM_PKG. The parameters --with-blas,
# --with-blas-lflags, and --with-blas-cflags are interpreted there. If nothing
# is found, default locations are checked.

# When checking default locations, the macro uses a link check because it's
# really the only way to decide if a guess is correct. But a link check is
# always a good idea just in case FLIBS (Fortran intrinsic & runtime libraries)
# is also necessary. You can suppress the link check for a library spec given
# on the command line or obtained via a .pc file by adding `nolinkcheck' as $2.

AC_DEFUN([AC_COIN_CHK_BLAS],
[
  AC_REQUIRE([AC_COIN_PROG_F77])

  AC_MSG_CHECKING([for package BLAS])

# Make sure the necessary variables exist for each client package.

  m4_foreach_w([myvar],[$1],
    [AC_SUBST(m4_toupper(myvar)_LFLAGS)
     AC_SUBST(m4_toupper(myvar)_CFLAGS)
     AC_SUBST(m4_toupper(myvar)_PCFILES)
    ])

# Set up command line arguments with DEF_PRIM_ARGS and give FIND_PRIM_PKG
# a chance, just in case blas.pc exists. The result (coin_has_blas) will
# be one of yes (either the user specified something or pkgconfig found
# something), no (user specified nothing and pkgconfig found nothing) or
# skipping (user said do not use). We'll also have variables blas_lflags,
# blas_cflags, blas_data, and blas_pcfiles.

  AC_COIN_DEF_PRIM_ARGS([blas],yes,yes,yes,no)
  AC_COIN_FIND_PRIM_PKG([blas])

# If FIND_PRIM_PKG found something and the user wants a link check, do it. For
# a successful link check, update blas_libs just in case FLIBS was added.

  if test "$coin_has_blas" = yes ; then
    m4_if([$2],[nolinkcheck],[:],
      [use_blas=
       AC_COIN_CHK_PKG_FLINK([use_blas],[daxpy],[$blas_lflags])
       if test -n "$use_blas" ; then
         blas_lflags=$use_blas
       else
         AC_MSG_WARN([BLAS failed to link with "$blas_lflags"])
       fi])

# If FIND_PRIM_PKG didn't find anything, try a few guesses.  Try some
# specialised checks based on the host system type first.  If none of them
# are applicable, or the applicable one fails, try the generic -lblas.

  elif test "$coin_has_blas" = no ; then
    AC_MSG_RESULT([nothing yet])
    case $build in
      *-sgi-*) 
        AC_MSG_CHECKING([for BLAS in -lcomplib.sgimath])
        AC_COIN_CHK_PKG_FLINK([blas_lflags],[daxpy],[-lcomplib.sgimath])
        ;;

      *-*-solaris*)
        # Ideally, we'd use -library=sunperf, but it's an imperfect world.
        # Studio cc doesn't recognise -library, it wants -xlic_lib. Studio 12
        # CC doesn't recognise -xlic_lib. Libtool doesn't like -xlic_lib
        # anyway. Sun claims that CC and cc will understand -library in Studio
        # 13. The main extra function of -xlic_lib and -library is to arrange
        # for the Fortran run-time libraries to be linked for C++ and C. We
        # can arrange that explicitly.
        AC_MSG_CHECKING([for BLAS in -lsunperf])
        AC_COIN_CHK_PKG_FLINK([blas_lflags],[daxpy],[-lsunperf])
        ;;
        
      *-cygwin* | *-mingw*)
        case "$CC" in
          clang* ) ;;
          cl* | */cl* | CL* | */CL* | icl* | */icl* | ICL* | */ICL*)
            AC_MSG_CHECKING([for BLAS in MKL (32bit)])
            AC_COIN_CHK_PKG_FLINK([blas_lflags],[daxpy],
              [mkl_intel_c.lib mkl_sequential.lib mkl_core.lib])
            if test -z "$blas_lflags" ; then
              AC_MSG_CHECKING([for BLAS in MKL (64bit)])
              AC_COIN_CHK_PKG_FLINK([blas_lflags],[daxpy],
                [mkl_intel_lp64.lib mkl_sequential.lib mkl_core.lib])
            fi
            ;;
        esac
        ;;
        
       *-darwin*)
        AC_MSG_CHECKING([for BLAS in Veclib])
        AC_COIN_CHK_PKG_FLINK([blas_lflags],[daxpy],[-framework Accelerate])
        ;;
    esac
    if test -z "$blas_lflags" ; then
      AC_MSG_CHECKING([for BLAS in -lblas])
      AC_COIN_CHK_PKG_FLINK([blas_lflags],[daxpy],[-lblas])
    fi
    if test -n "$blas_lflags" ; then
      coin_has_blas=yes
    fi
  fi

# Done. Time to set some variables. Create an automake conditional
# COIN_HAS_BLAS.

  AM_CONDITIONAL(m4_toupper(COIN_HAS_BLAS),[test $coin_has_blas = yes])

# If we've located the package, define preprocessor symbol COIN_HAS_BLAS
# and augment the necessary variables for the client packages.

  if test $coin_has_blas = yes ; then
    AC_DEFINE(m4_toupper(COIN_HAS_BLAS),[1],
      [Define to 1 if BLAS is available.])
    m4_foreach_w([myvar],[$1],
      [m4_toupper(myvar)_PCFILES="$blas_pcfiles $m4_toupper(myvar)_PCFILES"
       m4_toupper(myvar)_LFLAGS="$blas_lflags $m4_toupper(myvar)_LFLAGS"
       m4_toupper(myvar)_CFLAGS="$blas_cflags $m4_toupper(myvar)_CFLAGS"
      ])
  else
    AC_MSG_RESULT([$coin_has_blas])
  fi

]) # AC_COIN_CHK_BLAS


###########################################################################
#                       COIN_CHK_LAPACK                                   #
###########################################################################

# COIN_CHK_LAPACK([client packages],[nolinkcheck])

# This macro checks for a LAPACK library and adds the information necessary to
# use it to the _LFLAGS, _CFLAGS, and _PCFILES variables of the client packages
# passed as a space-separated list in parameter $1. These correspond to
# Libs.private, Cflags.private, and Requires.private, respectively, in a .pc
# file.

# The algorithm first invokes FIND_PRIM_PKG. The parameters --with-lapack,
# --with-lapack-lflags, and --with-lapack-cflags are interpreted there. If
# nothing is found, default locations are checked.

# When checking default locations, the macro uses a link check because it's
# really the only way to decide if a guess is correct. But a link check is
# always a good idea just in case FLIBS (Fortran intrinsic & runtime libraries)
# is also necessary. You can suppress the link check for a library spec given
# on the command line or obtained via a .pc file by adding `nolinkcheck' as $2.

AC_DEFUN([AC_COIN_CHK_LAPACK_OLD],
[
  AC_REQUIRE([AC_COIN_PROG_F77])

  AC_MSG_CHECKING([for package LAPACK])

# Make sure the necessary variables exist for each client package.

  m4_foreach_w([myvar],[$1],
    [AC_SUBST(m4_toupper(myvar)_LIBS)
     AC_SUBST(m4_toupper(myvar)_CFLAGS)
     AC_SUBST(m4_toupper(myvar)_PCFILES)
    ])

# Set up command line arguments with DEF_PRIM_ARGS and give FIND_PRIM_PKG
# a chance, just in case lapack.pc exists. The result (coin_has_lapack)
# will be one of yes (either the user specified something or pkgconfig
# found something), no (user specified nothing and pkgconfig found nothing)
# or skipping (user said do not use). We'll also have variables lapack_lflags,
# lapack_cflags, lapack_data, and lapack_pcfiles.

  AC_COIN_DEF_PRIM_ARGS([lapack],yes,yes,yes,no)
  AC_COIN_FIND_PRIM_PKG([lapack])

# If FIND_PRIM_PKG found something and the user wants a link check, do it. For
# a successful link check, update lapack_lflags just in case FLIBS was added.

  if test "$coin_has_lapack" = yes ; then
    m4_if([$2],[nolinkcheck],[:],
      [use_lapack=
       AC_COIN_CHK_PKG_FLINK([use_lapack],[daxpy],[$lapack_lflags])
       if test -n "$use_lapack" ; then
         lapack_lflags=$use_lapack
       else
         AC_MSG_WARN([LAPACK failed to link with "$lapack_lflags"])
       fi])

# If FIND_PRIM_PKG didn't find anything, try a few guesses. First, try some
# specialised checks based on the host system type. If none of them are
# applicable, or the applicable one fails, try the generic -llapack.

  elif test "$coin_has_lapack" = no ; then
    AC_MSG_RESULT([nothing yet])
    case $build in
      *-sgi-*) 
        AC_MSG_CHECKING([for LAPACK in -lcomplib.sgimath])
        AC_COIN_CHK_PKG_FLINK([lapack_lflags],[dsyev],[-lcomplib.sgimath])
        ;;

      *-*-solaris*)
        # See comments in COIN_CHK_PKG_BLAS.
        AC_MSG_CHECKING([for LAPACK in -lsunperf])
        AC_COIN_CHK_PKG_FLINK([lapack_lflags],[dsyev],[-lsunperf])
        ;;

        # On cygwin, do this check only if doscompile is disabled. The
        # prebuilt library will want to link with cygwin, hence won't run
        # standalone in DOS.

    esac
    if test -z "$lapack_lflags" ; then
      AC_MSG_CHECKING([for LAPACK in -llapack])
      AC_COIN_CHK_PKG_FLINK([lapack_lflags],[dsyev],[-llapack])
    fi
    if test -n "$lapack_lflags" ; then
      coin_has_lapack=yes
    fi
  fi

# Done. Time to set some variables. Create an automake conditional
# COIN_HAS_LAPACK.

  AM_CONDITIONAL(m4_toupper(COIN_HAS_LAPACK),[test $coin_has_lapack = yes])

# If we've located the package, define preprocessor symbol COIN_HAS_LAPACK
# and augment the necessary variables for the client packages.

  if test $coin_has_lapack = yes ; then
    AC_DEFINE(m4_toupper(COIN_HAS_LAPACK),[1],
      [Define to 1 if the LAPACK package is available])
    m4_foreach_w([myvar],[$1],
      [m4_toupper(myvar)_PCFILES="$lapack_pcfiles $m4_toupper(myvar)_PCFILES"
       m4_toupper(myvar)_LFLAGS="$lapack_lflags $m4_toupper(myvar)_LFLAGS"
       m4_toupper(myvar)_CFLAGS="$lapack_cflags $m4_toupper(myvar)_CFLAGS"
      ])
  else
    AC_MSG_RESULT([$coin_has_lapack])
  fi

]) # AC_COIN_CHK_LAPACK

