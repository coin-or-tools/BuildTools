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
  if test "x$coin_majorver" = x ; then coin_majorver=9999 ; fi
  if test "x$coin_minorver" = x ; then coin_minorver=9999 ; fi
  if test "x$coin_releasever" = x ; then coin_releasever=9999 ; fi
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
# figure out whether there is a base directory up from here
coin_base_directory=
if test -e ../coin_subdirs.txt ; then
  coin_base_directory=`cd ..; pwd`
elif test -e ../../coin_subdirs.txt ; then
  coin_base_directory=`cd ../..; pwd`
fi

if test "x$coin_base_directory" != x ; then 
  COIN_DESTDIR=$coin_base_directory/coinstash
fi
AC_SUBST(COIN_DESTDIR)

# Set the project's version numbers
AC_COIN_PROJECTVERSION($1, $2)
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
# need to come before AC_OUTPUT
if test "x$coin_subdirs" != x; then
  # write coin_subdirs to a file so that project configuration knows where to find uninstalled projects
  echo $coin_subdirs > coin_subdirs.txt
else
  # substitute for OBJDIR, needed to setup .pc file for uninstalled project
  #ABSBUILDDIR="`pwd`"
  #AC_SUBST(ABSBUILDDIR)
  :
fi

AC_OUTPUT

AC_MSG_NOTICE([In case of trouble, first consult the troubleshooting page at https://projects.coin-or.org/BuildTools/wiki/user-troubleshooting])
#if test x$coin_projectdir = xyes; then
  AC_MSG_NOTICE([Configuration of $PACKAGE_NAME successful])
#else
#  AC_MSG_NOTICE([Main configuration of $PACKAGE_NAME successful])
#fi

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
# AC_SUBST'ed.  Finally, if this setup belongs to a project directory, then
# the search path for .pc files is assembled from the value of
# $PKG_CONFIG_PATH and the directories named in a file
# $coin_base_directory/coin_subdirs.txt in a variable
# COIN_PKG_CONFIG_PATH, which is also AC_SUBST'ed. For a path xxx given in the
# coin-subdirs.txt, also the directory xxx/pkgconfig is added, if existing.

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

# assemble pkg-config search path to find projects under base directory
COIN_PKG_CONFIG_PATH=
if test "x$coin_base_directory" != x ; then
  if test -f $coin_base_directory/coin_subdirs.txt ; then
    for i in `cat $coin_base_directory/coin_subdirs.txt` ; do
      if test -d $coin_base_directory/$i ; then
        COIN_PKG_CONFIG_PATH="$coin_base_directory/$i:${COIN_PKG_CONFIG_PATH}"
      fi
      if test -d $coin_base_directory/$i/pkgconfig ; then
        COIN_PKG_CONFIG_PATH="$coin_base_directory/$i/pkgconfig:${COIN_PKG_CONFIG_PATH}"
      fi
    done
  fi
fi
AC_SUBST(COIN_PKG_CONFIG_PATH)

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
m4_toupper($1_DEPENDENCIES)=
m4_toupper($1_PCREQUIRES)=
AC_SUBST(m4_toupper($1_LIBS))
AC_SUBST(m4_toupper($1_CFLAGS))
AC_SUBST(m4_toupper($1_DATA))
AC_SUBST(m4_toupper($1_DEPENDENCIES))
m4_foreach_w([myvar], [$3], [
  AC_SUBST(m4_toupper(myvar)_CFLAGS)
  AC_SUBST(m4_toupper(myvar)_LIBS)
  AC_SUBST(m4_toupper(myvar)_PCREQUIRES)
  AC_SUBST(m4_toupper(myvar)_DEPENDENCIES)
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
    # set search path for pkg-config
    # need to export variable to be sure that the following pkg-config gets these values
    coin_save_PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
    PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH:$PKG_CONFIG_PATH"
    export PKG_CONFIG_PATH
    
    # let pkg-config do it's magic
    AC_COIN_PKG_CHECK_MODULE_EXISTS([$1],[$2],
      [ m4_tolower(coin_has_$1)=yes
        AC_MSG_RESULT([yes: $m4_toupper($1)_VERSIONS])

        m4_toupper($1_DATA)=`$PKG_CONFIG --variable=datadir --define-variable prefix=${COIN_DESTDIR}${prefix} $2 2>/dev/null`
        
        m4_toupper($1_PCREQUIRES)="$2"
        # augment X_PCREQUIRES for each build target X in $3
        m4_foreach_w([myvar], [$3], [
          m4_toupper(myvar)_PCREQUIRES="$2 $m4_toupper(myvar)_PCREQUIRES"
        ])
      ],
      [ m4_tolower(coin_has_$1)=notGiven
        AC_MSG_RESULT([not given: $m4_toupper($1)_PKG_ERRORS])
      ])

    # reset PKG_CONFIG_PATH variable 
    PKG_CONFIG_PATH="$coin_save_PKG_CONFIG_PATH"
    export PKG_CONFIG_PATH

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
coin_save_PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH:$COIN_PKG_CONFIG_PATH_UNINSTALLED"
export PKG_CONFIG_PATH

m4_foreach_w([myvar],[$1],[
  if test -n "${m4_toupper(myvar)_PCREQUIRES}" ; then
    m4_toupper(myvar)_CFLAGS=`$PKG_CONFIG --cflags --define-variable prefix=${COIN_DESTDIR}${prefix} ${m4_toupper(myvar)_PCREQUIRES} ` ${m4_toupper(myvar)_CFLAGS}
    m4_toupper(myvar)_LIBS=`$PKG_CONFIG --libs --define-variable prefix=${COIN_DESTDIR}${prefix} ${m4_toupper(myvar)_PCREQUIRES} ` ${m4_toupper(myvar)_LIBS}
    #TODO setup _DEPENDENCIES from _LIBS
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

# reset PKG_CONFIG_PATH variable 
PKG_CONFIG_PATH="$coin_save_PKG_CONFIG_PATH"

])

###########################################################################
#                           COIN_MAIN_PACKAGEDIR                          #
###########################################################################

# Otherwise, if the directory $2/$1 and the file $2/$1/$3 exist, check whether $2/$1/configure exists.
#   If so, include this directory into the list of directories where configure and make recourse into.
# tolower(coin_has_$1) is set to "no" if the project source is not available or will not be compiled.
# Otherwise, it will be set to "yes".

AC_DEFUN([AC_COIN_MAIN_PACKAGEDIR],[
AC_MSG_CHECKING([whether source of project $1 is available and should be compiled])

m4_tolower(coin_has_$1)=notGiven
coin_reason=

# check if user wants to skip project in any case
AC_ARG_VAR([COIN_SKIP_PROJECTS],[Set to the subdirectories of projects that should be skipped in the configuration])
if test x"$COIN_SKIP_PROJECTS" != x; then
  for dir in $COIN_SKIP_PROJECTS; do
    if test $dir = "$1"; then
      m4_tolower(coin_has_$1)="no"
      coin_reason="$1 has been specified in COIN_SKIP_PROJECTS"
    fi
    m4_ifval($2,[
    if test $dir = "$2/$1"; then
      m4_tolower(coin_has_$1)="no"
      coin_reason="$2/$1 has been specified in COIN_SKIP_PROJECTS"
    fi])
  done
fi

if test "$m4_tolower(coin_has_$1)" != no; then
  AC_ARG_WITH([m4_tolower($1)],,
    [if test "$withval" = no ; then
       m4_tolower(coin_has_$1)="no"
       coin_reason="--without-m4_tolower($1) has been specified"
     fi
    ])
fi

if test "$m4_tolower(coin_has_$1)" != no; then
  AC_ARG_WITH([m4_tolower($1)-lib],
    AC_HELP_STRING([--with-m4_tolower($1)-lib],
                   [linker flags for using project $1]),
    [if test "$withval" = no ; then
       m4_tolower(coin_has_$1)="no"
       coin_reason="--without-m4_tolower($1)-lib has been specified"
     else
       m4_tolower(coin_has_$1)="no"
       coin_reason="--with-m4_tolower($1)-lib has been specified"
     fi],
    [])
fi

if test "$m4_tolower(coin_has_$1)" != no; then
  AC_ARG_WITH([m4_tolower($1)-incdir],
    AC_HELP_STRING([--with-m4_tolower($1)-incdir],
                   [directory with header files for using project $1]),
    [if test "$withval" = no ; then
       m4_tolower(coin_has_$1)="no"
       coin_reason="--without-m4_tolower($1)-incdir has been specified"
     else
       m4_tolower(coin_has_$1)="no"
       coin_reason="--with-m4_tolower($1)-incdir has been specified"
     fi],
    [])
fi

if test "$m4_tolower(coin_has_$1)" != no; then
  AC_ARG_WITH([m4_tolower($1)-datadir],
    AC_HELP_STRING([--with-m4_tolower($1)-datadir],
                   [directory with data files for using project $1]),
    [if test "$withval" = no ; then
       m4_tolower(coin_has_$1)="no"
       coin_reason="--without-m4_tolower($1)-datadir has been specified"
     else
       m4_tolower(coin_has_$1)="no"
       coin_reason="--with-m4_tolower($1)-datadir has been specified"
     fi],
    [])
fi


# check if project is available in present directory
if test "$m4_tolower(coin_has_$1)" = notGiven; then
  m4_tolower(coin_has_$1)=no
  if test -d $srcdir/m4_ifval($2,[$2/],)$1; then
    coin_reason="source in m4_ifval($2,[$2/],)$1"
    # If a third argument is given, then we have to check if one one the files given in that third argument is present.
    # If none of the files in the third argument is available, then we consider the project directory as non-existing.
    # However, if no third argument is given, then this means that there should be no check, and existence of the directory is sufficient.
    m4_ifvaln([$3],
      [for i in $srcdir/m4_ifval($2,[$2/],)$1/$3; do
         if test -r $i; then
           m4_tolower(coin_has_$1)="yes"
         else
           m4_tolower(coin_has_$1)="no"
           coin_reason="source file $i not available"
           break
         fi
       done],
      [ m4_tolower(coin_has_$1)="yes" ])
  fi
fi

if test -z "$coin_reason" ; then
  AC_MSG_RESULT([$m4_tolower(coin_has_$1)])
else
  AC_MSG_RESULT([$m4_tolower(coin_has_$1), $coin_reason])
fi

if test "$m4_tolower(coin_has_$1)" = yes ; then
  if test -r $srcdir/m4_ifval($2,[$2/],)$1/configure; then
    coin_subdirs="$coin_subdirs m4_ifval($2,[$2/],)$1"
    AC_CONFIG_SUBDIRS(m4_ifval($2,[$2/],)$1)
  fi
fi
])
