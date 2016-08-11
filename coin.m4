# Copyright (C) 2013-2016
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
AC_SUBST(EXAMPLE_FILES)
#AC_SUBST(EXAMPLE_CLEAN_FILES)
]) #AC_COIN_EXAMPLE_FILES


###########################################################################
#                          COIN_PROJECTVERSION                            #
###########################################################################

# This macro is used by COIN_PROJECTDIR_INIT and sets up variables related
# to versioning numbers of the project.

AC_DEFUN([AC_COIN_PROJECTVERSION],
[m4_ifvaln([$1],[
  AC_DEFINE_UNQUOTED(m4_toupper($1_VERSION), ["$PACKAGE_VERSION"],[Version number of project])
  
  [coin_majorver=`echo $PACKAGE_VERSION | sed -n -e 's/^\([0-9]*\).*/\1/gp'`]
  [coin_minorver=`echo $PACKAGE_VERSION | sed -n -e 's/^[0-9]*\.\([0-9]*\).*/\1/gp'`]
  [coin_releasever=`echo $PACKAGE_VERSION | sed -n -e 's/^[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/gp'`]
  test -z "$coin_majorver"   && coin_majorver=9999
  test -z "$coin_minorver"   && coin_minorver=9999
  test -z "$coin_releasever" && coin_releasever=9999
  AC_DEFINE_UNQUOTED(m4_toupper($1_VERSION_MAJOR),   [$coin_majorver],   [Major Version number of project])
  AC_DEFINE_UNQUOTED(m4_toupper($1_VERSION_MINOR),   [$coin_minorver],   [Minor Version number of project])
  AC_DEFINE_UNQUOTED(m4_toupper($1_VERSION_RELEASE), [$coin_releasever], [Release Version number of project])

  # We use the following variable to have a string with the upper case
  # version of the project name
  COIN_PRJCT=m4_toupper($1)

  # Set the project's SVN revision number. The complicated sed expression
  # (made worse by quadrigraphs) ensures that things like 4123:4168MS end up
  # as a single number.
  AC_CHECK_PROG([have_svnversion],[svnversion],[yes],[no])
  if test "x$have_svnversion" = xyes; then
    AC_SUBST(m4_toupper($1_SVN_REV))
    svn_rev_tmp=`LANG=en_EN svnversion $srcdir 2>/dev/null`
    if test "x$svn_rev_tmp" != xexported -a "x$svn_rev_tmp" != x -a "x$svn_rev_tmp" != "xUnversioned directory"; then
      m4_toupper($1_SVN_REV)=`echo $svn_rev_tmp | sed -n -e 's/^@<:@0-9@:>@*://' -e 's/\(@<:@0-9@:>@\)@<:@^0-9@:>@*$/\1/p'`
      AC_DEFINE_UNQUOTED(m4_toupper($1_SVN_REV), $m4_toupper($1_SVN_REV), [SVN revision number of project])
    fi
  fi
 ])
 
# Capture libtool library version, if given.
 m4_ifvaln([$2],[coin_libversion=$2],[])
])

###########################################################################
#                            COIN_INITALIZE                               #
###########################################################################

# This macro does everything that is required in the early part in the
# configure script, such as defining a few variables.
# The first parameter is the project name.
# The second (optional) is the libtool library version (important for releases,
# less so for stable or trunk).

AC_DEFUN([AC_COIN_INITIALIZE],
[
# required autoconf version
AC_PREREQ(2.69)

# Set the project's version numbers
AC_COIN_PROJECTVERSION($1, $2)

# A useful makefile conditional that is always false
AM_CONDITIONAL(ALWAYS_FALSE, false)

# Where should everything be installed by default?  Here, we want it
# to be installed directly in 'bin', 'lib', 'include' subdirectories
# of the directory where configure is run.  The default would be
# /usr/local.      
AC_PREFIX_DEFAULT([`pwd`])

# Get the system type
AC_CANONICAL_BUILD

# initialize automake, don't define PACKAGE or VERSION
# TODO should we enable warnings by passing an option like -Wall
AM_INIT_AUTOMAKE([no-define])

# disable automatic rebuild of configure/Makefile
AM_MAINTAINER_MODE

# create libtool
AC_PROG_LIBTOOL
])

###########################################################################
#                              COIN_FINALIZE                              #
###########################################################################

# This macro should be called at the very end of the configure.ac file.
# It creates the output files (by using AC_OUTPUT), and might do some other
# things (such as generating links to data files in a VPATH configuration).
# It also prints the "success" message.
# Note: If the variable coin_skip_ac_output is set to yes, then no output
# files are written.

AC_DEFUN([AC_COIN_FINALIZE],
[
AC_OUTPUT

AC_MSG_NOTICE([In case of trouble, first consult the troubleshooting page at https://projects.coin-or.org/BuildTools/wiki/user-troubleshooting])
AC_MSG_NOTICE([Configuration of $PACKAGE_NAME successful])

]) #AC_COIN_FINALIZE


###########################################################################
#                           COIN_HAS_PKGCONFIG                            #
###########################################################################

# This macro checks whether a pkg-config tool with a minimal version number
# is available.  If so, then the variable PKGCONFIG is set to its path.
# If not, PKGCONFIG is set to "".  The minimal version number can be given
# as first parameter, by default it is 0.16.0, since COIN-OR .pc files now
# include an URL field, which breaks pkg-config version <= 0.15.
# This macro is a modified version of PKG_PROG_PKG_CONFIG in pkg.m4.
# Further, the AM_CONDITIONAL COIN_HAS_PKGCONFIG is set and PKGCONFIG is
# AC_SUBST'ed.  Finally, the search path for .pc files is assembled from the
# value of $prefix and $PKG_CONFIG_PATH in a variable COIN_PKG_CONFIG_PATH,
# which is also AC_SUBST'ed.

AC_DEFUN([AC_COIN_HAS_PKGCONFIG],
[AC_ARG_VAR([PKG_CONFIG], [path to pkg-config utility])

AC_ARG_ENABLE([pkg-config],
  [AC_HELP_STRING([--disable-pkg-config],[disable use of pkg-config (if available)])],
  [use_pkgconfig="$enableval"],
  [#if test x$coin_cc_is_cl = xtrue; then
   #  use_pkgconfig=no
   #else
     use_pkgconfig=yes
   #fi
  ])

if test $use_pkgconfig = yes ; then
  if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
    AC_CHECK_TOOL([PKG_CONFIG], [pkg-config])
  fi
  if test -n "$PKG_CONFIG"; then
    _pkg_min_version=m4_default([$1], [0.16.0])
    AC_MSG_CHECKING([pkg-config is at least version $_pkg_min_version])
    if $PKG_CONFIG --atleast-pkgconfig-version $_pkg_min_version; then
      AC_MSG_RESULT([yes])
    else
      AC_MSG_RESULT([no])
      PKG_CONFIG=""
    fi
  fi

  # check if pkg-config supports the short-errors flag
  if test -n "$PKG_CONFIG" && \
    $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
    pkg_short_errors=" --short-errors "
  else
    pkg_short_errors=""
  fi
fi

AM_CONDITIONAL([COIN_HAS_PKGCONFIG], [test -n "$PKG_CONFIG"])
AC_SUBST(PKG_CONFIG)

# assemble pkg-config search path
COIN_PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
AC_SUBST(COIN_PKG_CONFIG_PATH)

# let's assume that when installing into $prefix, then the user may have installed some other coin projects there before, so it's worth to have a look into there
# best would actually to use ${libdir}, since .pc files get installed into ${libdir}/pkgconfig,
# unfortunately, ${libdir} expands to ${exec_prefix}/lib and ${exec_prefix} to ${prefix}...
if test "x${prefix}" = xNONE ; then
  COIN_PKG_CONFIG_PATH="${ac_default_prefix}/lib64/pkgconfig:${ac_default_prefix}/lib/pkgconfig:${ac_default_prefix}/share/pkgconfig:${COIN_PKG_CONFIG_PATH}"
else
  COIN_PKG_CONFIG_PATH="${prefix}/lib64/pkgconfig:${prefix}/lib/pkgconfig:${prefix}/share/pkgconfig:${COIN_PKG_CONFIG_PATH}"
fi

])


###########################################################################
#                           COIN_PKG_CHECK_MODULE_EXISTS                  #
###########################################################################

# COIN_PKG_CHECK_MODULES_EXISTS(MODULE, PACKAGES, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#
# Check to see whether a particular set of packages exists.
# Similar to PKG_CHECK_MODULES(), but set only the variable $1_VERSIONS and $1_PKG_ERRORS
#
AC_DEFUN([AC_COIN_PKG_CHECK_MODULE_EXISTS],
[AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])
if test -n "$PKG_CONFIG" ; then
  if $PKG_CONFIG --exists "$2"; then
    m4_toupper($1)[]_VERSIONS=`$PKG_CONFIG --modversion "$2" 2>/dev/null | tr '\n' ' '`
    $3
  else
    m4_toupper($1)_PKG_ERRORS=`$PKG_CONFIG $pkg_short_errors --errors-to-stdout --print-errors "$2"`
    $4
  fi
else
  AC_MSG_ERROR("Cannot check for existance of module $1 without pkg-config")
fi
])

###########################################################################
#                            COIN_CHECK_PACKAGE                           #
###########################################################################

AC_DEFUN([AC_COIN_CHECK_PACKAGE],
[AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])
AC_MSG_CHECKING([for COIN-OR package $1])

m4_tolower(coin_has_$1)=notGiven

# check if user wants to skip package in any case
if test x"$COIN_SKIP_PROJECTS" != x; then
  for dir in $COIN_SKIP_PROJECTS; do
    if test $dir = "$1"; then
      m4_tolower(coin_has_$1)=skipping
    fi
  done
fi

if test "$m4_tolower(coin_has_$1)" != skipping; then
  AC_ARG_WITH([m4_tolower($1)],,
    [if test "$withval" = no ; then
       m4_tolower(coin_has_$1)=skipping
     fi
    ])
fi

m4_toupper($1_LIBS)=
m4_toupper($1_CFLAGS)=
m4_toupper($1_DATA)=
m4_toupper($1_PCREQUIRES)=
AC_SUBST(m4_toupper($1_LIBS))
AC_SUBST(m4_toupper($1_CFLAGS))
AC_SUBST(m4_toupper($1_DATA))
m4_foreach_w([myvar], [$3], [
  AC_SUBST(m4_toupper(myvar)_LIBS)
  AC_SUBST(m4_toupper(myvar)_CFLAGS)
  AC_SUBST(m4_toupper(myvar)_PCREQUIRES)
])

#check if user provided LIBS for package or disables use of package
if test $m4_tolower(coin_has_$1) != skipping; then
  AC_ARG_WITH([m4_tolower($1)-lib],
    AC_HELP_STRING([--with-m4_tolower($1)-lib],
                   [linker flags for using package $1]),
    [if test "$withval" = no ; then
       m4_tolower(coin_has_$1)=skipping
     else
       m4_tolower(coin_has_$1)=yes
       m4_toupper($1_LIBS)="$withval"
       m4_foreach_w([myvar], [$3], [
         m4_toupper(myvar)_LIBS="$withval $m4_toupper(myvar)_LIBS"
       ])
     fi
    ],
    [])
fi

#check if user provided INCDIR for package or disables use of package
if test $m4_tolower(coin_has_$1) != skipping; then
  AC_ARG_WITH([m4_tolower($1)-incdir],
    AC_HELP_STRING([--with-m4_tolower($1)-incdir],
                   [directory with header files for using package $1]),
    [if test "$withval" = no ; then
       m4_tolower(coin_has_$1)=skipping
     else
       m4_tolower(coin_has_$1)=yes
       m4_toupper($1_CFLAGS)="-I$withval"
       m4_foreach_w([myvar], [$3], [m4_toupper(myvar)_CFLAGS="-I$withval $m4_toupper(myvar)_CFLAGS"])
     fi
    ],
    [])
fi

#check if user provided DATADIR for package or disables use of package
if test $m4_tolower(coin_has_$1) != skipping; then
  AC_ARG_WITH([m4_tolower($1)-datadir],
    AC_HELP_STRING([--with-m4_tolower($1)-datadir],
                   [directory with data files for using package $1]),
    [if test "$withval" = no ; then
       m4_tolower(coin_has_$1)=skipping
     else
       m4_tolower(coin_has_$1)=yes
       m4_toupper($1_DATA)="$withval"
     fi
    ],
    [])
fi

# now use pkg-config, if nothing of the above applied
if test $m4_tolower(coin_has_$1) = notGiven; then
  if test -n "$PKG_CONFIG" ; then
    
    # let pkg-config do it's magic
    AC_COIN_PKG_CHECK_MODULE_EXISTS([$1],[$2],
      [ m4_tolower(coin_has_$1)=yes
        AC_MSG_RESULT([yes: $m4_toupper($1)_VERSIONS])

        m4_toupper($1_DATA)=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --variable=datadir $2 2>/dev/null`
        
        m4_toupper($1_PCREQUIRES)="$2"
        # augment X_PCREQUIRES for each build target X in $3
        m4_foreach_w([myvar], [$3], [
          m4_toupper(myvar)_PCREQUIRES="$2 $m4_toupper(myvar)_PCREQUIRES"
        ])
      ],
      [ m4_tolower(coin_has_$1)=notGiven
        AC_MSG_RESULT([not given: $m4_toupper($1)_PKG_ERRORS])
      ])

    m4_foreach_w([myvar], [$3], [
      m4_toupper(myvar)_PCREQUIRES="$2 $m4_toupper(myvar)_PCREQUIRES"
    ])

  else
    AC_MSG_ERROR([skipped check via pkg-config, redirect to fallback... -- oops, not there yet])
    # TODO
    #AC_COIN_CHECK_PACKAGE_FALLBACK([$1], [$2], [$3])
  fi

else
  AC_MSG_RESULT([$m4_tolower(coin_has_$1)])
fi

if test $m4_tolower(coin_has_$1) != skipping &&
   test $m4_tolower(coin_has_$1) != notGiven ; then
  AC_DEFINE(m4_toupper(COIN_HAS_$1),[1],[Define to 1 if the $1 package is available])
  
  if test 1 = 0 ; then  #change this test to enable a bit of debugging output
    if test -n "$m4_toupper($1)_DATA" ; then
      AC_MSG_NOTICE([$1 DATA   is  $m4_toupper($1)_DATA])
    fi
    if test -n "$m4_toupper($1)_PCREQUIRES" ; then
      AC_MSG_NOTICE([$1 PCREQUIRES are $m4_toupper($1)_PCREQUIRES])
    fi
  fi
  
fi

# Define the Makefile conditional
AM_CONDITIONAL(m4_toupper(COIN_HAS_$1),
               [test $m4_tolower(coin_has_$1) != notGiven &&
                test $m4_tolower(coin_has_$1) != skipping])
])

###########################################################################
#                           COIN_FINALIZE_FLAGS                           #
###########################################################################

# TODO this could be moved into COIN_FINALIZE, if we were able to remember
#   for which variables we need to run pkg-config
AC_DEFUN([AC_COIN_FINALIZE_FLAGS],[

# do pkg-config calls to complete LIBS and CFLAGS
m4_foreach_w([myvar],[$1],[
  if test -n "${m4_toupper(myvar)_PCREQUIRES}" ; then
    temp_CFLAGS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --cflags ${m4_toupper(myvar)_PCREQUIRES}`
    temp_LIBS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --libs ${m4_toupper(myvar)_PCREQUIRES}`
    m4_toupper(myvar)_CFLAGS="$temp_CFLAGS ${m4_toupper(myvar)_CFLAGS}"
    m4_toupper(myvar)_LIBS="$temp_LIBS ${m4_toupper(myvar)_LIBS}"
  fi

  if test 1 = 0 ; then  #change this test to enable a bit of debugging output
    if test -n "${m4_toupper(myvar)_CFLAGS}" ; then
      AC_MSG_NOTICE([myvar CFLAGS are ${m4_toupper(myvar)_CFLAGS}])
    fi
    if test -n "${m4_toupper(myvar)_LIBS}" ; then
      AC_MSG_NOTICE([myvar LIBS   are ${m4_toupper(myvar)_LIBS}])
    fi
  fi
])

])


###########################################################################
#                            COIN_TRY_FLINK                               #
###########################################################################

# Auxilliary macro to test if a Fortran function name can be linked,
# given the current settings of LIBS.  We determine from the context, what
# the currently active programming language is, and cast the name accordingly.
# The first argument is the name of the function/subroutine, in small letters,
# the second argument are the actions taken when the test works, and the
# third argument are the actions taken if the test fails.

AC_DEFUN([AC_COIN_TRY_FLINK],[
case $ac_ext in
  f)
    AC_TRY_LINK(,[      call $1],[flink_try=yes],[flink_try=no])
    ;;
  c)
    coin_need_flibs=no
    flink_try=no
    AC_F77_FUNC($1,cfunc$1)
    AC_LINK_IFELSE(
      [AC_LANG_PROGRAM([void $cfunc$1();],[$cfunc$1()])],
      [flink_try=yes],
      [if test x"$FLIBS" != x; then
         flink_save_libs="$LIBS"
         LIBS="$LIBS $FLIBS"
         AC_LINK_IFELSE(
           [AC_LANG_PROGRAM([void $cfunc$1();],[$cfunc$1()])],
           [coin_need_flibs=yes
            flint_try=yes]
         )
         LIBS="$flink_save_libs"
       fi
      ]
    )
    ;;
  cc|cpp)
    coin_need_flibs=no
    flink_try=no
    AC_F77_FUNC($1,cfunc$1)
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
]) # AC_COIN_TRY_FLINK

###########################################################################
#                         COIN_CHECK_PACKAGE_BLAS                         #
###########################################################################

# This macro checks for a library containing the BLAS library.  It
# 1. checks the --with-blas argument
# 2. if --with-blas=BUILD has been specified goes to point 5
# 3. if --with-blas has been specified to a working library, sets BLAS_LIBS
#    to its value
# 4. tries standard libraries
# 5. calls COIN_CHECK_PACKAGE(Blas, [coinblas], [$1]) to check for
#    ThirdParty/Blas
# The makefile conditional and preprocessor macro COIN_HAS_BLAS is defined.
# BLAS_LIBS is set to the flags required to link with a Blas library.
# For each build target X in $1, X_LIBS is extended with $BLAS_LIBS.
# In case 3 and 4, the flags to link to Blas are added to X_PCLIBS too.
# In case 5, Blas is added to X_PCREQUIRES.

AC_DEFUN([AC_COIN_CHECK_PACKAGE_BLAS],
[
AC_ARG_WITH([blas],
            AC_HELP_STRING([--with-blas],
                           [specify BLAS library (or BUILD to enforce use of ThirdParty/Blas)]),
            [use_blas="$withval"], [use_blas=])

# if user specified --with-blas-lib, then we should give COIN_CHECK_PACKAGE
# preference
AC_ARG_WITH([blas-lib],,[use_blas=BUILD])

# Check if user supplied option makes sense
if test x"$use_blas" != x; then
  if test "$use_blas" = "BUILD"; then
    # we come to this later
    :
  elif test "$use_blas" != "no"; then
    coin_save_LIBS="$LIBS"
    LIBS="$use_blas $LIBS"
    if test "$F77" != unavailable ; then
      coin_need_flibs=no
      AC_MSG_CHECKING([whether user supplied BLASLIB=\"$use_blas\" works])
      AC_COIN_TRY_FLINK([daxpy],
                        [if test $coin_need_flibs = yes ; then
                           use_blas="$use_blas $FLIBS"
                         fi
                         AC_MSG_RESULT([yes: $use_blas])],
                        [AC_MSG_RESULT([no])
                         AC_MSG_ERROR([user supplied BLAS library \"$use_blas\" does not work])])
      use_blas="$use_blas $FLIBS"
    else
      AC_MSG_NOTICE([checking whether user supplied BLASLIB=\"$use_blas\" works with C linkage])
      AC_LANG_PUSH(C)
      AC_CHECK_FUNC([daxpy],[],[AC_MSG_ERROR([user supplied BLAS library \"$use_blas\" does not work])])
      AC_LANG_POP(C)
    fi
    LIBS="$coin_save_LIBS"
  fi
else
# Try to autodetect the library for blas based on build system
  #AC_MSG_CHECKING([default locations for BLAS])
  case $build in
    *-sgi-*) 
      AC_MSG_CHECKING([whether -lcomplib.sgimath has BLAS])
      coin_need_flibs=no
      coin_save_LIBS="$LIBS"
      LIBS="-lcomplib.sgimath $LIBS"
      AC_COIN_TRY_FLINK([daxpy],
                        [use_blas="-lcomplib.sgimath"
                         if test $coin_need_flibs = yes ; then
                           use_blas="$use_blas $FLIBS"
                         fi
                         AC_MSG_RESULT([yes: $use_blas])
                        ],
                        [AC_MSG_RESULT([no])])
      LIBS="$coin_save_LIBS"
      ;;

    *-*-solaris*)
      AC_MSG_CHECKING([for BLAS in libsunperf])
      # Ideally, we'd use -library=sunperf, but it's an imperfect world. Studio
      # cc doesn't recognise -library, it wants -xlic_lib. Studio 12 CC doesn't
      # recognise -xlic_lib. Libtool doesn't like -xlic_lib anyway. Sun claims
      # that CC and cc will understand -library in Studio 13. The main extra
      # function of -xlic_lib and -library is to arrange for the Fortran run-time
      # libraries to be linked for C++ and C. We can arrange that explicitly.
      coin_need_flibs=no
      coin_save_LIBS="$LIBS"
      LIBS="-lsunperf $FLIBS $LIBS"
      AC_COIN_TRY_FLINK([daxpy],
                        [use_blas='-lsunperf'
                         if test $coin_need_flibs = yes ; then
                           use_blas="$use_blas $FLIBS"
                         fi
                         AC_MSG_RESULT([yes: $use_blas])
                        ],
                        [AC_MSG_RESULT([no])])
      LIBS="$coin_save_LIBS"
      ;;
      
    *-cygwin* | *-mingw*)
      case "$CC" in
        clang* ) ;;
        cl* | */cl* | CL* | */CL* | icl* | */icl* | ICL* | */ICL*)
          coin_save_LIBS="$LIBS"
          LIBS="mkl_intel_c.lib mkl_sequential.lib mkl_core.lib $LIBS"
          if test "$F77" != unavailable ; then
            AC_MSG_CHECKING([for BLAS in MKL (32bit)])
            AC_COIN_TRY_FLINK([daxpy],
                              [use_blas='mkl_intel_c.lib mkl_sequential.lib mkl_core.lib'
                               AC_MSG_RESULT([yes: $use_blas])
                              ],
                              [AC_MSG_RESULT([no])])
          else
            AC_MSG_NOTICE([for BLAS in MKL (32bit) using C linkage])
            AC_LANG_PUSH(C)
            AC_CHECK_FUNC([daxpy],[use_blas='mkl_intel_c.lib mkl_sequential.lib mkl_core.lib'])
            AC_LANG_POP(C)
          fi
          LIBS="$coin_save_LIBS"
          
          if test "x$use_blas" = x ; then
            LIBS="mkl_intel_lp64.lib mkl_sequential.lib mkl_core.lib $LIBS"
            if test "$F77" != unavailable ; then
              AC_MSG_CHECKING([for BLAS in MKL (64bit)])
              AC_COIN_TRY_FLINK([daxpy],
                                [use_blas='mkl_intel_lp64.lib mkl_sequential.lib mkl_core.lib'
                                 AC_MSG_RESULT([yes: $use_blas])
                                ],
                                [AC_MSG_RESULT([no])])
            else
              AC_MSG_NOTICE([for BLAS in MKL (64bit) using C linkage])
              # unset cached outcome of test with 32bit MKL
              unset ac_cv_func_daxpy
              AC_LANG_PUSH(C)
              AC_CHECK_FUNC([daxpy],[use_blas='mkl_intel_lp64.lib mkl_sequential.lib mkl_core.lib'])
              AC_LANG_POP(C)
            fi
            LIBS="$coin_save_LIBS"
          fi
          ;;
      esac
      ;;
      
     *-darwin*)
      AC_MSG_CHECKING([for BLAS in Veclib])
      coin_need_flibs=no
      coin_save_LIBS="$LIBS"
      LIBS="-framework Accelerate $LIBS"
      AC_COIN_TRY_FLINK([daxpy],
                        [use_blas='-framework Accelerate'
                         if test $coin_need_flibs = yes ; then
                           use_blas="$use_blas $FLIBS"
                         fi
                         AC_MSG_RESULT([yes: $use_blas])
                        ],
                        [AC_MSG_RESULT([no])])
      LIBS="$coin_save_LIBS"
      ;;
  esac

  if test -z "$use_blas" ; then
    AC_MSG_CHECKING([whether -lblas has BLAS])
    coin_need_flibs=no
    coin_save_LIBS="$LIBS"
    LIBS="-lblas $LIBS"
    AC_COIN_TRY_FLINK([daxpy],
                      [use_blas='-lblas'
                       if test $coin_need_flibs = yes ; then
                         use_blas="$use_blas $FLIBS"
                       fi
                       AC_MSG_RESULT([yes: $use_blas])
                      ],
                      [AC_MSG_RESULT([no])])
    LIBS="$coin_save_LIBS"
  fi

  # If we have no other ideas, consider building BLAS.
  if test -z "$use_blas" ; then
    use_blas=BUILD
  fi
fi

if test "x$use_blas" = xBUILD ; then
  AC_COIN_CHECK_PACKAGE(Blas, [coinblas], [$1])
  
elif test "x$use_blas" != x && test "$use_blas" != no; then
  coin_has_blas=yes
  AM_CONDITIONAL([COIN_HAS_BLAS],[test 0 = 0])
  AC_DEFINE([COIN_HAS_BLAS],[1], [If defined, the BLAS Library is available.])
  BLAS_LIBS="$use_blas"
  BLAS_CFLAGS=
  BLAS_DATA=
  AC_SUBST(BLAS_LIBS)
  AC_SUBST(BLAS_CFLAGS)
  AC_SUBST(BLAS_DATA)
  m4_foreach_w([myvar], [$1], [
    m4_toupper(myvar)_LIBS="$BLAS_LIBS $m4_toupper(myvar)_LIBS"
  ])
  
else
  coin_has_blas=no
  AM_CONDITIONAL([COIN_HAS_BLAS],[test 0 = 1])
fi

m4_foreach_w([myvar], [$1], [
  AC_SUBST(m4_toupper(myvar)_LIBS)
])

]) # AC_COIN_CHECK_PACKAGE_BLAS

###########################################################################
#                       COIN_CHECK_PACKAGE_LAPACK                         #
###########################################################################

# This macro checks for a library containing the LAPACK library.  It
# 1. checks the --with-lapack argument
# 2. if --with-lapack=BUILD has been specified goes to point 5
# 3. if --with-lapack has been specified to a working library, sets
#    LAPACK_LIBS to its value
# 4. tries standard libraries
# 5. calls COIN_CHECK_PACKAGE(Lapack, [coinlapack], [$1]) to check for
#    ThirdParty/Lapack
# The makefile conditional and preprocessor macro COIN_HAS_LAPACK is defined.
# LAPACK_LIBS is set to the flags required to link with a Lapack library.
# For each build target X in $1, X_LIBS is extended with $LAPACK_LIBS.
# In case 3 and 4, the flags to link to Lapack are added to X_PCLIBS too.
# In case 5, Lapack is added to X_PCREQUIRES.
#
# TODO: Lapack usually depends on Blas, so if we check for a system lapack library,
#   shouldn't we include AC_COIN_CHECK_PACKAGE_BLAS first?
#   However, if we look for coinlapack via AC_COIN_CHECK_PACKAGE(Lapack, [coinlapack], [$1]),
#   then we will get Blas as dependency of coinlapack.

AC_DEFUN([AC_COIN_CHECK_PACKAGE_LAPACK],
[
AC_ARG_WITH([lapack],
            AC_HELP_STRING([--with-lapack],
                           [specify LAPACK library (or BUILD to enforce use of ThirdParty/Lapack)]),
            [use_lapack=$withval], [use_lapack=])

#if user specified --with-lapack-lib, then we should give COIN_HAS_PACKAGE preference
AC_ARG_WITH([lapack-lib],,[use_lapack=BUILD])

# Check if user supplied option makes sense
if test x"$use_lapack" != x; then
  if test "$use_lapack" = "BUILD"; then
    # we come to this later
    :
  elif test "$use_lapack" != no; then
    use_lapack="$use_lapack $BLAS_LIBS"
    coin_save_LIBS="$LIBS"
    LIBS="$use_lapack $LIBS"
    if test "$F77" != unavailable; then
      AC_MSG_CHECKING([whether user supplied LAPACKLIB=\"$use_lapack\" works])
      coin_need_flibs=no
      AC_COIN_TRY_FLINK([dsyev],
                        [if test $coin_need_flibs = yes ; then
                           use_lapack="$use_lapack $FLIBS"
                         fi
                         AC_MSG_RESULT([yes: $use_lapack])
                        ],
                        [AC_MSG_RESULT([no])
                         AC_MSG_ERROR([user supplied LAPACK library \"$use_lapack\" does not work])])
    else
      AC_MSG_NOTICE([whether user supplied LAPACKLIB=\"$use_lapack\" works with C linkage])
      AC_LANG_PUSH(C)
      AC_CHECK_FUNC([dsyev],[],[AC_MSG_ERROR([user supplied LAPACK library \"$use_lapack\" does not work])])
      AC_LANG_POP(C)
    fi
    LIBS="$coin_save_LIBS"
  fi
else
  if test x$coin_has_blas = xyes; then
    # First try to see if LAPACK is already available with BLAS library
    coin_save_LIBS="$LIBS"
    LIBS="$BLAS_LIBS $LIBS"
    if test "$F77" != unavailable; then
      coin_need_flibs=no
      AC_MSG_CHECKING([whether LAPACK is already available with BLAS library])
      AC_COIN_TRY_FLINK([dsyev],
                        [use_lapack="$BLAS_LIBS"
                         if test $coin_need_flibs = yes ; then
                           use_lapack="$use_lapack $FLIBS"
                         fi
                         AC_MSG_RESULT([yes: $use_lapack])
                        ],
                        [AC_MSG_RESULT([no])])
    else
      AC_MSG_NOTICE([checking whether LAPACK is already available with BLAS library])
      AC_LANG_PUSH(C)
      AC_CHECK_FUNC([dsyev],[use_lapack="$BLAS_LIBS"])
      AC_LANG_POP(C)
    fi
    LIBS="$coin_save_LIBS"
  fi
  if test -z "$use_lapack"; then
    # Try to autodetect the library for lapack based on build system
    case $build in
      # TODO: Is this check actually needed here, since -lcomplib.sigmath should have been recognized as Blas library,
      #       and above it is checked whether the Blas library already contains Lapack
      *-sgi-*) 
        AC_MSG_CHECKING([whether -lcomplib.sgimath has LAPACK])
        coin_save_LIBS="$LIBS"
        coin_need_flibs=no
        LIBS="-lcomplib.sgimath $BLAS_LIBS $LIBS"
        AC_COIN_TRY_FLINK([dsyev],
                          [use_lapack="-lcomplib.sgimath $BLAS_LIBS"
                           if test $coin_need_flibs = yes ; then
                             use_lapack="$use_lapack $FLIBS"
                           fi
                           AC_MSG_RESULT([yes: $use_lapack])
                          ],
                          [AC_MSG_RESULT([no])])
        LIBS="$coin_save_LIBS"
        ;;

      # See comments in COIN_CHECK_PACKAGE_BLAS.
      # TODO: Is this check actually needed here, since -lsunperf should have been recognized as Blas library,
      #       and above it is checked whether the Blas library already contains Lapack
      *-*-solaris*)
        AC_MSG_CHECKING([for LAPACK in libsunperf])
        coin_need_flibs=no
        coin_save_LIBS="$LIBS"
        LIBS="-lsunperf $BLAS_LIBS $FLIBS $LIBS"
        AC_COIN_TRY_FLINK([dsyev],
                          [use_lapack='-lsunperf $BLAS_LIBS'
                           if test $coin_need_flibs = yes ; then
                             use_lapack="$use_lapack $FLIBS"
                           fi
                           AC_MSG_RESULT([yes: $use_lapack])
                          ],
                          [AC_MSG_RESULT([no])])
        LIBS="$coin_save_LIBS"
        ;;
        # On cygwin, do this check only if doscompile is disabled. The prebuilt library
        # will want to link with cygwin, hence won't run standalone in DOS.
    esac
  fi

  if test -z "$use_lapack" ; then
    AC_MSG_CHECKING([whether -llapack has LAPACK])
    coin_need_flibs=no
    coin_save_LIBS="$LIBS"
    LIBS="-llapack $BLAS_LIBS $LIBS"
    AC_COIN_TRY_FLINK([dsyev],
                      [use_lapack='-llapack'
                       if test $coin_need_flibs = yes ; then
                         use_lapack="$use_lapack $FLIBS"
                       fi
                       AC_MSG_RESULT([yes: $use_lapack])
                      ],
                      [AC_MSG_RESULT([no])])
    LIBS="$coin_save_LIBS"
  fi

  # If we have no other ideas, consider building LAPACK.
  if test -z "$use_lapack" ; then
    use_lapack=BUILD
  fi
fi

if test "x$use_lapack" = xBUILD ; then
  AC_COIN_CHECK_PACKAGE(Lapack, [coinlapack], [$1])

elif test "x$use_lapack" != x && test "$use_lapack" != no; then
  coin_has_lapack=yes
  AM_CONDITIONAL([COIN_HAS_LAPACK],[test 0 = 0])
  AC_DEFINE([COIN_HAS_LAPACK],[1], [If defined, the LAPACK Library is available.])
  LAPACK_LIBS="$use_lapack"
  LAPACK_CFLAGS=
  LAPACK_DATA=
  AC_SUBST(LAPACK_LIBS)
  AC_SUBST(LAPACK_CFLAGS)
  AC_SUBST(LAPACK_DATA)
  m4_foreach_w([myvar], [$1], [
    m4_toupper(myvar)_LIBS="$LAPACK_LIBS $m4_toupper(myvar)_LIBS"
  ])
  
else
  coin_has_lapack=no
  AM_CONDITIONAL([COIN_HAS_LAPACK],[test 0 = 1])
fi

m4_foreach_w([myvar], [$1], [
  AC_SUBST(m4_toupper(myvar)_LIBS)
])

]) # AC_COIN_CHECK_PACKAGE_LAPACK


#######################################################################
#                           COIN_CHECK_LIBM                           #
#######################################################################

# Check for the math library.
# For a (space separated) list of arguments X, this macro adds the flags
# for linking against the math library to a X_LIBS.

AC_DEFUN([AC_COIN_CHECK_LIBM],
[AC_REQUIRE([AC_PROG_CC])

coin_save_LIBS="$LIBS"

AC_LANG_PUSH(C)
AC_SEARCH_LIBS([cos],[m],
  [m4_foreach_w([myvar], [$1], [m4_toupper(myvar)_LIBS="-lm $m4_toupper(myvar)_LIBS"])]
)
AC_LANG_POP(C)

LIBS="$coin_save_LIBS"

]) # AC_COIN_CHECK_LIBM

###########################################################################
#                           COIN_CHECK_ZLIB                               #
###########################################################################

# This macro checks for the libz library.  If found, it sets the automake
# conditional COIN_HAS_ZLIB and defines the C preprocessor variable
# COIN_HAS_ZLIB.  Further, for a (space separated) list of arguments X,
# it adds the linker flag to the variables X_LIBS.

AC_DEFUN([AC_COIN_CHECK_ZLIB],
[AC_REQUIRE([AC_PROG_CC])

coin_has_zlib=no

AC_ARG_ENABLE([zlib],
              [AC_HELP_STRING([--disable-zlib],[do not compile with compression library zlib])],
              [coin_enable_zlib=$enableval],
              [coin_enable_zlib=yes])

if test $coin_enable_zlib = yes; then
  AC_LANG_PUSH(C)
  AC_CHECK_HEADER([zlib.h],[coin_has_zlib=yes])

  if test $coin_has_zlib = yes; then
    AC_CHECK_LIB([z],[gzopen],[:],[coin_has_zlib=no])
  fi

  if test $coin_has_zlib = yes; then
    m4_foreach_w([myvar], [$1], [m4_toupper(myvar)_LIBS="-lz $m4_toupper(myvar)_LIBS"])
    AC_DEFINE([COIN_HAS_ZLIB],[1],[Define to 1 if zlib is available])
  fi
  AC_LANG_POP(C)
fi

AM_CONDITIONAL(COIN_HAS_ZLIB, test x$coin_has_zlib = xyes)
]) # AC_COIN_CHECK_ZLIB


###########################################################################
#                            COIN_CHECK_BZLIB                             #
###########################################################################

# This macro checks for the libbz2 library.  If found, it defines the C
# preprocessor variable COIN_HAS_BZLIB.  Further, for a (space separated) list
# of arguments X, it adds the linker flag to the variables X_LIBS.

AC_DEFUN([AC_COIN_CHECK_BZLIB],
[AC_REQUIRE([AC_PROG_CC])

AC_ARG_ENABLE([bzlib],
              [AC_HELP_STRING([--disable-bzlib],[do not compile with compression library bzlib])],
              [coin_enable_bzlib=$enableval],
              [coin_enable_bzlib=yes])

coin_has_bzlib=no
if test $coin_enable_bzlib = yes; then
  AC_LANG_PUSH(C)
  AC_CHECK_HEADER([bzlib.h],[coin_has_bzlib=yes])

  if test $coin_has_bzlib = yes; then
    AC_CHECK_LIB([bz2],[BZ2_bzReadOpen],[:],[coin_has_bzlib=no])
  fi

  if test $coin_has_bzlib = yes; then
    m4_foreach_w([myvar], [$1], [m4_toupper(myvar)_LIBS="-lbz2 $m4_toupper(myvar)_LIBS"])
    AC_DEFINE([COIN_HAS_BZLIB],[1],[Define to 1 if bzlib is available])
  fi
  AC_LANG_POP(C)
fi
]) # AC_COIN_CHECK_BZLIB


###########################################################################
#                         COIN_CHECK_GNU_READLINE                         #
###########################################################################

# This macro checks for GNU's readline.  It verifies that the header
# readline/readline.h is available, and that the -lreadline library
# contains "readline".  It is assumed that #include <stdio.h> is included
# in the source file before the #include<readline/readline.h>
# If found, it defines the C preprocessor variable COIN_HAS_READLINE.
# Further, for a (space separated) list of arguments X, it adds the
# linker flag to the variable X_LIBS, X_PCLIBS, and X_LIBS_INSTALLED.

AC_DEFUN([AC_COIN_CHECK_GNU_READLINE],
[AC_REQUIRE([AC_PROG_CC])

AC_ARG_ENABLE([readline],
              [AC_HELP_STRING([--disable-readline],[do not compile with readline library])],
              [coin_enable_readline=$enableval],
              [coin_enable_readline=yes])

coin_has_readline=no
if test $coin_enable_readline = yes; then
  AC_LANG_PUSH(C)
  AC_CHECK_HEADER([readline/readline.h],[coin_has_readline=yes],[],[#include <stdio.h>])

  coin_save_LIBS="$LIBS"
  LIBS=
  # First we check if tputs and friends are available
  if test $coin_has_readline = yes; then
    AC_SEARCH_LIBS([tputs],[ncurses termcap curses],[],[coin_has_readline=no])
  fi

  # Now we check for readline
  if test $coin_has_readline = yes; then
    AC_CHECK_LIB([readline],[readline],[],[coin_has_readline=no])
  fi

  if test $coin_has_readline = yes; then
    m4_foreach_w([myvar], [$1], [m4_toupper(myvar)_LIBS="-lreadline $m4_toupper(myvar)_LIBS"])
    AC_DEFINE([COIN_HAS_READLINE],[1],[Define to 1 if readline is available])
  fi

  LIBS="$coin_save_LIBS"
  AC_LANG_POP(C)
fi
]) # AC_COIN_CHECK_GNU_READLINE

###########################################################################
#                              COIN_CHECK_GMP                             #
###########################################################################

# This macro checks for the gmp library.  If found, it defines the C
# preprocessor variable COIN_HAS_GMP.  Further, for a (space separated) list
# of arguments X, it adds the linker flag to the variables X_LIBS.

AC_DEFUN([AC_COIN_CHECK_GMP],
[AC_REQUIRE([AC_PROG_CC])

AC_ARG_ENABLE([gmp],
              [AC_HELP_STRING([--disable-gmp],[do not compile with GNU multiple precision library])],
              [coin_enable_gmp=$enableval],
              [coin_enable_gmp=yes])

coin_has_gmp=no
if test $coin_enable_gmp = yes; then
  AC_LANG_PUSH(C)
  AC_CHECK_HEADER([gmp.h],[AC_CHECK_LIB([gmp],[__gmpz_init],[coin_has_gmp=yes])])
  
  if test $coin_has_gmp = yes ; then
    m4_foreach_w([myvar], [$1], [m4_toupper(myvar)_LIBS="-lgmp $m4_toupper(myvar)_LIBS"])
    AC_DEFINE([COIN_HAS_GMP],[1],[Define to 1 if GMP is available])
  fi
  AC_LANG_POP(C)
fi
]) # AC_COIN_CHECK_GMP


###########################################################################
#                           COIN_DOXYGEN                                  #
###########################################################################
#
# This macro determines the configuration information for doxygen, the tool
# used to generate online documentation of COIN code. It takes one parameter,
# a list of projects (mixed-case, to match the directory names) that should
# be processed as external tag files. E.g., COIN_DOXYGEN([Clp Osi]).
#
# This macro will define the following variables:
#  coin_have_doxygen	Yes if doxygen is found, no otherwise
#  coin_doxy_usedot     Defaults to `yes'; --with-dot will still check to see
#			if dot is available
#  coin_doxy_tagname	Name of doxygen tag file (placed in doxydoc directory)
#  coin_doxy_logname    Name of doxygen log file (placed in doxydoc directory)
#  coin_doxy_tagfiles   List of doxygen tag files used to reference other
#                       doxygen documentation
#  coin_doxy_excludes	Directories to exclude from doxygen processing

AC_DEFUN([AC_COIN_DOXYGEN],
[

AC_MSG_NOTICE([configuring doxygen documentation options])

# Check to see if doxygen is available.

AC_CHECK_PROG([coin_have_doxygen],[doxygen],[yes],[no])
AC_CHECK_PROG([coin_have_latex],[latex],[yes],[no])

# Look for the dot tool from the graphviz package, unless the user has
# disabled it.

AC_ARG_WITH([dot],
  AS_HELP_STRING([--with-dot],
		 [use dot (from graphviz) when creating documentation with
		  doxygen if available; --without-dot to disable]),
  [],[withval=yes])
if test x"$withval" = xno ; then
  coin_doxy_usedot=NO
  AC_MSG_CHECKING([for dot ])
  AC_MSG_RESULT([disabled])
else
  AC_CHECK_PROG([coin_doxy_usedot],[dot],[YES],[NO])
fi

# Generate a tag file name and a log file name

AC_SUBST([coin_doxy_tagname],[doxydoc/${PACKAGE}_doxy.tag])
AC_SUBST([coin_doxy_logname],[doxydoc/${PACKAGE}_doxy.log])
AM_CONDITIONAL(COIN_HAS_DOXYGEN, [test $coin_have_doxygen = yes])
AM_CONDITIONAL(COIN_HAS_LATEX, [test $coin_have_latex = yes])

# Process the list of project names and massage them into possible doxygen
# doc'n directories. Prefer 1) classic external, source processed using
# a project-specific doxygen.conf, we use the tag file; 2) classic
# external, source processed using package doxygen.conf; 3) installed
# doxydoc. Alternatives 1) and 2) are only possible if the directory will be
# configured, which we can't know unless this is the package base configure,
# since coin_subdirs is only set there. Hence it's sufficient to check for
# membership. If we use a tag file from a classic external, exclude the
# source from doxygen processing when doxygen runs in the base directory.

coin_doxy_tagfiles=
coin_doxy_excludes=
tmp="$1"
for proj in $tmp ; do
  lc_proj=`echo $proj | [tr [A-Z] [a-z]]`
  AC_MSG_CHECKING([for doxygen doc'n for $proj ])
  doxytag=${lc_proj}_doxy.tag
  doxyfound=no
  # proj will be configured, hence doxydoc present in build tree
  doxysrcdir="${srcdir}/../${proj}"
  # AC_MSG_NOTICE([Considering $doxysrcdir (base)])
  if test -d "$doxysrcdir" ; then
    # with a doxydoc directory?
    doxydir="$doxysrcdir/doxydoc"
    # AC_MSG_NOTICE([Considering $doxydir (base)])
    # AC_MSG_NOTICE([Subdirs: $coin_subdirs)])
    if test -d "$doxydir" ; then
      # use tag file; don't process source
      doxydir="../${proj}/doxydoc"
      coin_doxy_tagfiles="$coin_doxy_tagfiles $doxydir/$doxytag=../../$doxydir/html"
      AC_MSG_RESULT([$doxydir (tag)])
      coin_doxy_excludes="$coin_doxy_excludes */${proj}"
    else
      # will process the source -- nothing further to be done here
      AC_MSG_RESULT([$doxysrcdir (src)])
    fi
    doxyfound=yes
  fi
  # Not built, fall back to installed tag file
  if test $doxyfound = no ; then
    eval doxydir="${datadir}/coin/doc/${proj}/doxydoc"
    # AC_MSG_NOTICE([Considering $doxydir (install)])
    # AC_MSG_NOTICE([Subdirs: $coin_subdirs)])
    coin_doxy_tagfiles="$coin_doxy_tagfiles $doxydir/$doxytag=$doxydir/html"
    AC_MSG_RESULT([$doxydir (tag)])
  fi
done
AC_SUBST([coin_doxy_tagfiles])
AC_SUBST([coin_doxy_excludes])

]) # AC_COIN_DOXYGEN
