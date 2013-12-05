# Copyright (C) 2013
# All Rights Reserved.
# This file is distributed under the Eclipse Public License.
#
# This file defines the common autoconf macros for COIN-OR
#

# Check requirements
AC_PREREQ(2.69)


###########################################################################
#                            COIN_CHECK_ISFINITE                          #
###########################################################################

# This macro checks for a usable implementation of a function to check
# whether a given floating point number is finite.
# If a function is found, then the macro defines the symbol
# toupper($1)_C_FINITE to the name of this function.

AC_DEFUN([AC_COIN_CHECK_ISFINITE],[

AC_LANG_PUSH(C++)

#AC_COIN_CHECK_CXX_CHEADER(math)
#AC_COIN_CHECK_CXX_CHEADER(float)
#AC_COIN_CHECK_CXX_CHEADER(ieeefp)
AC_CHECK_HEADERS([cmath])
if test "$ac_cv_header_cmath" != "yes"; then
  AC_CHECK_HEADERS([math.h])
fi
AC_CHECK_HEADERS([cfloat])
if test "$ac_cv_header_cfloat" != "yes"; then
  AC_CHECK_HEADERS([float.h])
fi
AC_CHECK_HEADERS([cieeefp])
if test "$ac_cv_header_cieeefp" != "yes"; then
  AC_CHECK_HEADERS([ieeefp.h])
fi

COIN_C_FINITE=
AC_CHECK_DECL([isfinite],[COIN_C_FINITE=isfinite],,[
#ifdef HAVE_CMATH
# include <cmath>
#else
# ifdef HAVE_MATH_H
#  include <math.h>
# endif
#endif
#ifdef HAVE_CFLOAT
# include <cfloat>
#else
# ifdef HAVE_FLOAT_H
#  include <float.h>
# endif
#endif
#ifdef HAVE_CIEEEFP
# include <cieeefp>
#else
# ifdef HAVE_IEEEFP_H
#  include <ieeefp.h>
# endif
#endif])
if test -z "$COIN_C_FINITE"; then
  AC_CHECK_DECL([finite],[COIN_C_FINITE=finite],,[
#ifdef HAVE_CMATH
# include <cmath>
#else
# ifdef HAVE_MATH_H
#  include <math.h>
# endif
#endif
#ifdef HAVE_CFLOAT
# include <cfloat>
#else
# ifdef HAVE_FLOAT_H
#  include <float.h>
# endif
#endif
#ifdef HAVE_CIEEEFP
# include <cieeefp>
#else
# ifdef HAVE_IEEEFP_H
#  include <ieeefp.h>
# endif
#endif])
  if test -z "$COIN_C_FINITE"; then
    AC_CHECK_DECL([_finite],[COIN_C_FINITE=_finite],,[
#ifdef HAVE_CMATH
# include <cmath>
#else
# ifdef HAVE_MATH_H
#  include <math.h>
# endif
#endif
#ifdef HAVE_CFLOAT
# include <cfloat>
#else
# ifdef HAVE_FLOAT_H
#  include <float.h>
# endif
#endif
#ifdef HAVE_CIEEEFP
# include <cieeefp>
#else
# ifdef HAVE_IEEEFP_H
#  include <ieeefp.h>
# endif
#endif])
  fi
fi
if test -z "$COIN_C_FINITE"; then
  AC_MSG_WARN(Cannot find C-function for checking Inf.)
else
  AC_DEFINE_UNQUOTED(COIN_C_FINITE,[$COIN_C_FINITE],
                     [Define to be the name of C-function for Inf check])
fi

AC_LANG_POP(C++)
])

###########################################################################
#                              COIN_CHECK_ISNAN                           #
###########################################################################

# This macro checks for a usable implementation of a function to check
# whether a given floating point number represents NaN.
# If a function is found, then the macro defines the symbol COIN_C_ISNAN
# to the name of this function.

AC_DEFUN([AC_COIN_CHECK_ISNAN],[

AC_LANG_PUSH(C++)

#AC_COIN_CHECK_CXX_CHEADER(math)
#AC_COIN_CHECK_CXX_CHEADER(float)
#AC_COIN_CHECK_CXX_CHEADER(ieeefp)
AC_CHECK_HEADERS([cmath])
if test "$ac_cv_header_cmath" != "yes"; then
  AC_CHECK_HEADERS([math.h])
fi
AC_CHECK_HEADERS([cfloat])
if test "$ac_cv_header_cfloat" != "yes"; then
  AC_CHECK_HEADERS([float.h])
fi
AC_CHECK_HEADERS([cieeefp])
if test "$ac_cv_header_cieeefp" != "yes"; then
  AC_CHECK_HEADERS([ieeefp.h])
fi

COIN_C_ISNAN=
AC_CHECK_DECL([isnan],[COIN_C_ISNAN=isnan],,[
#ifdef HAVE_CMATH
# include <cmath>
#else
# ifdef HAVE_MATH_H
#  include <math.h>
# endif
#endif
#ifdef HAVE_CFLOAT
# include <cfloat>
#else
# ifdef HAVE_FLOAT_H
#  include <float.h>
# endif
#endif
#ifdef HAVE_CIEEEFP
# include <cieeefp>
#else
# ifdef HAVE_IEEEFP_H
#  include <ieeefp.h>
# endif
#endif])

# It appears that for some systems (e.g., Mac OSX), cmath will provide only
# std::isnan, and bare isnan will be unavailable. Typically we need a parameter
# in the test to allow C++ to do overload resolution.
# With newer autoconf, this parameter now gets interpreted as a typecast.

if test -z "$COIN_C_ISNAN"; then
  AC_CHECK_DECL([std::isnan(double)],[COIN_C_ISNAN=std::isnan],,[
#ifdef HAVE_CMATH
# include <cmath>
#else
# ifdef HAVE_MATH_H
#  include <math.h>
# endif
#endif
#ifdef HAVE_CFLOAT
# include <cfloat>
#else
# ifdef HAVE_FLOAT_H
#  include <float.h>
# endif
#endif
#ifdef HAVE_CIEEEFP
# include <cieeefp>
#else
# ifdef HAVE_IEEEFP_H
#  include <ieeefp.h>
# endif
#endif])
fi

if test -z "$COIN_C_ISNAN"; then
  AC_CHECK_DECL([_isnan],[COIN_C_ISNAN=_isnan],,[
#ifdef HAVE_CMATH
# include <cmath>
#else
# ifdef HAVE_MATH_H
#  include <math.h>
# endif
#endif
#ifdef HAVE_CFLOAT
# include <cfloat>
#else
# ifdef HAVE_FLOAT_H
#  include <float.h>
# endif
#endif
#ifdef HAVE_CIEEEFP
# include <cieeefp>
#else
# ifdef HAVE_IEEEFP_H
#  include <ieeefp.h>
# endif
#endif])
fi
if test -z "$COIN_C_ISNAN"; then
  AC_CHECK_DECL([isnand],[COIN_C_ISNAN=isnand],,[
#ifdef HAVE_CMATH
# include <cmath>
#else
# ifdef HAVE_MATH_H
#  include <math.h>
# endif
#endif
#ifdef HAVE_CFLOAT
# include <cfloat>
#else
# ifdef HAVE_FLOAT_H
#  include <float.h>
# endif
#endif
#ifdef HAVE_CIEEEFP
# include <cieeefp>
#else
# ifdef HAVE_IEEEFP_H
#  include <ieeefp.h>
# endif
#endif])
fi
if test -z "$COIN_C_ISNAN"; then
  AC_MSG_WARN(Cannot find C-function for checking NaN.)
else
  AC_DEFINE_UNQUOTED(COIN_C_ISNAN,[$COIN_C_ISNAN],
                     [Define to be the name of C-function for NaN check])
fi

AC_LANG_POP(C++)
])

###########################################################################
#                          COIN_EXAMPLE_FILES                             #
###########################################################################

# This macro determines the names of the example files (using the
# argument in an "ls" command) and sets up the variables EXAMPLE_FILES
# and EXAMPLE_CLEAN_FILES.  If this is a VPATH configuration, it also
# creates soft links to the example files.

AC_DEFUN([AC_COIN_EXAMPLE_FILES],
[
#AC_REQUIRE([AC_COIN_CHECK_VPATH])
#AC_REQUIRE([AC_COIN_ENABLE_MSVC])
#AC_REQUIRE([AC_PROG_LN_S])

files=`cd $srcdir; ls $1`
# We need to do the following loop to make sure that there are no newlines
# in the variable
for file in $files; do
  EXAMPLE_FILES="$EXAMPLE_FILES $file"
  # using AC_CONFIG_LINKS is much simpler here, but due to a bug
  # in autoconf (even latest autoconf), the AC_COIN_EXAMPLE_FILES
  # macro can only be called once if the links are made this way
  # (otherwise autoconf thinks $file is a duplicate...)
  AC_CONFIG_LINKS([$file:$file])
done

# potentially add some of this back as needed:
#if test $coin_vpath_config = yes; then
#  lnkcmd=
#  if test "$enable_msvc" != no; then
#    lnkcmd=cp
#  fi
#  case "$CC" in
#    clang* ) ;;
#    cl* | */cl* | CL* | */CL* | icl* | */icl* | ICL* | */ICL*)
#      lnkcmd=cp ;;
#  esac
#  if test "x$lnkcmd" = xcp; then
#    AC_MSG_NOTICE([Copying example files ($1)])
#  else
#    AC_MSG_NOTICE([Creating links to the example files ($1)])
#    lnkcmd="$LN_S"
#  fi
#  for file in $EXAMPLE_FILES; do
#    rm -f $file
#    $lnkcmd $srcdir/$file $file
#  done
#  EXAMPLE_CLEAN_FILES="$EXAMPLE_CLEAN_FILES $1"
#else
#  EXAMPLE_CLEAN_FILES="$EXAMPLE_CLEAN_FILES"
#fi
#
# In case there are compressed files, we create a variable with the
# uncompressed names
#EXAMPLE_UNCOMPRESSED_FILES=
#for file in $EXAMPLE_FILES; do
#  case $file in
#    *.gz)
#      EXAMPLE_UNCOMPRESSED_FILES="$EXAMPLE_UNCOMPRESSED_FILES `echo $file | sed -e s/.gz//`"
#      ;;
#  esac
#done
#
#AC_SUBST(EXAMPLE_UNCOMPRESSED_FILES)
#AC_SUBST(EXAMPLE_FILES)
#AC_SUBST(EXAMPLE_CLEAN_FILES)
]) #AC_COIN_EXAMPLE_FILES

