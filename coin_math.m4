# Copyright (C) 2017-2020 COIN-OR Foundation
# All Rights Reserved.
# This file is distributed under the Eclipse Public License 2.0.
# See LICENSE for details.

###########################################################################
#                     Math Utility Macros                                 #
###########################################################################
# Evolution of C/C++ standards says that in general we should prefer header
# file cxxx over header file xxx.h and function name std:xxx() over function
# name xxx(). Sadly, evolution of C/C++ standards also leaves considerable
# ambiguity: cxxx must provide functions in the std namespace and is allowed
# but not required to provide them in the global namespace. xxx.h must provide
# functions in the global namespace and is allowed but not required to provide
# them in the std namespace.

# When testing for std::xxx, we may need to supply one or more parameters, yyy,
# for overload resolution.  As an added complication, the standard CHECK_DECL
# macro will generate a line of the form #ifndef <arg>. If <arg> happens
# to be std::xxx or std::xxx(yyy), the resulting '#ifndef std::xxx(yyy)'
# is not legal syntax.
###########################################################################


###########################################################################
#                     COIN_MATH_INCLUDES                                  #
###########################################################################
# Utility macro to avoid having to replicate this code snippet in far too
# many places.
###########################################################################

AC_DEFUN([AC_COIN_MATH_HDRS],
[
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
  #endif
])

###########################################################################
#                   COIN_CHECK_MATH_HEADERS                               #
###########################################################################
# Utility macro to look for standard math headers. As a separate macro
# this can be REQUIRED, hence it runs only once. For a header file cxxx,
# the macro will define preprocessor symbol HAVE_CXXX and cache variable
# ac_cv_header_cxxx. For xxx.h, HAVE_XXX_H and ac_cv_header_xxx_h. For each
# call to CHECK_HEADERS, search stops with the first header that's found.
###########################################################################

AC_DEFUN([AC_COIN_CHECK_MATH_HDRS],
[
  AC_CHECK_HEADERS([cmath math.h],[break],[])
  AC_CHECK_HEADERS([cfloat float.h],[break],[])
  AC_CHECK_HEADERS([cieeefp ieeefp.h],[break],[])
])


###########################################################################
#                   COIN_CHECK_NAMESPACE_DECL                             #
###########################################################################
#
# CHECK_NAMESPACE_DECL(symbol,[params],[action-if-found],[action-if-not-found],
#                      [includes = 'AC_INCLUDES_DEFAULT'])
#
# Like AC_CHECK_DECL, but will generate a syntactically valid check for a
# symbol xxx declared in a namespace nnn (i.e., `nnn::xxx'). The optional
# params can be specified if needed for overload resolution of the symbol. For
# example, to check for an overload of std::isfinite that takes a float as
# a parameter, CHECK_NAMESPACE_DECL([std::isfinite],[1.0], ....).
###########################################################################

AC_DEFUN([AC_COIN_CHECK_NAMESPACE_DECL],
[
  AC_LANG_ASSERT(C++)

  AC_MSG_CHECKING(for $1)
  AC_COMPILE_IFELSE(
    [AC_LANG_SOURCE(
      m4_ifblank([$5],[AC_INCLUDES_DEFAULT],[$5])
      int main ()
      { (void) m4_ifblank([$2],[$1],[$1($2)]) ;
        return 0 ; }
    )],
    [$3
     AC_MSG_RESULT(yes)],
    [$4
     AC_MSG_RESULT(no)])
])


###########################################################################
#                   COIN_CHECK_ISFINITE                                   #
###########################################################################
# This macro checks for a usable implementation of a function to check if a
# floating point value is finite or not. If a function is found, the macro
# defines the preprocessor symbol COIN_C_FINITE to the name of this function.
###########################################################################

AC_DEFUN([AC_COIN_CHECK_ISFINITE],
[
  AC_REQUIRE([AC_COIN_CHECK_MATH_HDRS])

  COIN_C_FINITE=

  AC_COIN_CHECK_NAMESPACE_DECL([std::isfinite],[1.0],
      [COIN_C_FINITE=std::isfinite],[],
      AC_COIN_MATH_HDRS)

  if test -z "$COIN_C_FINITE"; then
    for fname in isfinite finite _finite ; do
      AC_CHECK_DECL([$fname],[COIN_C_FINITE=$fname],,AC_COIN_MATH_HDRS)
      if test -n "$COIN_C_FINITE" ; then
        break
      fi
    done
  fi

  if test -z "$COIN_C_FINITE"; then
    AC_MSG_WARN(Cannot find C-function for checking Inf.)
  else
    AC_DEFINE_UNQUOTED(m4_toupper(AC_PACKAGE_NAME)_C_FINITE,[$COIN_C_FINITE],[Define to be the name of C-function for Inf check])
  fi
])

###########################################################################
#                              COIN_CHECK_ISNAN                           #
###########################################################################
# This macro checks for a usable implementation of a function to check if
# a floating point value is not a number (NaN).  If a function is found,
# the macro defines the preprocessor symbol COIN_C_ISNAN to the name of
# this function.
###########################################################################

AC_DEFUN([AC_COIN_CHECK_ISNAN],
[
  AC_REQUIRE([AC_COIN_CHECK_MATH_HDRS])

  COIN_C_ISNAN=

  AC_COIN_CHECK_NAMESPACE_DECL([std::isnan],[1.0],
      [COIN_C_ISNAN=std::isnan],[],
      AC_COIN_MATH_HDRS)

  if test -z "$COIN_C_ISNAN"; then
    for fname in isnan _isnan isnand ; do
      AC_CHECK_DECL([$fname],[COIN_C_ISNAN=$fname],,AC_COIN_MATH_HDRS)
      if test -z "$COIN_C_ISNAN"; then
        break
      fi
    done
  fi

  if test -z "$COIN_C_ISNAN"; then
    AC_MSG_WARN(Cannot find C-function for checking NaN.)
  else
    AC_DEFINE_UNQUOTED(m4_toupper(AC_PACKAGE_NAME)_C_ISNAN,[$COIN_C_ISNAN],[Define to be the name of C-function for NaN check])
  fi
])

