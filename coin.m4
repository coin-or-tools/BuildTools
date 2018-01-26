# Copyright (C) 2013-2016
# All Rights Reserved.
# This file is distributed under the Eclipse Public License.
#
# This file defines the common autoconf macros for COIN-OR
#

# Check requirements
AC_PREREQ(2.69)

###########################################################################
#                           COIN_CHECK_VPATH                              #
###########################################################################

# This macro sets the variable coin_vpath_config to true if this is a VPATH
# configuration, otherwise it sets it to false. `VPATH' just means we're
# following best practices and not building in the source directory.

AC_DEFUN([AC_COIN_CHECK_VPATH],
[
  AC_MSG_CHECKING(whether this is a VPATH configuration)
  if test `cd $srcdir ; pwd` != `pwd`; then
    coin_vpath_config=yes
  else
    coin_vpath_config=no
  fi
  AC_MSG_RESULT($coin_vpath_config)
]) # AC_COIN_CHECK_VPATH


###########################################################################
#                          COIN_PROJECTVERSION                            #
###########################################################################

# This macro is used by COIN_INITIALIZE and sets up variables related to
# versioning numbers of the project.
#   COIN_PROJECTVERSION([project],[libtool_version_string])

AC_DEFUN([AC_COIN_PROJECTVERSION],
[
  m4_ifvaln([$1],
    [AC_DEFINE_UNQUOTED(m4_toupper($1_VERSION),
       ["$PACKAGE_VERSION"],[Version number of project])

# Parse package version, assuming major.minor.release. PACKAGE_VERSION is set
# by AC_INIT. Force components to 9999 if they're empty; this deals with
# things like `trunk' and other nonstandard forms.
  
  [coin_majorver=`echo $PACKAGE_VERSION | sed -n -e 's/^\([0-9]*\).*/\1/gp'`]
  [coin_minorver=`echo $PACKAGE_VERSION | sed -n -e 's/^[0-9]*\.\([0-9]*\).*/\1/gp'`]
  [coin_releasever=`echo $PACKAGE_VERSION | sed -n -e 's/^[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/gp'`]
  test -z "$coin_majorver"   && coin_majorver=9999
  test -z "$coin_minorver"   && coin_minorver=9999
  test -z "$coin_releasever" && coin_releasever=9999
  AC_DEFINE_UNQUOTED(m4_toupper($1_VERSION_MAJOR),
    [$coin_majorver],[Major version number of project.])
  AC_DEFINE_UNQUOTED(m4_toupper($1_VERSION_MINOR),
    [$coin_minorver],[Minor version number of project.])
  AC_DEFINE_UNQUOTED(m4_toupper($1_VERSION_RELEASE),
    [$coin_releasever],[Release version number of project.])

# Create a variable set to the upper case version of the project name

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
      AC_DEFINE_UNQUOTED(m4_toupper($1_SVN_REV),
        $m4_toupper($1_SVN_REV),[SVN revision number of project])
    fi
  fi
 ])
 
# Capture the libtool library version, if given.

  m4_ifvaln([$2],[coin_libversion=$2],[])
])

###########################################################################
#                          COIN_ENABLE_MSVC                               # 
###########################################################################

# This macro is invoked by any PROG_compiler macro to establish the
# --enable-msvc option.

AC_DEFUN([AC_COIN_ENABLE_MSVC],
[
  AC_ARG_ENABLE([msvc],
    [AC_HELP_STRING([--enable-msvc],
       [Allow only Intel/Microsoft compilers on MinGW/MSys/Cygwin.])],
    [enable_msvc=$enableval],
    [enable_msvc=no])
])

###########################################################################
#                            COIN_INITIALIZE                               #
###########################################################################

AC_DEFUN([AC_COIN_COMPFLAGS_DEFAULTS],
[
# We want --enable-msvc setup and checked

  AC_REQUIRE([AC_COIN_ENABLE_MSVC])

# This macro should run before the compiler checks (doesn't seem to be
# sufficient for CFLAGS)

  AC_BEFORE([$0],[AC_PROG_CXX])
  AC_BEFORE([$0],[AC_PROG_CC])
  AC_BEFORE([$0],[AC_PROG_F77])
  AC_BEFORE([$0],[AC_PROG_FC])

# change default compiler flags (TODO bring back --enable-debug)
# - disable debugging (remove -g, set -DNDEBUG)
# - enable exceptions for (i)cl

  if test "$enable_msvc" = yes ; then
    : ${FFLAGS:=""}
    : ${FCFLAGS:=""}
    : ${CFLAGS:="-DNDEBUG -nologo"}
    : ${CXXFLAGS:="-DNDEBUG -EHsc -nologo"}
    : ${AR:="lib"}
    : ${AR_FLAGS:="-nologo -out:"}
  else
    : ${FFLAGS:=""}
    : ${FCFLAGS:=""}
    : ${CFLAGS:="-DNDEBUG"}
    : ${CXXFLAGS:="-DNDEBUG"}
  fi
])

# AC_COIN_INITIALIZE(name,version)

# This macro does everything that is required in the early part of the
# configure script, such as defining a few variables.
#   name: project name
#   version (optional): the libtool library version (important for releases,
#     less so for stable or trunk).

AC_DEFUN([AC_COIN_INITIALIZE],
[
# Enforce the required autoconf version

  AC_PREREQ(2.69)

# Set the project's version numbers

  AC_COIN_PROJECTVERSION($1, $2)

# A useful makefile conditional that is always false

  AM_CONDITIONAL(ALWAYS_FALSE, false)

# Where should everything be installed by default?  The COIN default is to
# install directly into subdirectories of the directory where configure is
# run. The default would be to install under /usr/local.

  AC_PREFIX_DEFAULT([`pwd`])

# Change the default compiler flags. This needs to run before
# AC_CANONICAL_BUILD.

  AC_REQUIRE([AC_COIN_COMPFLAGS_DEFAULTS])

# Get the build and host types

  AC_CANONICAL_BUILD
  AC_CANONICAL_HOST

# libtool has some magic for host_os=mingw, but doesn't know about msys

  if test $host_os = msys ; then
    host_os=mingw
    host=`echo $host | sed -e 's/msys/mingw/'`
  fi

# Make silent build rules the default (https://www.gnu.org/software/automake/
# manual/html_node/Automake-Silent-Rules.html). Run before AM_INIT_AUTOMAKE,
# which will AC_REQUIRE it anyway.

  AM_SILENT_RULES([yes])

# Initialize automake
# - don't define PACKAGE or VERSION
# - disable dist target
# - enable all automake warnings

  AM_INIT_AUTOMAKE([no-define no-dist -Wall])

# Disable automatic rebuild of configure/Makefile. Use run_autotools.

  AM_MAINTAINER_MODE
])

###########################################################################
#                           COIN_PROG_LIBTOOL                             #
###########################################################################

# Set up libtool parameters
# (https://www.gnu.org/software/libtool/manual/html_node/LT_005fINIT.html)

AC_DEFUN([AC_COIN_PROG_LIBTOOL],
[
# On Windows, shared C++ libraries do not work with the current libtool (it
# handles only exports for C functions, not C++). On all other systems, build
# shared libraries.

  case $host_os in
    cygwin* | mingw* | msys* )
      AC_DISABLE_SHARED
      ;;
    *)
      AC_DISABLE_STATIC
      ;;
  esac

# Create libtool

  AC_PROG_LIBTOOL

# Patch libtool to eliminate a trailing space after AR_FLAGS. This needs to be
# run after config.status has created libtool. Apparently necessary on
# Windows when lib.exe is the archive tool.

  case "$AR" in
    *lib* | *LIB* )
      AC_CONFIG_COMMANDS([libtoolpatch],
        [sed -e 's|AR_FLAGS |AR_FLAGS|g' libtool > libtool.tmp
	 mv libtool.tmp libtool
	 chmod 755 libtool])
      ;;
  esac

# -no-undefined is required for DLLs on Windows

  LT_LDFLAGS="-no-undefined"
  AC_SUBST([LT_LDFLAGS])
])

###########################################################################
#                    COIN_PROG_CC   COIN_PROG_CXX                         #
###########################################################################

# Macros to find C and C++ compilers according to specified lists of compiler
# names. For Fortran compilers, see coin_fortran.m4.

# Note that automake redefines AC_PROG_CC to invoke _AM_PROG_CC_C_O (an
# equivalent to AC_PROG_CC_C_O, plus wrap CC in the compile script if needed)
# and _AM_DEPENDENCIES (`dependency style'). Look in aclocal.m4 to see this.

AC_DEFUN_ONCE([AC_COIN_PROG_CC],
[
  AC_REQUIRE([AC_COIN_ENABLE_MSVC])

# Setting up libtool with LT_INIT will AC_REQUIRE AC_PROG_CC, but we want
# to invoke it from this macro first so that we can supply a parameter.

  AC_BEFORE([$0],[LT_INIT])
  AC_BEFORE([$0],[AC_PROG_LIBTOOL])

# If enable-msvc, then test only for MS and Intel (on Windows) C compiler
# otherwise, test a long list of C compilers that comes into our mind

  if test $enable_msvc = yes ; then
    comps="icl cl"
  else
    # TODO old buildtools was doing some $build specific logic here, do we
    # still need this?
    comps="gcc clang cc icc icl cl cc xlc xlc_r pgcc"  
  fi
  AC_PROG_CC([$comps])
])

# Note that automake redefines AC_PROG_CXX to invoke _AM_DEPENDENCIES
# (`dependency style') but does not add an equivalent for AC_PROG_CXX_C_O,
# hence we need an explicit call.

AC_DEFUN_ONCE([AC_COIN_PROG_CXX],
[
  AC_REQUIRE([AC_COIN_ENABLE_MSVC])
  AC_REQUIRE([AC_COIN_PROG_CC])

# If enable-msvc, then test only for MS and Intel (on Windows) C++ compiler
# otherwise, test a long list of C++ compilers that comes into our mind

  if test $enable_msvc = yes ; then
    comps="cl icl"
  else
    # TODO old buildtools was doing some $build specific logic here, do we
    # still need this?
    comps="g++ clang++ c++ pgCC icpc gpp cxx cc++ cl icl FCC KCC RCC xlC_r aCC CC"
  fi
  AC_PROG_CXX([$comps])

# If the compiler does not support -c -o, then wrap the compile script around
# it.

  AC_PROG_CXX_C_O
  if test $ac_cv_prog_cxx_c_o = no ; then
    CXX="$am_aux_dir/compile $CXX"
  fi
])


###########################################################################
#                           COIN_HAS_PKGCONFIG                            #
###########################################################################

# Check whether a suitable pkg-config tool is available.  If so, then the
# variable PKGCONFIG is set to its path, otherwise it is set to "".  Further,
# the AM_CONDITIONAL COIN_HAS_PKGCONFIG is set and PKGCONFIG is AC_SUBST'ed.
# Finally, the search path for .pc files is assembled from the value of
# $prefix and $PKG_CONFIG_PATH in a variable COIN_PKG_CONFIG_PATH, which is
# also AC_SUBST'ed.
# The default minimal version number is 0.16.0 because COIN-OR .pc files
# include a URL field which breaks pkg-config version <= 0.15. A more recent
# minimum version can be specified as a parameter.
# Portions of the macro body are derived from macros in pkg.m4.

AC_DEFUN([AC_COIN_HAS_PKGCONFIG],
[
  AC_ARG_VAR([PKG_CONFIG],[path to pkg-config utility])

# pkgconf is the up-and-coming thing, replacing pkg-config, so prefer it.
# The next stanza is a modified version of PKG_PROG_PKG_CONFIG from pkg.m4.

  if test -z "$PKG_CONFIG" ; then
   AC_CHECK_TOOLS([PKG_CONFIG],[pkgconf pkg-config])
  fi
  if test -n "$PKG_CONFIG" ; then
    pkg_min_version=m4_default([$1],[0.16.0])
    AC_MSG_CHECKING([$PKG_CONFIG is at least version $pkg_min_version])
    if $PKG_CONFIG --atleast-pkgconfig-version $pkg_min_version ; then
      AC_MSG_RESULT([yes: `$PKG_CONFIG --version`])
    else
     AC_MSG_RESULT([no])
     PKG_CONFIG=""
   fi
  fi

# Check if PKG_CONFIG supports the short-errors flag. The next stanza is a
# modified version of _PKG_SHORT_ERRORS_SUPPORTED from pkg.m4.

  if test -n "$PKG_CONFIG" &&
     $PKG_CONFIG --atleast-pkgconfig-version 0.20 ; then
    pkg_short_errors=" --short-errors "
  else
    pkg_short_errors=""
  fi

# Create a makefile variable and conditional.

  AM_CONDITIONAL([COIN_HAS_PKGCONFIG], [test -n "$PKG_CONFIG"])
  AC_SUBST(PKG_CONFIG)

# Assemble a PKG_CONFIG search path that will include the installation
# directory for .pc files for COIN packages.  Coin .pc files are installed in
# ${libdir}/pkgconfig. But autoconf sets $libdir to '${exec_prefix}/lib', and
# $exec_prefix to '${prefix}'.  COIN_INITIALIZE will set ac_default_prefix
# correctly. Unless the user specifies --prefix, it is set to NONE
# until the end of configuration, at which point it will be set to
# $ac_default_prefix. Unless the user specifies --exec-prefix, it is
# set to NONE until the end of configuration, at which point it's set to
# '${prefix}'. Sheesh.  So do the expansion, then back it out. Of course,
# this whole house of cards balances on the shaky assumption that the user is
# sane and has installed all packages in the same place and does not change
# that place when make executes. If not, well, it's their responsibility to
# augment PKG_CONFIG_PATH in the environment.

  COIN_PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
  AC_SUBST(COIN_PKG_CONFIG_PATH)

  save_prefix=$prefix
  save_exec_prefix=$exec_prefix
  if test "x$prefix" = xNONE ; then
    prefix=$ac_default_prefix
  fi
  if test "x$exec_prefix" = xNONE ; then
    exec_prefix=$prefix
  fi
  expanded_libdir=$libdir
  while expr "$expanded_libdir" : '.*$.*' >/dev/null 2>&1 ; do
    eval expanded_libdir=$expanded_libdir
  done
  prefix=$save_prefix
  exec_prefix=$save_exec_prefix
  COIN_PKG_CONFIG_PATH="${expanded_libdir}/pkgconfig:${COIN_PKG_CONFIG_PATH}"
  AC_MSG_NOTICE([$PKG_CONFIG path is "$COIN_PKG_CONFIG_PATH"])

])  # COIN_HAS_PKGCONFIG


###########################################################################
#                      COIN_CHK_MOD_EXISTS                                #
###########################################################################

# COIN_CHK_MOD_EXISTS(MODULE, PACKAGES,
#                     [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])

# Check to see whether a particular module (set of packages) exists. Derived
# from PKG_CHECK_MODULES() from pkg.m4, but set only the variables $1_VERSIONS
# and $1_PKG_ERRORS. PACKAGES ($2) is a space-separated list of .pc file names
# (without the .pc suffix). Note that variable values will have one line per
# package (embedded newlines) if more than one package is given in PACKAGES.

AC_DEFUN([AC_COIN_CHK_MOD_EXISTS],
[
  AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])

  if test -n "$PKG_CONFIG" ; then
    if PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --exists "$2" ; then
      m4_toupper($1)[]_VERSIONS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --modversion "$2" 2>/dev/null | tr '\n' ' '`
      $3
    else
      m4_toupper($1)_PKG_ERRORS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG $pkg_short_errors --errors-to-stdout --print-errors "$2"`
      $4
    fi
  else
    AC_MSG_ERROR("Cannot check for existence of module $1 without pkgconf")
  fi
])


###########################################################################
#                          COIN_CHK_PKG_CORE                              #
###########################################################################

# COIN_CHK_PKG_CORE([prim],[.pc file name],[default action])

# Determine whether we can use primary package prim ($1) and collect
# information on the required library flags (prim_libs), compiler flags
# (prim_cflags), and data directories (prim_data).

# The algorithm first checks for user specified values given with command line
# parameters --with-prim-libs, --with-prim-cflags, and --with-prim-data. If
# none of these are specified, it will look for a .pc file for prim using
# PKG_CONFIG.

# --with-prim is interpreted as follows: --with-prim=no is equivalent to
# --without-prim. Any of --with-prim, --with-prim=yes, or --with-prim=build,
# cause the macro to look for a .pc file. Any other value is taken as
# equivalent to --with-prim-libs=value.

# Default action ($3) (no, yes, build) is the default action if the user
# offers no guidance via command line parameters.

# If no .pc file names are specified, the macro will look for prim.pc if the
# default is yes, coinprim.pc if the default is build.  If a .pc file name
# ($2) is specified, it overrides the macro defaults.

# The macro doesn't test that the specified values actually work. This is
# deliberate.  There's no guarantee that user-specified libraries and/or
# directories actually exist yet. The same possibility exists for values
# returned when pkgconf checks the .pc file.

AC_DEFUN([AC_COIN_CHK_PKG_CORE],
[
  AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])

  dflt_action=m4_default([$3],[yes])

# Initialize variables for the primary package. Make sure variables for the
# client packages are set up as output variables.

  m4_tolower(coin_has_$1)=noInfo
  m4_tolower($1_libs)=
  m4_tolower($1_cflags)=
  m4_tolower($1_data)=
  m4_tolower($1_pcfiles)=

# Check to see if the user has overridden configure parameters from the
# environment.

  if test x"$COIN_SKIP_PROJECTS" != x ; then
    for pkg in $COIN_SKIP_PROJECTS ; do
      if test "$m4_tolower(pkg)" = "$m4_tolower($1)" ; then
	m4_tolower(coin_has_$1)=skipping
      fi
    done
  fi

# Check to see if the user specified --with-xxx.

  if test "$m4_tolower(coin_has_$1)" != skipping ; then
    AC_ARG_WITH([m4_tolower($1)],
      AS_HELP_STRING([--with-m4_tolower($1)],
	[Use $1. If an argument is given,
	 'yes' is equivalent to --with-m4_tolower($1),
	 'no' is equivalent to --without-m4_tolower($1),
	 'build' requests a COIN package.
	 Any other argument should be a linker library specification
	 appropriate for your environment.]),
      [case "$withval" in
         no )
	   m4_tolower(coin_has_$1)=skipping
	   ;;
	 yes )
	   m4_tolower(coin_has_$1)=requested
	   ;;
	 build )
	   m4_tolower(coin_has_$1)=build
	   ;;
	 * )
	   m4_tolower(coin_has_$1)=yes
	   m4_tolower($1_libs)=$withval
   	   ;;
       esac],[])
  fi

# Check if the user specified any of --with-xxx-lib, --with-xxx-incdir, and
# --with-xxx-datadir for the package.

  if test "$m4_tolower(coin_has_$1)" != skipping ; then
    AC_ARG_WITH([m4_tolower($1)-libs],
      AS_HELP_STRING([--with-m4_tolower($1)-lib],
	[Linker flags for $1 appropriate for your environment.
	 (Most often, -l specs for libraries.)]),
      [case "$withval" in
         build | no | yes )
	   AC_MSG_ERROR(["$withval" is not valid here; please specify linker flags appropriate for your environment.])
	   ;;
	 * )
	   m4_tolower(coin_has_$1)=yes
	   m4_tolower($1_libs)=$withval
	   ;;
       esac],[])

    AC_ARG_WITH([m4_tolower($1)-cflags],
      AS_HELP_STRING([--with-m4_tolower($1)-cflags],
        [Compiler flags for $1 appropriate for your environment.
	 (Most often, -I specs for header file directories.)]),
      [case "$withval" in
         build | no | yes )
	   AC_MSG_ERROR(["$withval" is not valid here; please specify compiler flags appropriate for your environment.])
	   ;;
	 * )
	   m4_tolower(coin_has_$1)=yes
	   m4_tolower($1_cflags)="$withval"
	   ;;
       esac],[])

    AC_ARG_WITH([m4_tolower($1)-data],
      AS_HELP_STRING([--with-m4_tolower($1)-data],
	[A data directory specification for $1 appropriate for your
	 environment.]),
      [case "$withval" in
         build | no | yes )
	   AC_MSG_ERROR(["$withval" is not valid here; please give a data directory specification appropriate for your environment.])
	   ;;
	 * )
	   m4_tolower(coin_has_$1)=yes
	   m4_tolower($1_data)="$withval"
	   ;;
       esac],[])
  fi

# At this point, coin_has_prim can be one of noInfo (no user options
# specified), skipping (user said no), requested or build (user said yes
# or build and gave no further guidance), or yes (user specified one or
# more --with-prim options). If we're already at yes or skipping, we're
# done looking.

# If there are no user options (noInfo) and the default is no, we're skipping.
# Otherwise, the default must be yes or build; consider the package requested.
# A default action we don't recognise defaults to yes.

  if test "$m4_tolower(coin_has_$1)" = noInfo ; then
    case $dflt_action in
      no )
	m4_tolower(coin_has_$1)=skipping
	;;
      build )
	m4_tolower(coin_has_$1)=build
	;;
      * )
        m4_tolower(coin_has_$1)=requested
	;;
    esac
  fi

# Now coin_has_prim can be one of skipping, yes, requested, or build. For
# requested or build, try pkgconf, if it's available. If it's not available,
# well, hope that the user knows their system and prim can be used with no
# additional flags.

  case $m4_tolower(coin_has_$1) in
    requested | build )
      if test -n "$PKG_CONFIG" ; then
	m4_ifnblank($2,
	  [pcfile=$2],
	  [if test $m4_tolower(coin_has_$1) = build ; then
	     pcfile=m4_tolower(coin$1)
	   else
	     pcfile=m4_tolower($1)
	   fi])
	AC_COIN_CHK_MOD_EXISTS([$1],[$pcfile],
	  [m4_tolower(coin_has_$1)=yes
	   m4_tolower($1_data)=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --variable=datadir $pcfile 2>/dev/null`
	   m4_tolower($1_pcfiles)="$pcfile"],
	  [m4_tolower(coin_has_$1)=no])
      else
	m4_tolower(coin_has_$1)=yes
	# AC_MSG_WARN([skipped check via pkgconf as no pkgconf available])
      fi
      ;;
    skipping | yes )
      ;;
    * )
      AC_MSG_WARN([Unexpected status "$m4_tolower(coin_has_$1)" in COIN_CHK_PKG_CORE])
      ;;
  esac

# The final value of coin_has_prim will be yes, no, or skipping. No means
# we looked (with pkgconfig) and didn't find anything. Skipping means the
# user said `don't use.' Yes means we have something, from the user or
# from pkgconfig. Note that we haven't run a useability test!

# Change the test to enable / disable debugging output

    if test 1 = 1 ; then
      AC_MSG_NOTICE([CHK_PKG_CORE result for $1: "$m4_tolower(coin_has_$1)"])
      AC_MSG_NOTICE([Collected values for package '$1'])
      AC_MSG_NOTICE([m4_tolower($1_libs) is "$m4_tolower($1_libs)"])
      AC_MSG_NOTICE([m4_tolower($1_cflags) is "$m4_tolower($1_cflags)"])
      AC_MSG_NOTICE([m4_tolower($1_data) is "$m4_tolower($1_data)"])
      AC_MSG_NOTICE([m4_tolower($1_pcfiles) is "$m4_tolower($1_pcfiles)"])
    fi

])  # COIN_CHK_PKG_CORE

###########################################################################
#                          COIN_CHK_PKG                                   #
###########################################################################

# COIN_CHK_PKG([prim],[client packages],[.pc file name],
#              [default action],[public/private])

# Determine whether we can use primary package prim ($1) and collect
# information on the required library flags (prim_libs), compiler flags
# (prim_cflags), and data directories (prim_data).

# The algorithm first checks for user specified values given with command line
# parameters --with-prim-libs, --with-prim-cflags, and --with-prim-data. If
# none of these are specified, it will look for a .pc file for prim using
# PKG_CONFIG.

# --with-prim is interpreted as follows: --with-prim=no is equivalent to
# --without-prim. Any of --with-prim, --with-prim=yes, or --with-prim=build,
# cause the macro to look for a .pc file. Any other value is taken as
# equivalent to --with-prim-libs=value.

# Default action ($4) (no, yes, build) is the default action if the user
# offers no guidance via command line parameters.

# If no .pc file names are specified, the macro will look for prim.pc if the
# default is yes, coinprim.pc if the default is build.  If a .pc file name
# ($3) is specified, it overrides the macro defaults.

# Define an automake conditional COIN_HAS_PRIM to record the result. If we
# decide to use prim, also define a preprocessor symbol COIN_HAS_PRIM.

# Linker and compiler flag information will be propagated to the space-
# separated list of client packages ($2) using the _PCFILES variable if
# a .pc file is used, otherwise by the _LIBS and _CFLAGS variables of
# client packages. These variables match Requires.private, Libs.private,
# and Cflags.private, respectively, in a .pc file. To force information about
# prim to be added to the public variables in a .pc file, set public/private
# ($5) to public.

# The macro doesn't test that the specified values actually work. This is
# deliberate.  There's no guarantee that user-specified libraries and/or
# directories actually exist yet. The same possibility exists for values
# returned when pkgconf checks the .pc file.

AC_DEFUN([AC_COIN_CHK_PKG],
[
  AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])

  AC_MSG_CHECKING([for package $1])

  pubpriv=m4_default([$5],[private])

# Make sure the necessary variables exist for each client package.

  m4_foreach_w([myvar],[$2],
    [AC_SUBST(m4_toupper(myvar)_LIBS)
     AC_SUBST(m4_toupper(myvar)_CFLAGS)
     AC_SUBST(m4_toupper(myvar)_PCFILES)
     AC_SUBST(m4_toupper(myvar)_LIBS_PUB)
     AC_SUBST(m4_toupper(myvar)_CFLAGS_PUB)
     AC_SUBST(m4_toupper(myvar)_PCFILES_PUB)])

# Invoke CHK_PKG_CORE to do the heavy lifting.

  AC_COIN_CHK_PKG_CORE(m4_tolower($1),[$3],[$4])

  AC_MSG_RESULT([$m4_tolower(coin_has_$1)])

# Create an automake conditional COIN_HAS_PRIM.

  AM_CONDITIONAL(m4_toupper(COIN_HAS_$1),
  		 [test $m4_tolower(coin_has_$1) = yes])

# If we've located the package, define preprocessor symbol COIN_HAS_PRIM
# and augment the necessary variables for the client packages. We need the
# final ':' (noop) below because it's possible that PRIM is data-only and the
# list of client packages is empty.

  if test $m4_tolower(coin_has_$1) = yes ; then
    AC_DEFINE(m4_toupper(COIN_HAS_$1),[1],
      [Define to 1 if the $1 package is available])
    if test $pubpriv = private ; then
      m4_foreach_w([myvar],[$2],
        [m4_toupper(myvar)_PCFILES="$m4_tolower($1_pcfiles) $m4_toupper(myvar)_PCFILES"
         m4_toupper(myvar)_LIBS="$m4_tolower($1_libs) $m4_toupper(myvar)_LIBS"
         m4_toupper(myvar)_CFLAGS="$m4_tolower($1_cflags) $m4_toupper(myvar)_CFLAGS"])
      :
    else
      m4_foreach_w([myvar],[$2],
        [m4_toupper(myvar)_PCFILES_PUB="$m4_tolower($1_pcfiles) $m4_toupper(myvar)_PCFILES"_PUB
         m4_toupper(myvar)_LIBS_PUB="$m4_tolower($1_libs) $m4_toupper(myvar)_LIBS_PUB"
         m4_toupper(myvar)_CFLAGS_PUB="$m4_tolower($1_cflags) $m4_toupper(myvar)_CFLAGS_PUB"])
      :
    fi

# Finally, set up PRIM_DATA.

    AC_SUBST(m4_toupper($1)_DATA)
    m4_toupper($1)_DATA=$m4_tolower($1_data)
  fi
])   # COIN_CHK_PKG

#######################################################################
#                           COIN_CHECK_LIBM                           #
#######################################################################

# COIN_CHECK_LIBM([client1 client2 ...])
# Check if a library spec is needed for the math library. If something is
# needed, the macro adds the flags to CLIENT_LIBS for each client.

AC_DEFUN([AC_COIN_CHECK_LIBM],
[
  AC_REQUIRE([AC_PROG_CC])

  coin_save_LIBS="$LIBS"
  LIBS=
  AC_SEARCH_LIBS([cos],[m],
    [if test "$ac_cv_search_cos" != 'none required' ; then
       m4_foreach_w([myvar],[$1],
	 [m4_toupper(myvar)_LIBS="$ac_cv_search_cos $m4_toupper(myvar)_LIBS"])
     fi])
  LIBS="$coin_save_LIBS"
]) # AC_COIN_CHECK_LIBM

###########################################################################
#                           COIN_CHECK_ZLIB                               #
###########################################################################

# COIN_CHECK_ZLIB([client1 client2 ...])

# This macro checks for the libz library.  If found, it sets the automake
# conditional COIN_HAS_ZLIB and defines the C preprocessor variable
# COIN_HAS_ZLIB. The default is to use zlib, if it's present.  For each
# client, it adds the linker flags to the variable CLIENT_LIBS.

AC_DEFUN([AC_COIN_CHECK_ZLIB],
[
  AC_REQUIRE([AC_COIN_PROG_CC])

  coin_has_zlib=no

  AC_ARG_ENABLE([zlib],
    [AC_HELP_STRING([--disable-zlib],
       [do not compile with compression library zlib])],
    [coin_enable_zlib=$enableval],
    [coin_enable_zlib=yes])

  if test x$coin_enable_zlib = xyes ; then
    AC_CHECK_HEADER([zlib.h],[coin_has_zlib=yes])
    if test x$coin_has_zlib = xyes ; then
      AC_CHECK_LIB([z],[gzopen],[],[coin_has_zlib=no])
    fi
    if test x$coin_has_zlib = xyes ; then
      m4_foreach_w([myvar],[$1],
	[m4_toupper(myvar)_LIBS="-lz $m4_toupper(myvar)_LIBS"])
      AC_DEFINE([COIN_HAS_ZLIB],[1],[Define to 1 if zlib is available])
    fi
  fi

  AM_CONDITIONAL([COIN_HAS_ZLIB],[test x$coin_has_zlib = xyes])
]) # AC_COIN_CHECK_ZLIB


###########################################################################
#                            COIN_CHECK_BZLIB                             #
###########################################################################

# COIN_CHECK_BZLIB([client1 client2 ...])

# This macro checks for the libbz2 library.  If found, it defines the
# C preprocessor variable COIN_HAS_BZLIB and the automake conditional
# COIN_HAS_BZLIB.  Further, for a (space separated) list of clients, it adds
# the linker flag to the variable CLIENT_LIBS.

AC_DEFUN([AC_COIN_CHECK_BZLIB],
[
  AC_REQUIRE([AC_PROG_CC])

  coin_has_bzlib=no

  AC_ARG_ENABLE([bzlib],
    [AC_HELP_STRING([--disable-bzlib],
       [do not compile with compression library bzlib])],
    [coin_enable_bzlib=$enableval],
    [coin_enable_bzlib=yes])

  if test $coin_enable_bzlib = yes ; then
    AC_CHECK_HEADER([bzlib.h],[coin_has_bzlib=yes])
    if test $coin_has_bzlib = yes ; then
      AC_CHECK_LIB([bz2],[BZ2_bzReadOpen],[],[coin_has_bzlib=no])
    fi
    if test $coin_has_bzlib = yes ; then
      m4_foreach_w([myvar],[$1],
        [m4_toupper(myvar)_LIBS="-lbz2 $m4_toupper(myvar)_LIBS"])
      AC_DEFINE([COIN_HAS_BZLIB],[1],[Define to 1 if bzlib is available])
    fi
  fi

  AM_CONDITIONAL([COIN_HAS_BZLIB],[test x$coin_has_bzlib = xyes])
]) # AC_COIN_CHECK_BZLIB


###########################################################################
#                              COIN_CHECK_GMP                             #
###########################################################################

# COIN_CHECK_GMP([client1 client2 ...])

# This macro checks for the gmp library.  If found, it defines the C
# preprocessor variable COIN_HAS_GMP and the automake conditional COIN_HAS_GMP.
# Further, for a (space separated) list of clients, it adds the linker
# flag to the variable CLIENT_LIBS.

AC_DEFUN([AC_COIN_CHECK_GMP],
[
  AC_REQUIRE([AC_PROG_CC])

  coin_has_gmp=no

  AC_ARG_ENABLE([gmp],
    [AC_HELP_STRING([--disable-gmp],
       [do not compile with GNU multiple precision library])],
    [coin_enable_gmp=$enableval],
    [coin_enable_gmp=yes])

  if test $coin_enable_gmp = yes ; then
    AC_CHECK_HEADER([gmp.h],
      [AC_CHECK_LIB([gmp],[__gmpz_init],[coin_has_gmp=yes])])
    if test $coin_has_gmp = yes ; then
      m4_foreach_w([myvar],[$1],
	[m4_toupper(myvar)_LIBS="-lgmp $m4_toupper(myvar)_LIBS"])
      AC_DEFINE([COIN_HAS_GMP],[1],[Define to 1 if GMP is available])
    fi
  fi

  AM_CONDITIONAL([COIN_HAS_GMP],[test x$coin_has_gmp = xyes])
]) # AC_COIN_CHECK_GMP


###########################################################################
#                         COIN_CHECK_GNU_READLINE                         #
###########################################################################

# COIN_CHECK_GNU_READLINE([client1 client2 ...])

# This macro checks for GNU's readline.  It verifies that the header
# readline/readline.h is available, and that the -lreadline library contains
# "readline".  It is assumed that #include <stdio.h> is included in the source
# file before the #include<readline/readline.h> If found, it defines the C
# preprocessor variable COIN_HAS_READLINE.  Further, for a (space separated)
# list of clients, it adds the linker flag to the variable CLIENT_LIBS.

AC_DEFUN([AC_COIN_CHECK_GNU_READLINE],
[
  AC_REQUIRE([AC_PROG_CC])

  coin_has_readline=no

  AC_ARG_ENABLE([readline],
    [AC_HELP_STRING([--disable-readline],
       [do not compile with readline library])],
    [coin_enable_readline=$enableval],
    [coin_enable_readline=yes])

  if test $coin_enable_readline = yes ; then
    AC_CHECK_HEADER([readline/readline.h],
      [coin_has_readline=yes],[],[#include <stdio.h>])
    coin_save_LIBS="$LIBS"
    LIBS=
    if test $coin_has_readline = yes ; then
      AC_SEARCH_LIBS([tputs],
        [ncurses termcap curses],[],[coin_has_readline=no])
    fi
    if test $coin_has_readline = yes ; then
      AC_CHECK_LIB([readline],[readline],[],[coin_has_readline=no])
    fi
    if test $coin_has_readline = yes ; then
      m4_foreach_w([myvar],[$1],
        [m4_toupper(myvar)_LIBS="-lreadline $m4_toupper(myvar)_LIBS"])
      AC_DEFINE([COIN_HAS_READLINE],[1],[Define to 1 if readline is available])
    fi
    LIBS="$coin_save_LIBS"
  fi

  AM_CONDITIONAL([COIN_HAS_READLINE],[test x$coin_has_readline = xyes])
]) # AC_COIN_CHECK_GNU_READLINE

###########################################################################
#                           COIN_DOXYGEN                                  #
###########################################################################

# This macro determines the configuration information for doxygen, the tool
# used to generate online documentation of COIN code. It takes one parameter,
# a list of projects (mixed-case, to match the install directory names) that
# should be processed as external tag files. E.g., COIN_DOXYGEN([Clp Osi]).

# This macro will define the following variables:
#  coin_have_doxygen	Yes if doxygen is found, no otherwise
#  coin_doxy_usedot     Defaults to `yes'; --with-dot will still check to see
#			if dot is available
#  coin_doxy_tagname	Name of doxygen tag file (placed in doxydoc directory)
#  coin_doxy_logname    Name of doxygen log file (placed in doxydoc directory)
#  coin_doxy_tagfiles   List of doxygen tag files used to reference other
#                       doxygen documentation

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

AC_SUBST([coin_doxy_tagname],[${PACKAGE}_doxy.tag])
AC_SUBST([coin_doxy_logname],[${PACKAGE}_doxy.log])
AM_CONDITIONAL(COIN_HAS_DOXYGEN, [test $coin_have_doxygen = yes])
AM_CONDITIONAL(COIN_HAS_LATEX, [test $coin_have_latex = yes])

# Process the list of project names and massage each one into the name of a
# tag file. Further substitution for @doxydocdir@ will happen during make
# install.

coin_doxy_tagfiles=
tmp="$1"
for proj in $tmp ; do
  lc_proj=`echo $proj | [tr [A-Z] [a-z]]`
  doxytag=${lc_proj}_doxy.tag
  coin_doxy_tagfiles="$coin_doxy_tagfiles @docdir_nosub@/$proj/doxydoc/$doxytag=@docdir_nosub@/$proj/doxydoc"
done
AC_SUBST([coin_doxy_tagfiles])

]) # AC_COIN_DOXYGEN


###########################################################################
#                          COIN_EXAMPLE_FILES                             #
###########################################################################

# This macro deals with `example' files. Its original use is for data files
# associated with the Data projects. It allows for uniform handling of files
# that are not processed but should be present in the build directory. Most of
# the work is done by make. This macro just sets up the necessary variables.
# The justification for this approach is to allow the use of file name wild
# cards in the argument. The underlying machinery of autoconf and automake
# kind of breaks down when the file names are not literal text.

# One tradeoff for allowing the use of wildcards is that it's not possible to
# give the created link a name that's different from the source file.

# The variables (file names accumulate over calls):
# EXAMPLE_DIST_FILES: The originals that should be distributed
# EXAMPLE_UNCOMP_FILES: like EXAMPLE_DIST_FILES, but names of compressed files
# are stripped of their .gz suffix.
# EXAMPLE_CLEAN_FILES: contains only the names of files that were stripped of
# .gz. Essential for distclean in a non-VPATH build.
# One of EXAMPLE_DIST_FILES or EXAMPLE_UNCOMP_FILES will be the list of file
# names for install / uninstall. See Makefile.am in a Data project for usage.

AC_DEFUN([AC_COIN_EXAMPLE_FILES],
[
AC_REQUIRE([AC_COIN_CHECK_VPATH])[]dnl
AC_REQUIRE([AC_PROG_LN_S])[]dnl
AM_CONDITIONAL([COIN_VPATH_BUILD],[test x$coin_vpath_config = xyes])

# Get the names of the files and sort them to the various variables. As
# a convenient side-effect, the loop will remove newlines from the list
# of files. Avoid adding duplicate file names. (Allowing wild cards makes
# duplicates far too likely.) The redirect of stderr on the ls is arguable. It
# avoids error messages in the configure output if the package maintainer
# specifies files that don't exist (for example, generic wild card specs
# that anticipate future growth) but it will hide honest errors.

files=`cd $srcdir; ls $1 2>/dev/null`
for file in $files; do
  if expr " $EXAMPLE_DIST_FILES " : '.* '"$file"' .*' >/dev/null 2>&1 ; then
    continue ;
  fi
  EXAMPLE_DIST_FILES="$EXAMPLE_DIST_FILES $file"
  if expr "$file" : '.*\.gz$' >/dev/null 2>&1 ; then
    EXAMPLE_UNCOMP_FILES="$EXAMPLE_UNCOMP_FILES `expr "$file" : '\(.*\)\.gz$'`"
    EXAMPLE_CLEAN_FILES="$EXAMPLE_CLEAN_FILES `expr "$file" : '\(.*\)\.gz$'`"
  else
    EXAMPLE_UNCOMP_FILES="$EXAMPLE_UNCOMP_FILES $file"
  fi
done

AC_SUBST(EXAMPLE_DIST_FILES)
AC_SUBST(EXAMPLE_UNCOMP_FILES)
AC_SUBST(EXAMPLE_CLEAN_FILES)

]) # AC_COIN_EXAMPLE_FILES

###########################################################################
#                           COIN_FINALIZE_FLAGS                           #
###########################################################################

# COIN_FINALIZE_FLAGS([client1 client2 ...])

# For each client, accumulate the necessary flags in CLIENT_LIBS and
# CLIENT_CFLAGS.  The algorithm accumulates the flags for the packages
# in CLIENT_PCFILES and tacks on the current value of CLIENT_LIBS and
# CLIENT_CFLAGS.

# TODO this could be moved into COIN_FINALIZE, if we were able to remember
#   for which variables we need to run pkg-config

AC_DEFUN([AC_COIN_FINALIZE_FLAGS],
[
  m4_foreach_w([myvar],[$1],
    [if test -n "${m4_toupper(myvar)_PCFILES}" ; then
       temp_CFLAGS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --cflags ${m4_toupper(myvar)_PCFILES}`
       temp_LIBS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --libs ${m4_toupper(myvar)_PCFILES}`
       m4_toupper(myvar)_CFLAGS="$temp_CFLAGS ${m4_toupper(myvar)_CFLAGS}"
       m4_toupper(myvar)_LIBS="$temp_LIBS ${m4_toupper(myvar)_LIBS}"
     fi

# Change the test to enable / disable debugging output

     if test 1 = 1 ; then
       AC_MSG_NOTICE(
         [FINALIZE_FLAGS for myvar: adding "${m4_toupper(myvar)_PCFILES}"])
       AC_MSG_NOTICE([m4_toupper(myvar)_LIBS is "${m4_toupper(myvar)_LIBS}"])
       AC_MSG_NOTICE([m4_toupper(myvar)_CFLAGS is "${m4_toupper(myvar)_CFLAGS}"])
     fi])
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

