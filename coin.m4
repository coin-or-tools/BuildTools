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

if test -z "$COIN_C_ISNAN"; then
  AC_CHECK_DECL([std::isnan(42.42)],[COIN_C_ISNAN=std::isnan],,[
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
