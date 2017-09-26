
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
  AC_MSG_NOTICE([In COIN_PROG_F77])
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
  AC_MSG_NOTICE([Leaving COIN_PROG_F77])
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
  AC_MSG_NOTICE([In COIN_F77_SETUP])

# F77_WRAPPERS will trigger the necessary F77 setup macros (F77_MAIN,
# F77_LIBRARY_LDFLAGS, etc.)

  AC_F77_WRAPPERS
  AC_PROG_F77_C_O
  if test $ac_cv_prog_f77_c_o = no ; then
    F77="$am_aux_dir/compile $F77"
  fi
  AC_MSG_NOTICE([Leaving COIN_F77_SETUP])
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
    [AC_LANG_PUSH([C++])
     ac_save_LIBS=$LIBS
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
	     [AC_LANG_PROGRAM([extern "C" {void $ac_name();}],[$ac_name()])],
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
       AC_MSG_WARN([Unable to determine correct Fortran name-mangling scheme])
     fi
     LIBS=$ac_save_LIBS
     AC_LANG_POP([C++])])

# Invoke the second-level internal autoconf macro _AC_FC_WRAPPERS to give the
# functionality of AC_F77_WRAPPERS.

  if test "$ac_cv_f77_mangling" != unknown ; then
    AC_LANG_PUSH([Fortran 77])
    _AC_FC_WRAPPERS
    AC_LANG_POP([Fortran 77])
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
	[if test x"$FLIBS" != x; then
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
	[if test x"$FLIBS" != x; then
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
  if test $flink_try = yes; then
    $2
  else
    $3
  fi
  # AC_MSG_NOTICE([Done COIN_TRY_FLINK])
]) # AC_COIN_TRY_FLINK

