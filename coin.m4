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
#                        COIN_COMPFLAGS_DEFAULTS                          #
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

###########################################################################
#                            COIN_INITIALIZE                               #
###########################################################################

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

# Change the default compiler flags. This needs to run before
# AC_CANONICAL_BUILD.

  AC_REQUIRE([AC_COIN_COMPFLAGS_DEFAULTS])

# Get the build and host types

  AC_CANONICAL_BUILD
  AC_CANONICAL_HOST

# libtool has some magic for host_os and build_os being mingw, but doesn't know about msys

  if test $host_os = msys ; then
    host_os=mingw
    host=`echo $host | sed -e 's/msys/mingw/'`
  fi

  if test $build_os = msys ; then
    build_os=mingw
    build=`echo $build | sed -e 's/msys/mingw/'`
  fi

# Make silent build rules the default (https://www.gnu.org/software/automake/
# manual/html_node/Automake-Silent-Rules.html). Run before AM_INIT_AUTOMAKE,
# which will AC_REQUIRE it anyway.

  AM_SILENT_RULES([yes])

# Initialize automake
# - don't AC_DEFINE PACKAGE or VERSION (but there're still defined as shell
#   variables in configure, and as make variables).
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
# (lh, 180302) Sadly, we can't use the obvious libtool macros
# (AC_{ENABLE,DISABLE}_{SHARED,STATIC}, nor parameters to LT_INIT,
# precisely because these macros record the default behaviour by defining
# a macro, _LT_ENABLE_{SHARED,STATIC}_DEFAULT. No shell code involved, hence
# any shell conditional has no effect. Either we trust libtool or we need
# something more inventive. The relevant libtool macros are in ltoptions.m4,
# _LT_ENABLE_SHARED and _LT_ENABLE_STATIC.
# That is, something like the following will not work:
# case $host_os in
#   cygwin* | mingw* | msys* ) AC_DISABLE_SHARED  ;;
#   *) AC_DISABLE_STATIC ;;
# esac

# Create libtool.

  LT_INIT([disable-static pic-only win32-dll])

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

# Set up LT_LDFLAGS. Add the library version string to LT_LDFLAGS, if one
# is supplied.

  AC_SUBST([LT_LDFLAGS])
  AC_MSG_CHECKING([if the library version is set])
  if test x"$coin_libversion" != x ; then
    LT_LDFLAGS="$LT_LDFLAGS -version-info $coin_libversion"
    AC_MSG_RESULT([$coin_libversion])
  else
    AC_MSG_RESULT([no])
  fi

  # shared libraries should have no undefined symbols
  # for Windows DLLs, it is mandatory to add this
  LT_LDFLAGS="$LT_LDFLAGS -no-undefined"
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
#                   COIN_DEFINENAMEMANGLING                               #
###########################################################################

# COIN_DEFINENAMEMANGLING (name,namemangling)
# -------------------------------------------------------------------------
# Determine C/C++ name mangling to allow linking with header-less libraries.
#  name ($1) an identifier to prefix C macro names
#  namemangling ($2) the name mangling scheme as determined by COIN_NAMEMANGLING
#                    or COIN_TRY_LINK
#
# Defines the C macros $1_FUNC and $1_FUNC_ (in uppercase) to be used for
# declaring functions from library $1.

# -------------------------------------------------------------------------

AC_DEFUN([AC_COIN_DEFINENAMEMANGLING],
[
  AH_TEMPLATE($1_FUNC, [Define to a macro mangling the given C identifier (in lower and upper case).])
  AH_TEMPLATE($1_FUNC_, [As $1_FUNC, but for C identifiers containing underscores.])
  case "$2" in
   "lower case, no underscore, no extra underscore")
      AC_DEFINE($1_FUNC[(name,NAME)],  [name])
      AC_DEFINE($1_FUNC_[(name,NAME)], [name]) ;;
   "lower case, no underscore, extra underscore")
      AC_DEFINE($1_FUNC[(name,NAME)],  [name])
      AC_DEFINE($1_FUNC_[(name,NAME)], [name [##] _]) ;;
   "lower case, underscore, no extra underscore")
      AC_DEFINE($1_FUNC[(name,NAME)],  [name [##] _])
      AC_DEFINE($1_FUNC_[(name,NAME)], [name [##] _]) ;;
   "lower case, underscore, extra underscore")
      AC_DEFINE($1_FUNC[(name,NAME)],  [name [##] _])
      AC_DEFINE($1_FUNC_[(name,NAME)], [name [##] __]) ;;
   "upper case, no underscore, no extra underscore")
      AC_DEFINE($1_FUNC[(name,NAME)],  [NAME])
      AC_DEFINE($1_FUNC_[(name,NAME)], [NAME]) ;;
   "upper case, no underscore, extra underscore")
      AC_DEFINE($1_FUNC[(name,NAME)],  [NAME])
      AC_DEFINE($1_FUNC_[(name,NAME)], [NAME [##] _]) ;;
   "upper case, underscore, no extra underscore")
      AC_DEFINE($1_FUNC[(name,NAME)],  [NAME [##] _])
      AC_DEFINE($1_FUNC_[(name,NAME)], [NAME [##] _]) ;;
   "upper case, underscore, extra underscore")
      AC_DEFINE($1_FUNC[(name,NAME)],  [NAME [##] _])
      AC_DEFINE($1_FUNC_[(name,NAME)], [NAME [##] __]) ;;
   *)
      AC_MSG_WARN([Unsupported or unknown name-mangling scheme: $2])
      ;;
  esac
])

###########################################################################
#                   COIN_NAMEMANGLING                                     #
###########################################################################

# COIN_NAMEMANGLING (lib,func,lflags)
# -------------------------------------------------------------------------
# Determine C/C++ name mangling to allow linking with header-less libraries.
#  lib ($1) a library we're attempting to link to
#  func ($2) a function within that library
#  lflags ($3) flags to link to library, defaults to -l$1 if not given
#
# Defines the C macros $1_FUNC and $1_FUNC_ (in uppercase) to be used for
# declaring functions from library $1.

# Ideally, the function name will contain an embedded underscore but the
# macro doesn't require that because typical COIN-OR use cases (BLAS, LAPACK)
# don't have any names with embedded underscores. The default is `no extra
# underscore' (because this is tested first and will succeed if the name
# has no embedded underscore).

# The possibilities amount to
# { lower / upper case } X (no) trailing underscore X (no) extra underscore
# where the extra underscore is applied to name with an embedded underscore.


# -------------------------------------------------------------------------

AC_DEFUN([AC_COIN_NAMEMANGLING],
[
  AC_CACHE_CHECK(
    [$1 name mangling scheme],
    [m4_tolower(ac_cv_$1_namemangling)],
    [ac_save_LIBS=$LIBS
     a4_ifblank([$3], [LIBS="-l$1"], [LIBS="$3"])
     for ac_case in "lower case" "upper case" ; do
       for ac_trail in "underscore" "no underscore" ; do
         for ac_extra in "no extra underscore" "extra underscore" ; do
           m4_tolower(ac_cv_$1_namemangling)="${ac_case}, ${ac_trail}, ${ac_extra}"
           # AC_MSG_NOTICE([Attempting link for m4_tolower(ac_cv_$1_namemangling)])
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
             [ac_success=yes],
             [ac_success=no])
           # AC_MSG_RESULT([$result])
           if test $ac_success = yes ; then
             break 3
           fi
         done
       done
     done
     if test "$ac_success" = "no" ; then
       m4_tolower(ac_cv_$1_namemangling)=unknown
     fi
     LIBS=$ac_save_LIBS])

  # setup the m4_toupper($1)_FUNC and m4_toupper($1)_FUNC_ macros
  AC_COIN_DEFINENAMEMANGLING([m4_toupper($1)],[$m4_tolower(ac_cv_$1_namemangling)])

  # AC_MSG_NOTICE([Done COIN_NAMEMANGLING])
])


###########################################################################
#                            COIN_TRY_LINK                                #
###########################################################################

# This is a helper macro for checking if a library can be linked based on
# a function name only.
#   COIN_TRY_LINK(func,lflags,pcfiles,action-if-success,action-if-failed)
#  func ($1) the name of the function to try to link
#  lflags ($2) linker flags to use
#  pcfiles ($3) pc files to query for additional linker flags
#  action-if-success ($4) commands to execute if any linking was successful
#  action-if-failed ($5) commands to execute if no linking was successful
# 
# The macro tries different name mangling schemes and expands into
# action-if-success for the first one that succeeds.
# It sets variable func_namemangling according to the found name mangling
# scheme, which can be used as input for COIN_DEFINENAMEMANGLING.

AC_DEFUN([AC_COIN_TRY_LINK],
[
  # setup LIBS by adding $2 and those from $3
  ac_save_LIBS="$LIBS"
  m4_ifnblank([$2], [LIBS="$2 $LIBS"])
  m4_ifnblank([$3],
    [AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])
     temp_LFLAGS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --libs $3`
     LIBS="$temp_LFLAGS $LIBS"
    ])

  $1_namemangling=unknown

  # FIXME we had "extra underscore" as additional option for ac_extra
  #   but since there is no use for ac_extra below, was there any use for it?
  for ac_extra in "no extra underscore" ; do
    for ac_case in "lower case" "upper case" ; do
      for ac_trail in "underscore" "no underscore" ; do
        #AC_MSG_NOTICE([Attempting link for ${ac_case}, ${ac_trail}, ${ac_extra}])
        case $ac_case in
          "lower case")
            ac_name=m4_tolower($1)
            ;;
          "upper case")
            ac_name=m4_toupper($1)
            ;;
        esac
        if test "$ac_trail" = underscore ; then
          ac_name=${ac_name}_
        fi
        AC_MSG_CHECKING([for function $ac_name in $LIBS])
        AC_LINK_IFELSE(
          [AC_LANG_PROGRAM(
            [#ifdef __cplusplus
             extern "C"
             #endif
             void $ac_name();],
            [$ac_name()])],
          [$1_namemangling="${ac_case}, ${ac_trail}, ${ac_extra}"
           ac_success=yes],
          [ac_success=no])
        AC_MSG_RESULT([$ac_success])
        if test $ac_success = yes ; then
          break 3
        fi
      done
    done
  done
  LIBS=$ac_save_LIBS

  if test $ac_success = yes ; then
    m4_ifblank([$4],[:],[$4])
    m4_ifnblank([$5],[else $5])
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
      pkg_version=`$PKG_CONFIG --version`
      AC_MSG_RESULT([yes: $pkg_version])
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
# correctly. Unless the user specifies --prefix, prefix is set to
# NONE until the end of configuration, at which point it will be set to
# $ac_default_prefix. Unless the user specifies --exec-prefix, exec-prefix
# is set to NONE until the end of configuration, at which point it's set to
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
      m4_toupper($1)_VERSIONS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --modversion "$2" 2>/dev/null | tr '\n' ' '`
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
#                          COIN_CHK_HERE                                  #
###########################################################################

# COIN_CHK_HERE([prim],[client packages],[pcfile])

# Augment the _LFLAGS, _CFLAGS, and _PCFILES variables of the client
# packages with the values from PRIM_LFLAGS_PUB, PRIM_CFLAGS_PUB, and
# PRIM_PCFILES_PUB. This macro is intended for the case where a single project
# builds several objects and one object includes another. For example,
# the various OsiXxxLib solvers, which depend on OsiLib. We can't consult
# osi.pc (it's not installed yet) but the relevant variables are ready at
# hand. The name of prim is often different from the name of the .pc file
# ($3), hence the separate parameter.

# This macro should be called after FINALIZE_FLAGS is invoked for the
# client packages, for two reasons: First, COIN packages tend to use
# .pc files, so we're probably adding a package to _PCFILES that isn't yet
# installed. Also, FINALIZE_FLAGS will have accessed the .pc files already
# in _PCFILES and expanded them into _LIBS and _CFLAGS, saving the original
# _LIBS and _CFLAGS in _LIBS_NOPC and _CFLAGS_NOPC.

AC_DEFUN([AC_COIN_CHK_HERE],
[

# Make sure the necessary variables exist for each client package.

  m4_foreach_w([myvar],[$2],
    [AC_SUBST(m4_toupper(myvar)_LFLAGS)
     AC_SUBST(m4_toupper(myvar)_CFLAGS)
     AC_SUBST(m4_toupper(myvar)_PCFILES)
    ])

# Add the .pc file and augment LFLAGS and CFLAGS.

    m4_foreach_w([myvar],[$2],
      [m4_toupper(myvar)_PCFILES="$m4_toupper(myvar)_PCFILES $3"
       m4_toupper(myvar)_LFLAGS="$m4_toupper(myvar)_LFLAGS $m4_toupper($1)_LFLAGS"
       m4_toupper(myvar)_CFLAGS="$m4_toupper(myvar)_CFLAGS $m4_toupper($1)_CFLAGS"

# Define BUILDTOOLS_DEBUG to enable debugging output

       if test "$BUILDTOOLS_DEBUG" = 1 ; then
         AC_MSG_NOTICE([CHK_HERE adding $1 to myvar:])
         AC_MSG_NOTICE([m4_toupper(myvar)_PCFILES: "${m4_toupper(myvar)_PCFILES}"])
         AC_MSG_NOTICE([m4_toupper(myvar)_LFLAGS: "${m4_toupper(myvar)_LFLAGS}"])
         AC_MSG_NOTICE([m4_toupper(myvar)_CFLAGS: "${m4_toupper(myvar)_CFLAGS}"])
       fi
      ])

])   # COIN_CHK_HERE

###########################################################################
#                      COIN_DEF_PRIM_ARGS                                 #
###########################################################################

# COIN_DEF_PRIM_ARGS([prim],[base],[lflags],[cflags],[dflags],[build])

# This is a utility macro to handle the standard arguments that COIN-OR
# configuration files supply for a component (package or library):
#   --with-prim: use primitive (yes / no / special)
#   --with-prim-lflags: linker flags for the primitive
#   --with-prim-cflags: preprocessor & compiler flags for the primitive
#   --with-prim-data: data directory for the primitive
# These arguments allow the user to override default macro behaviour from the
# configure command line.
# The string prim, lower-cased, is used in the flag name.
# The parameters base, lflags, cflags, and dflags have the value yes or no and
# determine whether a --with option will be defined for prim, lflags, cflags,
# and data, respectively. They must be literals, as the macro uses them to cut
# out unused options. To use the results, construct the name of the shell
# variable as specified in the autoconf doc'n for ARG_WITH.

# Setting the final parameter to 'build' will cause the phrase "'build' will
# look for a COIN ThirdParty package" to be inserted in the documentation for
# --with-prim.

AC_DEFUN([AC_COIN_DEF_PRIM_ARGS],
[
  m4_define([extraHelp],[
    m4_normalize(Use $1. [If an argument is given,]
      ['yes' is equivalent to --with-m4_tolower($1),]
      m4_case($6,build,
      ['no' is equivalent to --without-m4_tolower($1)[,]
       'build' will look for a COIN ThirdParty package.],
      ['no' is equivalent to --without-m4_tolower($1).])
      m4_case($3$4$5,nonono,,
        nonoyes,
        Any other argument is applied as for --with-m4_tolower($1)-data,
        noyesno,
        Any other argument is applied as for --with-m4_tolower($1)-cflags,
        noyesyes,
        Any other argument is applied as for --with-m4_tolower($1)-cflags,
        Any other argument is applied as for --with-m4_tolower($1)-lflags))])

  m4_if($2,yes,
    [AC_ARG_WITH([m4_tolower($1)],
       AS_HELP_STRING([--with-m4_tolower($1)],extraHelp))])

  m4_if($3,yes,
    [AC_ARG_WITH([m4_tolower($1)-lflags],
       AS_HELP_STRING([--with-m4_tolower($1)-lflags],
         [Linker flags for $1 appropriate for your environment.
          (Most often, -l specs for libraries.)]))])

  m4_if($4,yes,
    [AC_ARG_WITH([m4_tolower($1)-cflags],
       AS_HELP_STRING([--with-m4_tolower($1)-cflags],
         [Compiler flags for $1 appropriate for your environment.
          (Most often, -I specs for header file directories.)]))])

  m4_if($5,yes,
    [AC_ARG_WITH([m4_tolower($1)-data],
       AS_HELP_STRING([--with-m4_tolower($1)-data],
         [A data directory specification for $1 appropriate for your
          environment.]))])
])   # COIN_DEF_PRIM_ARGS


###########################################################################
#                     COIN_FIND_PRIM_PKG                                  #
###########################################################################
# COIN_FIND_PRIM_PKG([prim],[.pc file name],[default action],[cmdlineopts])

# Determine whether we can use primary package prim ($1) and assemble
# information on the required library flags (prim_lflags), compiler flags
# (prim_cflags), and data directories (prim_data) as specified by cmdlineopts.

# cmdlineopts ($4) specifies the set of configure command line options
# defined and processed: 'nodata' produces --with-prim, --with-prim-libs, and
# --with-prim-cflags; 'dataonly' produces --with-prim and --with-prim-data;
# anything else ('all' works well) produces all four command line
# options. Shell code produced by the macro is tailored based on
# cmdlineopts. `nodata' is the default.

# --with-prim is interpreted as follows: --with-prim=no is equivalent to
# --without-prim. Any of --with-prim, --with-prim=yes, or --with-prim=build,
# cause the macro to look for a .pc file. Any other value is taken as
# equivalent to --with-prim-data=value (dataonly) or --with-prim-lflags=value
# (anything else).

# The algorithm first checks for a user-specified value of --with-prim;
# if this is no, prim is skipped. Next, it looks for user specified values
# given with command line parameters --with-prim-lflags, --with-prim-cflags,
# and --with-prim-data. If none of these are specified, it will look for a
# .pc file for prim using PKG_CONFIG.

# Default action ($3) (no, yes, build) is the default action if the user
# offers no guidance via command line parameters. The (hardwired) default is
# yes.

# If no .pc file names are specified, the macro will look for prim.pc if the
# default is yes, coinprim.pc if the default is build.  If a .pc file name
# ($2) is specified, but is not "skip", it overrides the macro defaults.
# If $2=skip, then checks for .pc files are skipped.

# Note that for the
# majority of COIN packages, you should not specify `build' as .pc files
# for most COIN packages are simply the package name (e.g., clp.pc). For
# ThirdParty packages, this works (e.g., coinglpk.pc).

# The macro doesn't test that the specified values actually work. This is
# deliberate.  There's no guarantee that user-specified libraries and/or
# directories actually exist yet. The same possibility exists for values
# returned when pkgconf checks the .pc file.

AC_DEFUN([AC_COIN_FIND_PRIM_PKG],
[
  AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])

  dflt_action=m4_default([$3],[yes])

# Initialize variables for the primary package.

  m4_tolower(coin_has_$1)=noInfo
  m4_tolower($1_lflags)=
  m4_tolower($1_cflags)=
  m4_tolower($1_data)=
  m4_tolower($1_pcfiles)=

# --with-prim is always present. If the client specified dataonly, its value
# is assigned to prim_data.

  withval=$m4_tolower(with_$1)
  if test -n "$withval" ; then
    case "$withval" in
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
        m4_if(m4_default($4,nodata),dataonly,
          [m4_tolower($1_data)=$withval],
          [m4_tolower($1_lflags)=$withval])
        ;;
    esac
  fi

# --with-prim-libs and --with-prim-cflags are present unless the client
# specified dataonly. Specifying --with-prim=no overrides the individual
# options for libs and cflags.

  m4_if(m4_default($4,nodata),dataonly,[],
    [if test "$m4_tolower(coin_has_$1)" != skipping ; then
       withval=$m4_tolower(with_$1_lflags)
       if test -n "$withval" ; then
         case "$withval" in
           build | no | yes )
             AC_MSG_ERROR(["$withval" is not valid here; please specify linker flags appropriate for your environment.])
             ;;
           * )
             m4_tolower(coin_has_$1)=yes
             m4_tolower($1_lflags)=$withval
             ;;
         esac
       fi

       withval=$m4_tolower(with_$1_cflags)
       if test -n "$withval" ; then
         case "$withval" in
           build | no | yes )
             AC_MSG_ERROR(["$withval" is not valid here; please specify compiler flags appropriate for your environment.])
             ;;
           * )
             m4_tolower(coin_has_$1)=yes
             m4_tolower($1_cflags)="$withval"
             ;;
         esac
       fi
     fi])

# --with-prim-data will be present unless the client specified nodata.
# Specifying --with-prim=no overrides the individual option for data.

  m4_if(m4_default($4,nodata),nodata,[],
    [if test "$m4_tolower(coin_has_$1)" != skipping ; then
       withval=$m4_tolower(with_$1_data)
       if test -n "$withval" ; then
         case "$withval" in
           build | no | yes )
             AC_MSG_ERROR(["$withval" is not valid here; please give a data directory specification appropriate for your environment.])
             ;;
           * )
             m4_tolower(coin_has_$1)=yes
             m4_tolower($1_data)="$withval"
             ;;
         esac
       fi
     fi])

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
      if test -n "$PKG_CONFIG" -a "$2" != skip ; then
        m4_ifnblank($2,
          [pcfile="$2"],
          [if test $m4_tolower(coin_has_$1) = build ; then
             pcfile=m4_tolower(coin$1)
           else
             pcfile=m4_tolower($1)
           fi])
        AC_COIN_CHK_MOD_EXISTS([$1],[$pcfile],
          [m4_tolower(coin_has_$1)=yes
           m4_tolower($1_data)=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --variable=datadir "$pcfile" 2>/dev/null`
           m4_tolower($1_pcfiles)="$pcfile"],
          [m4_tolower(coin_has_$1)=no])
      else
        m4_tolower(coin_has_$1)=no
        # AC_MSG_WARN([skipped check via pkgconf as no pkgconf available])
      fi
      ;;
    skipping | yes )
      ;;
    * )
      AC_MSG_WARN([Unexpected status "$m4_tolower(coin_has_$1)" in COIN_FIND_PRIM_PKG])
      ;;
  esac

# The final value of coin_has_prim will be yes, no, or skipping. No means
# we looked (with pkgconfig) and didn't find anything. Skipping means the
# user said `don't use.' Yes means we have something, from the user or
# from pkgconfig. Note that we haven't run a useability test!

# Define BUILDTOOLS_DEBUG to enable debugging output

    if test "$BUILDTOOLS_DEBUG" = 1 ; then
      AC_MSG_NOTICE([FIND_PRIM_PKG result for $1: "$m4_tolower(coin_has_$1)"])
      AC_MSG_NOTICE([Collected values for package '$1'])
      AC_MSG_NOTICE([m4_tolower($1_lflags) is "$m4_tolower($1_lflags)"])
      AC_MSG_NOTICE([m4_tolower($1_cflags) is "$m4_tolower($1_cflags)"])
      AC_MSG_NOTICE([m4_tolower($1_data) is "$m4_tolower($1_data)"])
      AC_MSG_NOTICE([m4_tolower($1_pcfiles) is "$m4_tolower($1_pcfiles)"])
    fi

])  # COIN_FIND_PRIM_PKG

###########################################################################
#                          COIN_CHK_PKG                                   #
###########################################################################

# COIN_CHK_PKG([prim],[client packages],[.pc file name],
#              [default action],[cmdopts])

# Determine whether we can use primary package prim ($1) and assemble
# information on the required linker flags (prim_lflags), compiler flags
# (prim_cflags), and data directories (prim_data).

# The configure command line options offered to the user are controlled
# by cmdopts ($5). 'nodata' offers --with-prim, --with-prim-lflags, and
# --with-prim-cflags. 'dataonly' offers --with-prim and --with-prim-data.
# 'all' offers all four. DEF_PRIM_ARGS and FIND_PRIM_PKG are tailored
# accordingly. The (hardwired) default is 'nodata'.

# Default action ($4) (no, yes, build) is the default action if the user
# offers no guidance via command line parameters. Really, 'build' has no hope
# of working except for COIN ThirdParty packages. Don't use it for other COIN
# packages.

# If no .pc file names are specified, the macro will look for prim.pc if the
# default is yes, coinprim.pc if the default is build.  If a .pc file name
# ($3) is specified, it overrides the macro defaults.

# Define an automake conditional COIN_HAS_PRIM to record the result. If we
# decide to use prim, also define a preprocessor symbol COIN_HAS_PRIM.

# Linker and compiler flag information will be propagated to the space-
# separated list of client packages ($2) using the _PCFILES variable if
# a .pc file is used, otherwise by the _LFLAGS and _CFLAGS variables of
# client packages. These variables match Requires.private, Libs.private,
# and Cflags.private, respectively, in a .pc file.

# Data directory information is used differently. Typically what's wanted is
# individual variables specifying the data directory for each primitive. Hence
# the macro defines PRIM_DATA for the primitive.

# The macro doesn't test that the specified values actually work. This is
# deliberate.  There's no guarantee that user-specified libraries and/or
# directories actually exist yet. The same possibility exists for values
# returned when pkgconf checks the .pc file.

AC_DEFUN([AC_COIN_CHK_PKG],
[
  AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])

  AC_MSG_CHECKING([for package $1])

# Make sure the necessary variables exist for each client package.

  m4_foreach_w([myvar],[$2],
    [AC_SUBST(m4_toupper(myvar)_LFLAGS)
     AC_SUBST(m4_toupper(myvar)_CFLAGS)
     AC_SUBST(m4_toupper(myvar)_PCFILES)
    ])

# Check to see if the user has set an override to skip this primary.

  m4_tolower(coin_has_$1)=noInfo
  if test x"$COIN_SKIP_PROJECTS" != x ; then
    for pkg in $COIN_SKIP_PROJECTS ; do
      if test "$m4_tolower(pkg)" = "$m4_tolower($1)" ; then
        m4_tolower(coin_has_$1)=skipping
      fi
    done
  fi

# If we're not skipping this primary, define and process the command line
# options according to the cmdopts parameter. Then invoke FIND_PRIM_PKG to do
# the heavy lifting.

  if test "$m4_tolower(coin_has_$1)" != skipping ; then
    m4_case(m4_default($5,nodata),
      nodata,[AC_COIN_DEF_PRIM_ARGS([$1],yes,yes,yes,no,$4)],
      dataonly,[AC_COIN_DEF_PRIM_ARGS([$1],yes,no,no,yes,$4)],
      [AC_COIN_DEF_PRIM_ARGS([$1],yes,yes,yes,yes,$4)])
    AC_COIN_FIND_PRIM_PKG(m4_tolower($1),[$3],[$4],[$5])
    AC_MSG_RESULT([$m4_tolower(coin_has_$1)])
  else
    AC_MSG_RESULT([$m4_tolower(coin_has_$1) due to COIN_SKIP_PROJECTS])
  fi

# Possibilities are `yes', 'no', or `skipping'. Normalise to `yes' or `no'.

  if test "$m4_tolower(coin_has_$1)" != yes ; then
    m4_tolower(coin_has_$1)=no
  fi

# Create an automake conditional COIN_HAS_PRIM.

  AM_CONDITIONAL(m4_toupper(COIN_HAS_$1),
                   [test $m4_tolower(coin_has_$1) = yes])

# If we've located the package, define preprocessor symbol COIN_HAS_PRIM and
# augment the necessary variables for the client packages.

  if test $m4_tolower(coin_has_$1) = yes ; then
    AC_DEFINE(m4_toupper(COIN_HAS_$1),[1],
      [Define to 1 if $1 is available.])
    m4_foreach_w([myvar],[$2],
      [m4_toupper(myvar)_PCFILES="$m4_tolower($1_pcfiles) $m4_toupper(myvar)_PCFILES"
       m4_toupper(myvar)_LFLAGS="$m4_tolower($1_lflags) $m4_toupper(myvar)_LFLAGS"
       m4_toupper(myvar)_CFLAGS="$m4_tolower($1_cflags) $m4_toupper(myvar)_CFLAGS"
      ])

# Finally, set up PRIM_DATA, unless the user specified nodata.

    m4_if(m4_default([$5],nodata),nodata,[],
      [AC_SUBST(m4_toupper($1)_DATA)
       m4_toupper($1)_DATA=$m4_tolower($1_data)])
  fi
])   # COIN_CHK_PKG


###########################################################################
#                          FIND_PRIM_LIB                                  #
###########################################################################

# COIN_FIND_PRIM_LIB([prim],[lflgs],[cflgs],[dflgs],
#                    [func],[other libraries],
#                    [dfltaction],[cmdlineopts])

# Determine whether we can use primary library prim ($1) and assemble
# information on the required linker flags (prim_lflags), compiler flags
# (prim_cflags), and data directories (prim_data) as specified by cmdlineopts.
# Run a link check if the user provides [func]. Linker flags for the link are
# the concatenation of [lflgs] and [other libraries].

# cmdlineopts ($8) specifies the set of configure command line options
# defined and processed: 'nodata' produces --with-prim, --with-prim-lflags,
# and --with-prim-cflags; 'dataonly' produces only --with-prim and
# --with-prim-data; anything else ('all' works well) produces all four
# command line options. Shell code produced by the macro is tailored based
# on cmdlineopts. `nodata' is the default.

# --with-prim is interpreted as follows:
#   * --with-prim=no is equivalent to --without-prim.
#   * --with-prim or --with-prim=yes is equivalent to
#       --with-prim-lflags=-lprim
#       --with-prim-data=/usr/local/share
#   * --with-prim=build attempts to invent something that will find a COIN
#     ThirdParty library or data
#       --with-prim-lflags="-L\$(libdir) -lcoinprim"
#       --with-prim-cflgs="-I\$(pkgincludedir)/ThirdParty"
#       --with-prim-data="\$(pkgdatadir)"
#   * Any other value is taken as equivalent to
#       --with-prim-data=value (dataonly) or
#       --with-prim-lflags=value (anything else)

# The algorithm first checks for a user-specified value of --with-prim;
# if this is no, prim is skipped. Next, it looks for user specified values
# given with command line parameters --with-prim-lflags, --with-prim-cflags,
# and --with-prim-data. If none of these are specified, it will use the values
# passed as parameters. It's all or none: any command line options disable all
# parameters.

# Default action ($7) (no, yes, build) is the default value of --with-prim
# if the user offers no guidance via command line parameters. The (hardwired)
# default is yes. `build' doesn't have a hope of working except for COIN
# ThirdParty packages, and even then it's pretty shaky. You should be
# using CHK_PKG, because COIN packaging for ThirdParty software creates a .pc
# file.

# The macro doesn't test that the specified values actually work unless
# [func] is given as a parameter. This is deliberate --- there's no guarantee
# that the specified library can be accessed just yet with the specified
# flags. Except for the link check, all we're doing here is filling in
# variables using a complicated algorithm.

AC_DEFUN([AC_COIN_FIND_PRIM_LIB],
[
  dflt_action=m4_default([$7],[yes])

# Initialize variables for the primary library.

  m4_tolower(coin_has_$1)=noInfo
  m4_tolower($1_lflags)=
  m4_tolower($1_cflags)=
  m4_tolower($1_data)=

# --with-prim is always present. If the client specified dataonly, its value
# is assigned to prim_data.

  withval=$m4_tolower(with_$1)
  if test -n "$withval" ; then
    case "$withval" in
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
        m4_if(m4_default($8,nodata),dataonly,
          [m4_tolower($1_data)=$withval],
          [m4_tolower($1_lflags)=$withval])
        ;;
    esac
  fi

# --with-prim-lflags and --with-prim-cflags are present unless the client
# specified dataonly. Specifying --with-prim=no overrides the individual
# options for lflags and cflags.

  m4_if(m4_default($8,nodata),dataonly,[],
    [if test "$m4_tolower(coin_has_$1)" != skipping ; then
       withval=$m4_tolower(with_$1_lflags)
       if test -n "$withval" ; then
         case "$withval" in
           build | no | yes )
             AC_MSG_ERROR(["$withval" is not valid here; please specify linker flags appropriate for your environment.])
             ;;
           * )
             m4_tolower(coin_has_$1)=yes
             m4_tolower($1_lflags)=$withval
             ;;
         esac
       fi

       withval=$m4_tolower(with_$1_cflags)
       if test -n "$withval" ; then
         case "$withval" in
           build | no | yes )
             AC_MSG_ERROR(["$withval" is not valid here; please specify compiler flags appropriate for your environment.])
             ;;
           * )
             m4_tolower(coin_has_$1)=yes
             m4_tolower($1_cflags)="$withval"
             ;;
         esac
       fi
     fi])

# --with-prim-data will be present unless the client specified nodata.
# Specifying --with-prim=no overrides the individual option for data.

  m4_if(m4_default($8,nodata),nodata,[],
    [if test "$m4_tolower(coin_has_$1)" != skipping ; then
       withval=$m4_tolower(with_$1_data)
       if test -n "$withval" ; then
         case "$withval" in
           build | no | yes )
             AC_MSG_ERROR(["$withval" is not valid here; please give a data directory specification appropriate for your environment.])
             ;;
           * )
             m4_tolower(coin_has_$1)=yes
             m4_tolower($1_data)="$withval"
             ;;
         esac
       fi
     fi])

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

# Now coin_has_prim can be one of skipping, yes, build, or requested. For
# build or requested, use the parameter values or invent some.

  case $m4_tolower(coin_has_$1) in
    build | requested)
      m4_if(m4_default($8,nodata),dataonly,[],
        [m4_ifnblank([$2],
           [m4_tolower($1_lflags)=$2],
           [if test "$m4_tolower(coin_has_$1)" = build ; then
              m4_tolower($1_lflags)="-L\$(libdir) -l[]m4_tolower(coin$1)"
            else
              m4_tolower($1_lflags)="-l[]m4_tolower($1)"
            fi])
         m4_ifnblank([$3],
           [m4_tolower($1_cflags)=$3],
           [if test "$m4_tolower(coin_has_$1)" = build ; then
              m4_tolower($1_cflags)="-I\$(pkgincludedir)/ThirdParty"
            fi])])
      m4_if(m4_default($8,nodata),nodata,[],
        [m4_tolower($1_data)=m4_default([$3],
           [if test "$m4_tolower(coin_has_$1)" = build ; then
              m4_tolower($1_data)="\$(pkgdatadir)"
            else
              m4_tolower($1_data)="/usr/local/share"
            fi])])
      m4_tolower(coin_has_$1)=yes
      ;;
    skipping | yes )
      ;;
    * )
      AC_MSG_WARN([Unexpected status "$m4_tolower(coin_has_$1)" in COIN_FIND_PRIM_LIB])
      ;;
  esac

# At this point, coin_has_prim is yes or skipping.  Time to run a link check,
# if we have a function ($5). Use whatever we've collected for lflags, plus
# other libraries ($6) as the other libraries parameter to AC_SEARCH_LIBS,
# leaving the library parameter blank.

  if test $m4_tolower(coin_has_$1) != skipping ; then
    m4_ifnblank([$5],
      [ac_save_LIBS=$LIBS
       LIBS="$m4_tolower($1_lflags) $6"
       AC_LINK_IFELSE(
        [AC_LANG_PROGRAM(
          [#ifdef __cplusplus
             extern "C"
           #endif
           void $5();],
          [$5()])],
       [],
       [m4_tolower(coin_has_$1)=no])
       LIBS=$ac_save_LIBS],
      [:])
  fi

# The final value of coin_has_prim will be yes, no, or skipping. No means that
# the link check failed. Yes means that we passed the link check, or no link
# check was performed. Skipping means the user said `don't use.'

# Define BUILDTOOLS_DEBUG to enable debugging output

    if test "$BUILDTOOLS_DEBUG" = 1 ; then
      AC_MSG_NOTICE([FIND_PRIM_LIB result for $1: "$m4_tolower(coin_has_$1)"])
      AC_MSG_NOTICE([Collected values for package '$1'])
      AC_MSG_NOTICE([m4_tolower($1_lflags) is "$m4_tolower($1_lflags)"])
      AC_MSG_NOTICE([m4_tolower($1_cflags) is "$m4_tolower($1_cflags)"])
      AC_MSG_NOTICE([m4_tolower($1_data) is "$m4_tolower($1_data)"])
      AC_MSG_NOTICE([m4_tolower($1_pcfiles) is "$m4_tolower($1_pcfiles)"])
    fi

])  # COIN_FIND_PRIM_LIB

###########################################################################
#                          COIN_CHK_LIB                                   #
###########################################################################

# COIN_CHK_LIB([prim],[client packages],[lflgs],[cflgs],[dflgs],
#              [func],[other libraries],
#              [dfltaction],[cmdopts])

# Determine whether we can use primary library prim ($1) and assemble
# information on the required linker flags (prim_lflags), compiler flags
# (prim_cflags), and data directories (prim_data). A link check will be
# performed in COIN_FIND_PRIMN_LIB if [func] is specified, using link flags
# formed by concatenating the values of [lflgs] and [other libraries].

# The configure command line options offered to the user are controlled
# by cmdopts ($9). 'nodata' offers --with-prim, --with-prim-lflags, and
# --with-prim-cflags; 'dataonly' offers --with-prim and --with-prim-data;
# 'all' offers all four. DEF_PRIM_ARGS and FIND_PRIM_LIB are tailored
# accordingly. The (hardwired) default is 'nodata'.

# Macro parameters lflgs ($3), cflgs ($4), and dflgs ($5) are used for
# --with-prim-lflags, --with-prim-cflags, and --with-prim-data if and only if
# there are no user-supplied values on the command line. It's all or nothing;
# any user-supplied value causes all macro parameters to be ignored.

# Default action ($8) (no, yes, build) is the default action if the user
# offers no guidance via command line parameters. Really, 'build' has no
# hope of working except for COIN ThirdParty packages. Don't use it for
# other COIN packages. You should be using CHK_PKG because COIN packaging
# for ThirdParty software creates a .pc file.

# Define an automake conditional COIN_HAS_PRIM to record the result. If we
# decide to use prim, also define a preprocessor symbol COIN_HAS_PRIM.

# Linker and compiler flag information will be propagated to the space-
# separated list of client packages ($2) using the _LFLAGS and _CFLAGS
# variables of client packages. These variables match Libs.private and
# Cflags.private, respectively, in a .pc file.

# Data directory information is used differently. Typically what's wanted is
# individual variables specifying the data directory for each primitive. Hence
# the macro defines PRIM_DATA for the primitive.

AC_DEFUN([AC_COIN_CHK_LIB],
[
  AC_MSG_CHECKING([for package $1])

# Make sure the necessary variables exist for each client package.

  m4_foreach_w([myvar],[$2],
    [AC_SUBST(m4_toupper(myvar)_LFLAGS)
     AC_SUBST(m4_toupper(myvar)_CFLAGS)
    ])

# Check to see if the user has overridden configure parameters from the
# environment.

  m4_tolower(coin_has_$1)=noInfo
  if test x"$COIN_SKIP_PROJECTS" != x ; then
    for pkg in $COIN_SKIP_PROJECTS ; do
      if test "$m4_tolower(pkg)" = "$m4_tolower($1)" ; then
        m4_tolower(coin_has_$1)=skipping
      fi
    done
  fi

# If we're not skipping this project, define and process the command line
# options according to the cmdopts parameter. Then invoke FIND_PRIM_PKG to do
# the heavy lifting.

  if test "$m4_tolower(coin_has_$1)" != skipping ; then
    m4_case(m4_default($9,nodata),
      nodata,[AC_COIN_DEF_PRIM_ARGS([$1],yes,yes,yes,no,$4)],
      dataonly,[AC_COIN_DEF_PRIM_ARGS([$1],yes,no,no,yes,$4)],
      [AC_COIN_DEF_PRIM_ARGS([$1],yes,yes,yes,yes,$4)])
    AC_COIN_FIND_PRIM_LIB(m4_tolower($1),[$3],[$4],[$5],[$6],[$7],[$8],[$9])
    AC_MSG_RESULT([$m4_tolower(coin_has_$1)])
  else
    AC_MSG_RESULT([$m4_tolower(coin_has_$1) due to COIN_SKIP_PROJECTS])
  fi

# Possibilities are `yes', `no', or `skipping'. Normalise to `yes' or `no'.

  if test "$m4_tolower(coin_has_$1)" != yes ; then
    m4_tolower(coin_has_$1)=no
  fi

# Create an automake conditional COIN_HAS_PRIM.

  AM_CONDITIONAL(m4_toupper(COIN_HAS_$1),
                   [test $m4_tolower(coin_has_$1) = yes])

# If we've located the package, define preprocessor symbol COIN_HAS_PRIM
# and augment the necessary variables for the client packages.

  if test $m4_tolower(coin_has_$1) = yes ; then
    AC_DEFINE(m4_toupper(COIN_HAS_$1),[1],
      [Define to 1 if the $1 package is available])
    m4_foreach_w([myvar],[$2],
      [m4_toupper(myvar)_LFLAGS="$m4_tolower($1_lflags) $m4_toupper(myvar)_LFLAGS"
       m4_toupper(myvar)_CFLAGS="$m4_tolower($1_cflags) $m4_toupper(myvar)_CFLAGS"
      ])

# Finally, set up PRIM_DATA, unless the user specified nodata.

    m4_if(m4_default([$9],nodata),nodata,[],
      [AC_SUBST(m4_toupper($1)_DATA)
       m4_toupper($1)_DATA=$m4_tolower($1_data)])
  fi
])   # COIN_CHK_LIB


#######################################################################
#                           COIN_CHK_LIBM                           #
#######################################################################

# COIN_CHK_LIBM([client1 client2 ...])
# Check if a library spec is needed for the math library. If something is
# needed, the macro adds the flags to CLIENT_LFLAGS for each client.

AC_DEFUN([AC_COIN_CHK_LIBM],
[
  AC_REQUIRE([AC_PROG_CC])

  coin_save_LIBS="$LIBS"
  LIBS=
  AC_SEARCH_LIBS([cos],[m],
    [if test "$ac_cv_search_cos" != 'none required' ; then
       m4_foreach_w([myvar],[$1],
         [m4_toupper(myvar)_LFLAGS="$ac_cv_search_cos $m4_toupper(myvar)_LFLAGS"
         ])
     fi])
  LIBS="$coin_save_LIBS"
]) # AC_COIN_CHK_LIBM

###########################################################################
#                           COIN_CHK_ZLIB                               #
###########################################################################

# COIN_CHK_ZLIB([client1 client2 ...])

# This macro checks for the libz library.  If found, it sets the automake
# conditional COIN_HAS_ZLIB and defines the C preprocessor variable
# COIN_HAS_ZLIB. The default is to use zlib, if it's present.  For each client,
# it adds the linker flags to the variable CLIENT_LFLAGS for each client.

AC_DEFUN([AC_COIN_CHK_ZLIB],
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
        [m4_toupper(myvar)_LFLAGS="-lz $m4_toupper(myvar)_LFLAGS"
        ])
      AC_DEFINE([COIN_HAS_ZLIB],[1],[Define to 1 if zlib is available])
    fi
  fi

  AM_CONDITIONAL([COIN_HAS_ZLIB],[test x$coin_has_zlib = xyes])
]) # AC_COIN_CHK_ZLIB


###########################################################################
#                            COIN_CHK_BZLIB                             #
###########################################################################

# COIN_CHK_BZLIB([client1 client2 ...])

# This macro checks for the libbz2 library.  If found, it defines the
# C preprocessor variable COIN_HAS_BZLIB and the automake conditional
# COIN_HAS_BZLIB.  Further, for a (space separated) list of clients, it adds
# the linker flag to the variable CLIENT_LFLAGS for each client.

AC_DEFUN([AC_COIN_CHK_BZLIB],
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
        [m4_toupper(myvar)_LFLAGS="-lbz2 $m4_toupper(myvar)_LFLAGS"
        ])
      AC_DEFINE([COIN_HAS_BZLIB],[1],[Define to 1 if bzlib is available])
    fi
  fi

  AM_CONDITIONAL([COIN_HAS_BZLIB],[test x$coin_has_bzlib = xyes])
]) # AC_COIN_CHK_BZLIB


###########################################################################
#                              COIN_CHK_GMP                             #
###########################################################################

# COIN_CHK_GMP([client1 client2 ...])

# This macro checks for the gmp library.  If found, it defines the C
# preprocessor variable COIN_HAS_GMP and the automake conditional COIN_HAS_GMP.
# Further, for a (space separated) list of clients, it adds the linker
# flag to the variable CLIENT_LFLAGS for each client.

AC_DEFUN([AC_COIN_CHK_GMP],
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
        [m4_toupper(myvar)_LFLAGS="-lgmp $m4_toupper(myvar)_LFLAGS"
        ])
      AC_DEFINE([COIN_HAS_GMP],[1],[Define to 1 if GMP is available])
    fi
  fi

  AM_CONDITIONAL([COIN_HAS_GMP],[test x$coin_has_gmp = xyes])
]) # AC_COIN_CHK_GMP


###########################################################################
#                         COIN_CHK_GNU_READLINE                         #
###########################################################################

# COIN_CHK_GNU_READLINE([client1 client2 ...])

# This macro checks for GNU's readline.  It verifies that the header
# readline/readline.h is available, and that the -lreadline library contains
# "readline".  It is assumed that #include <stdio.h> is included in the source
# file before the #include<readline/readline.h> If found, it defines the C
# preprocessor variable COIN_HAS_READLINE.  Further, for a (space separated)
# list of clients, it adds the linker flag to the variable CLIENT_LFLAGS for
# each client.

AC_DEFUN([AC_COIN_CHK_GNU_READLINE],
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
        [m4_toupper(myvar)_LFLAGS="-lreadline $m4_toupper(myvar)_LFLAGS"
        ])
      AC_DEFINE([COIN_HAS_READLINE],[1],[Define to 1 if readline is available])
    fi
    LIBS="$coin_save_LIBS"
  fi

  AM_CONDITIONAL([COIN_HAS_READLINE],[test x$coin_has_readline = xyes])
]) # AC_COIN_CHK_GNU_READLINE


###########################################################################
#                       COIN_CHK_LAPACK                                   #
###########################################################################

# COIN_CHK_LAPACK([client packages])

# This macro checks for a LAPACK library and adds the information necessary to
# use it to the _LFLAGS, _CFLAGS, and _PCFILES variables of the client packages
# passed as a space-separated list in parameter $1. These correspond to
# Libs.private, Cflags.private, and Requires.private, respectively, in a .pc
# file.

# The algorithm first invokes FIND_PRIM_PKG. The parameters --with-lapack,
# --with-lapack-lflags, and --with-lapack-cflags are interpreted there. If
# nothing is found, default locations are checked.
# A link check is used to determine whether default locations work and to
# determine the name mangling scheme of the Lapack library.

AC_DEFUN([AC_COIN_CHK_LAPACK],
[
# Make sure the necessary variables exist for each client package.
  m4_foreach_w([myvar],[$1],
    [AC_SUBST(m4_toupper(myvar)_LIBS)
     AC_SUBST(m4_toupper(myvar)_CFLAGS)
     AC_SUBST(m4_toupper(myvar)_PCFILES)
    ])

# Set up command line arguments with DEF_PRIM_ARGS.
  AC_COIN_DEF_PRIM_ARGS([lapack],yes,yes,yes,no)

# Give FIND_PRIM_PKG a chance to look for user-specified lapack flags,
# but skip any checks via a .pc file. The result (coin_has_lapack) will
# be one of yes (the user specified something), no (user specified nothing),
# or skipping (user said do not use). We'll also have variables
# lapack_lflags, lapack_cflags, lapack_data, and lapack_pcfiles.
  AC_COIN_FIND_PRIM_PKG([lapack],[skip])

# If FIND_PRIM_PKG found something, then we'll do a link check to figure
# out whether it is working and what the name mangling scheme is.
# This sets dsyev_namemangling
  if test "$coin_has_lapack" = yes ; then
    AC_COIN_TRY_LINK([dsyev],[$lapack_lflags],[$lapack_pcfiles],,
      [AC_MSG_ERROR([Could not find dsyev in Lapack])])
  fi

# If FIND_PRIM_PKG didn't find anything, try a few more guesses for
# optimized blas/lapack libs (based on build system type).
  if test "$coin_has_lapack" = no ; then
    case $build in
      *-linux*)
         AC_COIN_TRY_LINK([dsyev],[-Wl,--start-group -lmkl_core -lmkl_intel_lp64 -lmkl_sequential --Wl,--end-group],[],[
           coin_has_lapack=yes
           lapack_lflags="-Wl,--start-group -lmkl_core -lmkl_intel_lp64 -lmkl_sequential --Wl,--end-group"])
      ;;

      *-sgi-*) 
        AC_COIN_TRY_LINK([dsyev],[-lcomplib.sgimath],[],[
          coin_has_lapack=yes
          lapack_lflags=-lcomplib.sgimath])
      ;;

      *-*-solaris*)
        # Ideally, we'd use -library=sunperf, but it's an imperfect world.
        # Studio cc doesn't recognise -library, it wants -xlic_lib. Studio 12
        # CC doesn't recognise -xlic_lib. Libtool doesn't like -xlic_lib
        # anyway. Sun claims that CC and cc will understand -library in Studio
        # 13. The main extra function of -xlic_lib and -library is to arrange
        # for the Fortran run-time libraries to be linked for C++ and C. We
        # can arrange that explicitly.
        AC_COIN_TRY_LINK([dsyev],[-lsunperf],[],[
          coin_has_lapack=yes
          lapack_lflags=-lsunperf])
      ;;

      *-cygwin* | *-mingw* | *-msys*)
        case "$CC" in
          */compile\ cl | cl | */cl | */compile\ icl | icl | */icl )
            # check first for 64-bit MKL, then for 32-bit MKL
            AC_COIN_TRY_LINK([dsyev],[mkl_intel_lp64.lib mkl_sequential.lib mkl_core.lib],[],[
              coin_has_lapack=yes
              lapack_lflags="mkl_intel_lp64.lib mkl_sequential.lib mkl_core.lib"],
                [AC_COIN_TRY_LINK([dsyev],[mkl_intel_c.lib mkl_sequential.lib mkl_core.lib],[],[
                 coin_has_lapack=yes
                 lapack_lflags="mkl_intel_c.lib mkl_sequential.lib mkl_core.lib"])])
          ;;
        esac
      ;;
        
      *-darwin*)
        AC_COIN_TRY_LINK([dsyev],[-Wl,--start-group -lmkl_core -lmkl_intel_lp64 -lmkl_sequential -Wl,--end-group],[],[
          coin_has_lapack=yes
          lapack_lflags="-Wl,--start-group -lmkl_core -lmkl_intel_lp64 -lmkl_sequential -Wl,--end-group"])
        if test "$coin_has_lapack" = no ; then
          AC_COIN_TRY_LINK([dsyev],[-framework Accelerate],[],[
            coin_has_lapack=yes
            lapack_lflags="-framework Accelerate"])
        fi
      ;;
    esac
  fi

# If none of the above worked, check whether lapack.pc exists and links
  if test "$coin_has_lapack" = no ; then
    AC_MSG_CHECKING([for lapack.pc])
    AC_COIN_CHK_MOD_EXISTS([lapack],[lapack],
      [AC_MSG_RESULT([yes])
       AC_COIN_TRY_LINK([dsyev],[],[lapack],
        [coin_has_lapack=yes
         lapack_pcfiles=lapack],
        [AC_MSG_ERROR([Could not find dsyev in Lapack from lapack.pc.])])],
      [AC_MSG_RESULT([no])])
  fi

# If none of the above worked, try the generic -llapack as last resort.
  if test "$coin_has_lapack" = no ; then
    AC_COIN_TRY_LINK([dsyev],[-llapack],[],[
      coin_has_lapack=yes
      lapack_lflags=-llapack])
  fi

# Time to set some variables. Create an automake conditional COIN_HAS_LAPACK.
  AM_CONDITIONAL(m4_toupper(COIN_HAS_LAPACK),[test $coin_has_lapack = yes])

# If we've located the package, define preprocessor symbol COIN_HAS_LAPACK
# and COIN_LAPACK_FUNC[_] and augment the necessary variables for the client packages.
  if test $coin_has_lapack = yes ; then
    AC_DEFINE(m4_toupper(COIN_HAS_LAPACK),[1],
      [Define to 1 if the LAPACK package is available])
    AC_COIN_DEFINENAMEMANGLING([COIN_LAPACK], ${dsyev_namemangling})
    m4_foreach_w([myvar],[$1],
      [m4_toupper(myvar)_PCFILES="$lapack_pcfiles $m4_toupper(myvar)_PCFILES"
       m4_toupper(myvar)_LFLAGS="$lapack_lflags $m4_toupper(myvar)_LFLAGS"
       m4_toupper(myvar)_CFLAGS="$lapack_cflags $m4_toupper(myvar)_CFLAGS"
      ])
  fi
]) # AC_COIN_CHK_LAPACK

###########################################################################
#                           COIN_DOXYGEN                                  #
###########################################################################

# This macro determines the configuration information for doxygen, the tool
# used to generate online documentation of COIN code. It takes one parameter,
# a list of projects (mixed-case, to match the install directory names) that
# should be processed as external tag files. E.g., COIN_DOXYGEN([Clp Osi]).

# This macro will define the following variables:
#  coin_have_doxygen        Yes if doxygen is found, no otherwise
#  coin_doxy_usedot     Defaults to `yes'; --with-dot will still check to see
#                        if dot is available
#  coin_doxy_tagname        Name of doxygen tag file (placed in doxydoc directory)
#  coin_doxy_logname    Name of doxygen log file (placed in doxydoc directory)
#  coin_doxy_tagfiles   List of doxygen tag files used to reference other
#                       doxygen documentation

# It's not immediately obvious, but the code in this macro, configure-time
# substitions in doxygen.conf.in, and build-time edits of doxygen.conf in
# Makemain.inc combine to hardwire the assumptions that a tag file is named
# proj_doxy.tag, that PKG_TARNAME is coin-or-proj, and that the doxygen
# documentation is in the GNU default location $(docdir)/$PKG_TARNAME. Have
# a look over the complete machinery before you start changing things. The
# point of the build-time edits is to allow the user to redefine docdir at
# build time, as per GNU standards. Failure to use coin-or-proj as PKG_TARNAME
# will surely break linking of documentation with tag files.

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

# Generate a tag file name and a log file name.

lc_pkg=`echo ${PACKAGE_NAME} | [tr [A-Z] [a-z]]`
AC_SUBST([coin_doxy_tagname],[${lc_pkg}_doxy.tag])
AC_SUBST([coin_doxy_logname],[${lc_pkg}_doxy.log])
AM_CONDITIONAL(COIN_HAS_DOXYGEN, [test $coin_have_doxygen = yes])
AM_CONDITIONAL(COIN_HAS_LATEX, [test $coin_have_latex = yes])

# Process the list of project names and massage each one into the name of
# a tag file. The value of coin_doxy_tagfiles is substituted for TAGFILES
# in doxygen.conf.in. Further substitution for @baredocdir_nosub@ will happen
# as an edit during make install. See comments in Makemain.inc.

coin_doxy_tagfiles=
tmp="$1"
for proj in $tmp ; do
  lc_proj=`echo $proj | [tr [A-Z] [a-z]]`
  doxytag=${lc_proj}_doxy.tag
  doxydir="@baredocdir_nosub@/coin-or-${lc_proj}/doxydoc"
  coin_doxy_tagfiles="$coin_doxy_tagfiles $doxydir/$doxytag=$doxydir/html"
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

# COIN_FINALIZE_FLAGS([prim1 prim2 ...])

# For each PRIM, produce final versions of variables specifying linker and
# compiler flags.  PRIM_LFLAGS_NOPC and PRIM_CFLAGS_NOPC are appropriate for
# use in .pc files together with PRIM_PCFILES. PRIM_LFLAGS and PRIM_CFLAGS
# are augmented to contain flags obtained by invoking PKG_CONFIG on packages
# listed in PRIM_PCFILES and are appropriate for use in Makefile.am files.

# TODO this could be moved into COIN_FINALIZE, if we were able to remember
#   for which variables we need to run pkg-config

AC_DEFUN([AC_COIN_FINALIZE_FLAGS],
[
  m4_foreach_w([myvar],[$1],
    [ if test "$BUILDTOOLS_DEBUG" = 1 ; then
        AC_MSG_NOTICE([FINALIZE_FLAGS for myvar:])
      fi
      AC_SUBST(m4_toupper(myvar)_LFLAGS_NOPC,[$m4_toupper(myvar)_LFLAGS])
      AC_SUBST(m4_toupper(myvar)_CFLAGS_NOPC,[$m4_toupper(myvar)_CFLAGS])
      if test -n "${m4_toupper(myvar)_PCFILES}" ; then
        temp_CFLAGS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --cflags ${m4_toupper(myvar)_PCFILES}`
        temp_LFLAGS=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --libs ${m4_toupper(myvar)_PCFILES}`
        m4_toupper(myvar)_CFLAGS="$temp_CFLAGS ${m4_toupper(myvar)_CFLAGS}"
        m4_toupper(myvar)_LFLAGS="$temp_LFLAGS ${m4_toupper(myvar)_LFLAGS}"
      fi

      # setup XYZ_EXPORT symbol for library users
      libexport_attribute=
      if test "$enable_shared" = yes ; then
        # TODO better check for this? we essentially want to know whether we're building DLLs
        # or do we also need this for GCC on Windows?
        case $CC in */compile\ cl | cl | */cl | */compile\ icl | icl | */icl )
          libexport_attribute="__declspec(dllimport)"
          if test "$enable_static" = yes ; then
            AC_MSG_ERROR([Cannot do DLL and static LIB builds simultaneously. Do not add --enable-static without --disable-shared.])
          fi
        esac
      fi
      AC_DEFINE_UNQUOTED(m4_toupper(myvar)_EXPORT, [$libexport_attribute], [Library Visibility Attribute])

# Define BUILDTOOLS_DEBUG to enable debugging output

      if test "$BUILDTOOLS_DEBUG" = 1 ; then
        AC_MSG_NOTICE(
          [m4_toupper(myvar)_LFLAGS_NOPC: "${m4_toupper(myvar)_LFLAGS_NOPC}"])
        AC_MSG_NOTICE(
          [m4_toupper(myvar)_CFLAGS_NOPC: "${m4_toupper(myvar)_CFLAGS_NOPC}"])
        AC_MSG_NOTICE([adding "${m4_toupper(myvar)_PCFILES}"])
        AC_MSG_NOTICE([m4_toupper(myvar)_LFLAGS: "${m4_toupper(myvar)_LFLAGS}"])
        AC_MSG_NOTICE([m4_toupper(myvar)_CFLAGS: "${m4_toupper(myvar)_CFLAGS}"])
      fi
    ])
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

