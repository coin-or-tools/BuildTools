# Copyright (C) 2006 International Business Machines..
# All Rights Reserved.
# This file is distributed under the Common Public License.
#
## $Id: coin.m4,v 1.1.2.1 2006/04/19 23:25:12 andreasw Exp $
#
# Author: Andreas Wachter    IBM      2006-04-14

# This file defines the common autoconf macros for COIN
#

# Check requirements
AC_PREREQ(2.59)

###########################################################################
#                           COIN_MAIN_SUBDIRS                             #
###########################################################################

# This macro sets up the recursion into configure scripts into
# subdirectories.  Each possible subdirectory should be provided as a
# new argument to this macro.  The current limit is 10 subdirectories.
# This automatically also checks for the Data subdirectory.

AC_DEFUN([AC_COIN_MAIN_SUBDIRS],
[coin_subdirs=
m4_ifvaln([$1],[AC_MSG_CHECKING(whether directory $1 is available)
                if test -r $srcdir/$1/configure; then
                  coin_subdirs="$coin_subdirs $1"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($1)
                else
                  AC_MSG_RESULT(no)
                fi])
m4_ifvaln([$2],[AC_MSG_CHECKING(whether directory $2 is available)
                if test -r $srcdir/$2/configure; then
                  coin_subdirs="$coin_subdirs $2"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($2)
                else
                  AC_MSG_RESULT(no)
                fi])
m4_ifvaln([$3],[AC_MSG_CHECKING(whether directory $3 is available)
                if test -r $srcdir/$3/configure; then
                  coin_subdirs="$coin_subdirs $3"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($3)
                else
                  AC_MSG_RESULT(no)
                fi])
m4_ifvaln([$4],[AC_MSG_CHECKING(whether directory $4 is available)
                if test -r $srcdir/$4/configure; then
                  coin_subdirs="$coin_subdirs $4"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($4)
                else
                  AC_MSG_RESULT(no)
                fi])
m4_ifvaln([$5],[AC_MSG_CHECKING(whether directory $5 is available)
                if test -r $srcdir/$5/configure; then
                  coin_subdirs="$coin_subdirs $5"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($5)
                else
                  AC_MSG_RESULT(no)
                fi])
m4_ifvaln([$6],[AC_MSG_CHECKING(whether directory $6 is available)
                if test -r $srcdir/$6/configure; then
                  coin_subdirs="$coin_subdirs $6"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($6)
                else
                  AC_MSG_RESULT(no)
                fi])
m4_ifvaln([$7],[AC_MSG_CHECKING(whether directory $7 is available)
                if test -r $srcdir/$7/configure; then
                  coin_subdirs="$coin_subdirs $7"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($7)
                else
                  AC_MSG_RESULT(no)
                fi])
m4_ifvaln([$8],[AC_MSG_CHECKING(whether directory $8 is available)
                if test -r $srcdir/$8/configure; then
                  coin_subdirs="$coin_subdirs $8"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($8)
                else
                  AC_MSG_RESULT(no)
                fi])
m4_ifvaln([$9],[AC_MSG_CHECKING(whether directory $9 is available)
                if test -r $srcdir/$9/configure; then
                  coin_subdirs="$coin_subdirs $9"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($9)
                else
                  AC_MSG_RESULT(no)
                fi])
m4_ifvaln([$10],[AC_MSG_CHECKING(whether directory $10 is available)
                if test -r $srcdir/$10/configure; then
                  coin_subdirs="$coin_subdirs $10"
                  AC_MSG_RESULT(yes)
                  AC_CONFIG_SUBDIRS($10)
                else
                  AC_MSG_RESULT(no)
                fi])
]) # AC_COIN_MAIN_SUBDIRS

###########################################################################
#                           COIN_CHECK_VPATH                              #
###########################################################################

# This macro sets the variable coin_vpath_config to true if this is a
# VPATH configuration, otherwise it sets it to false.
AC_DEFUN([AC_COIN_CHECK_VPATH],
[AC_MSG_CHECKING(whether this is a VPATH configuration)
if test `cd $srcdir; pwd` != `pwd`; then
  coin_vpath_config=yes;
else
  coin_vpath_config=no;
fi
AC_MSG_RESULT($coin_vpath_config)
]) # AC_COIN_CHECK_VPATH

###########################################################################
#                           COIN_SRCDIR_INIT                              #
###########################################################################

# This macro does everything that is required in the early part in the
# configure script, such as defining a few variables.

AC_DEFUN([AC_COIN_SRCDIR_INIT],
[# Initialize the ADDLIBS variable (a number of library require -lm)
ADDLIBS="" #"-lm"
AC_SUBST(ADDLIBS)

# A useful makefile conditional that is always false
AM_CONDITIONAL(ALWAYS_FALSE, false)

# A makefile conditional that is set to true if 
]) # AC_COIN_SRCDIR_INIT

###########################################################################
#                          COIN_DEBUG_COMPILE                             #
###########################################################################

# enable the configure flag --enable-debug and set the variable
# coin_debug_compile to true or false
# This is used by COIN_PROG_CXX, COIN_PROG_CC and COIN_PROG_F77
# to determine the compilation flags.
# It defines the #define macro COIN_DEBUG if it is chosen, and the makefile
# conditional COIN_DEBUG is defined

AC_DEFUN([AC_COIN_DEBUG_COMPILE],
[AC_BEFORE([$0],[AC_COIN_PROG_CXX])dnl
AC_BEFORE([$0],[AC_COIN_PROG_CC])dnl
AC_BEFORE([$0],[AC_COIN_PROG_F77])dnl

AC_MSG_CHECKING([whether we want to compile in debug mode])

AC_ARG_ENABLE([debug],
[AC_HELP_STRING([--enable-debug],
                [compile with debug options and runtime tests])],
                [case "${enableval}" in
                   yes) coin_debug_compile=true
                     AC_DEFINE([COIN_DEBUG],[1],
                               [If defined, debug sanity checks are performed during runtime])
                     ;;
                   no)  coin_debug_compile=false
                     ;;
                    *) AC_MSG_ERROR(bad value ${enableval} for --enable-debug)
                     ;;
                 esac],
                [coin_debug_compile=false])

if test $coin_debug_compile = true; then
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no])
fi

AM_CONDITIONAL([COIN_DEBUG],[test "$coin_debug_compile" = true])
]) # AC_COIN_DEBUG_COMPILE


###########################################################################
#                             COIN_PROG_CXX                               #
###########################################################################

# Find the compile command by running AC_PROG_CXX (with compiler names
# for different operating systems) and put it into CXX (unless it was
# given my the user), and find an appropriate value for CXXFLAGS.  It is
# possible to provide additional -D flags in the variable CXXDEFS.

AC_DEFUN([AC_COIN_PROG_CXX],
[AC_LANG_PUSH(C++)

AC_ARG_VAR(CXXDEFS,[Additional -D flags to be used when compiling C++ code.])

coin_has_cxx=yes

save_cxxflags="$CXXFLAGS"
case $build in
  *-cygwin* | *-mingw*)
             comps="g++ cl" ;;
  *-darwin*) comps="g++ c++ CC" ;;
          *) comps="xlC aCC CC g++ c++ pgCC icpc" ;;
esac
AC_PROG_CXX([$comps])
CXXFLAGS="$save_cxxflags"

AC_CACHE_CHECK([for C++ compiler options],[coin_cv_cxxflags],
[if test x"$CXXFLAGS" = x; then

# ToDo decide whether we want -DNDEBUG for optimization
  coin_add_cxxflags=
  coin_opt_cxxflags=
  coin_dbg_cxxflags=
  coin_warn_cxxflags=

  if test "$GXX" = "yes"; then
    case "$CXX" in
      icpc | */icpc)
        ;;
      *)
# ToDo decide about unroll-loops
        coin_opt_cxxflags="-O3 -fomit-frame-pointer"
        coin_add_cxxflags="-pipe"
        coin_dbg_cxxflags="-g"
        coin_warn_cxxflags="-pedantic-errors -Wimplicit -Wparentheses -Wreturn-type -Wcast-qual -Wall -Wpointer-arith -Wwrite-strings -Wconversion"

        case $build in
          *-cygwin*)
            CXXFLAGS="-mno-cygwin"
            AC_TRY_LINK([],[int i=0; i++;],
                        [coin_add_cxxflags="-mno-cygwin $coin_add_cxxflags"])
            CXXFLAGS=
            ;;
        esac
        ;;
    esac
  fi
  if test -z "$coin_opt_cxxflags"; then
    case $build in
      *-cygwin* | *-mingw*)
        case "$CXX" in
          cl | */cl)
            coin_opt_cxxflags='-Ot1'
            coin_add_cxxflags='-nologo -EHsc -GR -MT'
            coin_dbg_cxxflags='-Yd'
            ;;
        esac
        ;;
      *-linux-*)
        case "$CXX" in
          icpc | */icpc)
            coin_opt_cxxflags="-O3 -ip"
            coin_add_cxxflags=""
            coin_dbg_cxxflags="-g"
            # Check if -i_dynamic is necessary (for new glibc library)
            CXXFLAGS=
            AC_TRY_LINK([],[int i=0; i++;],[],
                        [coin_add_cxxflags="-i_dynamic $coin_add_cxxflags"])
            ;;
          pgCC | */pgCC)
            coin_opt_cxxflags="-fast"
            coin_add_cxxflags="-Kieee -pc 64"
            coin_dbg_cxxflags="-g"
            ;;
        esac
        ;;
      *-ibm-*)
        case "$CXX" in
          xlC* | */xlC* | mpxlC* | */mpxlC*)
            coin_opt_cxxflags="-O3 -qarch=auto -qcache=auto -qhot -qtune=auto -qmaxmem=-1"
            coin_add_cxxflags="-bmaxdata:0x80000000 -qrtti=dyna"
            coin_dbg_cxxflags="-g"
            ;;
        esac
        ;;
      *-hp-*)
        case "$CXX" in
          aCC | */aCC )
            coin_opt_cxxflags="-O"
            coin_add_cxxflags="-AA"
            coin_dbg_cxxflags="-g"
            ;;
        esac
        ;;
      *-sun-*)
          coin_opt_cxxflags="-O4 -xtarget=native"
          coin_dbg_cxxflags="-g"
        ;;
    esac
  fi

  if test "$ac_cv_prog_cxx_g" = yes && test -z "$coin_dbg_cxxflags" ; then
    coin_dbg_cxxflags="-g"
  fi

  if test "$coin_debug_compile" = "true"; then
    CXXFLAGS="$coin_dbg_cxxflags $coin_add_cxxflags $coin_warn_cxxflags"
  else
    if test -z "$coin_opt_cxxflags"; then
      # Try if -O option works if nothing else is set
      CXXFLAGS="-O"
      AC_TRY_LINK([],[int i=0; i++;],[coin_opt_cxxflags="-O"])
    fi
    CXXFLAGS="$coin_opt_cxxflags $coin_add_cxxflags -DNDEBUG $CXXDEFS $coin_warn_cxxflags"
  fi
fi

# Try if CXXFLAGS works
AC_TRY_LINK([],[int i=0; i++;],[],[CXXFLAGS=])
if test -z "$CXXFLAGS"; then
  AC_MSG_WARN([The flags CXXFLAGS="$CXXFLAGS" do not work.  I will now just try '-O', but you might want to set CXXFLAGS manually.])
  CXXFLAGS='-O'
  AC_TRY_LINK([],[int i=0; i++;],[],[CXXFLAGS=])
  if test -z "$CXXFLAGS"; then
    AC_MSG_WARN([This value for CXXFLAGS does not work.  I will continue with empty CXXFLAGS, but you might want to set CXXFLAGS manually.])
  fi
fi
coin_cv_cxxflags="$CXXFLAGS"
]) # AC_CACHE_CHECK([for C++ compiler options CXXFLAGS]
CXXFLAGS="$coin_cv_cxxflags"

AC_LANG_POP(C++)
]) # AC_COIN_PROG_CXX


###########################################################################
#                             COIN_CXXLIBS                                #
###########################################################################

# Determine the C++ runtime libraries required for linking a C++ library
# with a Fortran or C compiler.  The result is available in CXXLIBS.

AC_DEFUN([AC_COIN_CXXLIBS],
[AC_REQUIRE([AC_PROG_CXX])dnl
AC_LANG_PUSH(C++)
AC_ARG_VAR(CXXLIBS,[Libraries necessary for linking C++ code with Fortran compiler])
if test -z "$CXXLIBS"; then
  if test "$GXX" = "yes"; then
    case "$CXX" in
      icpc | */icpc)
        CXXLIBS=""
        ;;
      *)
        CXXLIBS="-lstdc++ -lm" # -lgcc"
        ;;
    esac
  else
    case $build in
     *-linux-*)
      case "$CXX" in
      icpc | */icpc)
        CXXLIBS=""
             ;;
      pgCC | */pgCC)
        CXXLIBS="-lstd -lC -lc"
             ;;
      esac;;
    *-ibm-*)
      CXXLIBS="-lC -lc"
      ;;
    *-hp-*)
      CXXLIBS="-L/opt/aCC/lib -l++ -lstd_v2 -lCsup_v2 -lm -lcl -lc"
      ;;
    *-sun-*)
      CXXLIBS="-lCstd -lCrun"
    esac
  fi
fi
if test -z "$CXXLIBS"; then
  AC_MSG_WARN([Could not automatically determine CXXLIBS (C++ link libraries; necessary if main program is in Fortran of C).])
else
  AC_MSG_NOTICE([Assuming that CXXLIBS is \"$CXXLIBS\".])
fi
AC_LANG_POP(C++)
]) # AC_COIN_CXXLIBS

###########################################################################
#                           COIN_CHECK_HEADER                             #
###########################################################################

# This macro checks for a header file, but it does so without the
# standard header.  This avoids warning messages like:
#
# configure: WARNING: dlfcn.h: present but cannot be compiled
# configure: WARNING: dlfcn.h:     check for missing prerequisite headers?
# configure: WARNING: dlfcn.h: see the Autoconf documentation
# configure: WARNING: dlfcn.h:     section "Present But Cannot Be Compiled"
# configure: WARNING: dlfcn.h: proceeding with the preprocessor's result
# configure: WARNING: dlfcn.h: in the future, the compiler will take precedence

AC_DEFUN([AC_COIN_CHECK_HEADER],
[if test x"$4" = x; then
  hdr="#include <$1>"
else
  hdr="$4"
fi
AC_CHECK_HEADERS([$1],[$2],[$3],[$hdr])
]) # AC_COIN_CHECK_HEADER

###########################################################################
#                       COIN_CHECK_CXX_CHEADER                             #
###########################################################################

# This macro checks for C header files that are used from C++.  For a give
# stub (e.g., math), it first checks if the C++ library (cmath) is available.
# If it is, it defines HAVE_CMATH (or whatever the stub is).  If it is not
# available, it checks for the old C head (math.h) and defines HAVE_MATH_H
# if that one exists.

AC_DEFUN([AC_COIN_CHECK_CXX_CHEADER],
[AC_LANG_PUSH(C++)
AC_COIN_CHECK_HEADER([c$1],[$2],[$3],[$4])
if test "$ac_cv_header_c$1" != "yes"; then
  AC_COIN_CHECK_HEADER([$1.h],[$2],[$3],[$4])
fi
AC_LANG_POP(C++)
]) # AC_COIN_CHECK_CXX_CHEADER

###########################################################################
#                             COIN_PROG_CC                                #
###########################################################################

# Find the compile command by running AC_PROG_CC (with compiler names
# for different operating systems) and put it into CC (unless it was
# given my the user), and find an appropriate value for CFLAGS.  It is
# possible to provide additional -D flags in the variable CDEFS.

AC_DEFUN([AC_COIN_PROG_CC],
[AC_LANG_PUSH(C)

AC_ARG_VAR(CDEFS,[Additional -D flags to be used when compiling C code.])

coin_has_cc=yes

save_cflags="$CFLAGS"
case $build in
  *-cygwin* | *-mingw*)
             comps="gcc cl" ;;
  *-linux-*) comps="xlc gcc cc pgcc icc" ;;
  *)         comps="xlc cc gcc pgcc icc" ;;
esac
AC_PROG_CC([$comps])
CFLAGS="$save_cflags"

AC_CACHE_CHECK([for C compiler options],[coin_cv_cflags],
[if test x"$CFLAGS" = x; then

  coin_add_cflags=
  coin_opt_cflags=
  coin_dbg_cflags=
  coin_warn_cflags=

  if test "$GCC" = "yes"; then
    case "$CC" in
      icc | */icc)
        ;;
      *)
        coin_opt_cflags="-O3 -fomit-frame-pointer"
        coin_add_cflags="-pipe"
        coin_dbg_cflags="-g"
        coin_warn_cflags="-pedantic-errors -Wimplicit -Wparentheses -Wsequence-point -Wreturn-type -Wcast-qual -Wall"

        case $build in
          *-cygwin*)
            CFLAGS="-mno-cygwin"
            AC_TRY_LINK([],[int i=0; i++;],
                        [coin_add_cflags="-mno-cygwin $coin_add_cflags"])
            CFLAGS=
          ;;
        esac
        ;;
    esac
  fi
  if test -z "$coin_opt_cflags"; then
    case $build in
      *-cygwin* | *-mingw*)
        case "$CC" in
          cl | */cl)
            coin_opt_cflags='-Ot1'
            coin_add_cflags='-nologo'
            coin_dbg_cflags='-Yd'
            ;;
        esac
        ;;
      *-linux-*)
        case "$CC" in
          icc | */icc)
            coin_opt_cflags="-O3 -ip"
            coin_add_cflags=""
            coin_dbg_cflags="-g"
            # Check if -i_dynamic is necessary (for new glibc library)
            CFLAGS=
            AC_TRY_LINK([],[int i=0; i++;],[],
                        [coin_add_cflags="-i_dynamic $coin_add_cflags"])
            ;;
          pgcc | */pgcc)
            coin_opt_cflags="-fast"
            coin_add_cflags="-Kieee -pc 64"
            coin_dbg_cflags="-g"
            ;;
        esac
        ;;
      *-ibm-*)
        case "$CC" in
          xlc* | */xlc* | mpxlc* | */mpxlc*)
            coin_opt_cflags="-O3 -qarch=auto -qcache=auto -qhot -qtune=auto -qmaxmem=-1"
            coin_add_cflags="-bmaxdata:0x80000000"
            coin_dbg_cflags="-g"
          ;;
        esac
        ;;
      *-hp-*)
        coin_opt_cflags="-O"
        coin_add_cflags="-Ae"
        coin_dbg_cflags="-g"
        ;;
      *-sun-*)
        coin_opt_cflags="-xO4 -xtarget=native"
        coin_dbg_cflags="-g"
        ;;
      *-sgi-*)
        coin_opt_cflags="-O -OPT:Olimit=0"
        coin_dbg_cflags="-g"
        ;;
    esac
  fi

  if test "$ac_cv_prog_cc_g" = yes && test -z "$coin_dbg_cflags" ; then
    coin_dbg_cflags="-g"
  fi

  if test "$coin_debug_compile" = "true"; then
    CFLAGS="$coin_dbg_cflags $coin_add_cflags $coin_warn_cflags"
  else
    if test -z "$coin_opt_cflags"; then
      # Try if -O option works if nothing else is set
      CFLAGS="-O"
      AC_TRY_LINK([],[int i=0; i++;],[coin_opt_cflags="-O"],[])
    fi
    CFLAGS="$coin_opt_cflags $coin_add_cflags -DNDEBUG $CDEFS $coin_warn_cflags"
  fi
fi

# Try if CFLAGS works
AC_TRY_LINK([],[int i=0; i++;],[],[CFLAGS=])
if test -z "$CFLAGS"; then
  AC_MSG_WARN([The value CFLAGS="$CFLAGS" do not work.  I will now just try '-O', but you might want to set CFLAGS manually.])
  CFLAGS='-O'
  AC_TRY_LINK([],[int i=0; i++;],[],[CFLAGS=])
  if test -z "$CFLAGS"; then
    AC_MSG_WARN([This value for CFLAGS does not work.  I will continue with empty CFLAGS, but you might want to set CFLAGS manually.])
  fi
fi
coin_cv_cflags="$CFLAGS"
]) # AC_CACHE_CHECK([for C compiler options CXXFLAGS]
CFLAGS="$coin_cv_cflags"

AC_LANG_POP(C)
]) # AC_COIN_PROG_CC

###########################################################################
#                             COIN_PROG_F77                               #
###########################################################################

# Find the compile command by running AC_PROG_F77 (with compiler names
# for different operating systems) and put it into F77 (unless it was
# given my the user), and find an appropriate value for FFLAGS

AC_DEFUN([AC_COIN_PROG_F77],
[AC_LANG_PUSH([Fortran 77])

coin_has_f77=yes

save_fflags="$FFLAGS"
case $build in
  *-cygwin* | *-mingw*)
             comps="gfortran g77 ifort" ;;
  *)         comps="xlf fort77 gfortran f77 g77 pgf90 pgf77 ifort ifc" ;;
esac
AC_PROG_F77($comps)
FFLAGS="$save_fflags"

AC_CACHE_CHECK([for Fortran compiler options],[coin_cv_fflags],
[if test x"$FFLAGS" = x; then

  coin_add_fflags=
  coin_opt_fflags=
  coin_dbg_fflags=
  coin_warn_fflags=

  if test "$G77" = "yes"; then
    coin_opt_fflags="-O3 -fomit-frame-pointer"
    coin_add_fflags="-pipe"
    coin_dbg_fflags="-g"
    case $build in
      *-cygwin*)
        FFLAGS="-mno-cygwin"
        AC_TRY_LINK([],[      write(*,*) 'Hello world'],
                    [coin_add_fflags="-mno-cygwin $coin_add_fflags"])
        FFLAGS=
      ;;
    esac
  else
    case $build in
      *-cygwin* | *-mingw*)
        case $F77 in
          ifort | */ifort)
            coin_opt_fflags='-O3'
            coin_add_fflags='-nologo'
            coin_dbg_fflags='-debug'
          ;;
        esac
        ;;
      *-linux-*)
        case $F77 in
          ifc | */ifc | ifort | */ifort)
            coin_opt_fflags="-O3 -ip"
            coin_add_fflags="-cm -w90 -w95"
            coin_dbg_fflags="-g -CA -CB -CS"
            # Check if -i_dynamic is necessary (for new glibc library)
            FFLAGS=
            AC_TRY_LINK([],[      write(*,*) 'Hello world'],[],
                        [coin_add_fflags="-i_dynamic $coin_add_fflags"])
            ;;
          pgf77 | */pgf77 | pgf90 | */pgf90)
            coin_opt_fflags="-fast"
            coin_add_fflags="-Kieee -pc 64"
            coin_dbg_fflags="-g"
          ;;
        esac
        ;;
      *-ibm-*)
        case $F77 in
          xlf* | */xlf* | mpxlf* | */mpxlf* )
            coin_opt_fflags="-O3 -qarch=auto -qcache=auto -qhot -qtune=auto -qmaxmem=-1"
            coin_add_fflags="-bmaxdata:0x80000000"
            coin_dbg_fflags="-g -C"
            ;;
        esac
        ;;
      *-hp-*)
        coin_opt_fflags="+O3"
        coin_add_fflags="+U77"
        coin_dbg_fflags="-C -g"
        ;;
      *-sun-*)
        coin_opt_fflags="-O4 -xtarget=native"
        coin_dbg_fflags="-g"
        ;;
      *-sgi-*)
        coin_opt_fflags="-O5 -OPT:Olimit=0"
        coin_dbg_fflags="-g"
        ;;
    esac
  fi

  if test "$ac_cv_prog_f77_g" = yes && test -z "$coin_dbg_fflags" ; then
    coin_dbg_fflags="-g"
  fi

  if test "$coin_debug_compile" = true; then
    FFLAGS="$coin_dbg_fflags $coin_add_fflags $coin_warn_fflags"
  else
    if test -z "$coin_opt_fflags"; then
      # Try if -O option works if nothing else is set
      FFLAGS=-O
      AC_TRY_LINK([],[      integer i],
                  [coin_opt_fflags="-O"])
    fi
    FFLAGS="$coin_opt_fflags $coin_add_fflags $coin_warn_fflags"
  fi
fi

# Try if FFLAGS works
AC_TRY_LINK([],[      integer i],[],[FFLAGS=])
if test -z "$FFLAGS"; then
  AC_MSG_WARN([The flags FFLAGS="$FFLAGS" do not work.  I will now just try '-O', but you might want to set FFLAGS manually.])
  FFLAGS='-O'
  AC_TRY_LINK([],[      integer i],[],[FFLAGS=])
  if test -z "$FFLAGS"; then
    AC_MSG_WARN([This value for FFLAGS does not work.  I will continue with empty FFLAGS, but you might want to set FFLAGS manually.])
  fi
fi
coin_cv_fflags="$FFLAGS"
]) # AC_CACHE_CHECK([for Fortran compiler options FFLAGS]
FFLAGS="$coin_cv_fflags"

AC_LANG_POP([Fortran 77])
]) # AC_COIN_PROG_F77

###########################################################################
#                           COIN_F77_WRAPPERS                             #
###########################################################################

# Calls autoconfs AC_F77_WRAPPERS and does additional corrections to FLIBS

AC_DEFUN([AC_COIN_F77_WRAPPERS],
[AC_BEFORE([AC_COIN_PROG_F77],[$0])dnl
AC_BEFORE([AC_PROG_F77],[$0])dnl

AC_LANG_PUSH([Fortran 77])

AC_F77_WRAPPERS

# This is to correct a missing exclusion in autoconf 2.59
if test x"$FLIBS" != x; then
  my_flibs=
  for flag in $FLIBS; do
    case flag in
      -lcrt*.o) ;;
             *) my_flibs="$my_flibs $flag" ;;
    esac
  done
  FLIBS="$my_flibs"
fi

case $build in
# The following is a fix to define FLIBS for ifort on Windows
   *-cygwin* | *-mingw*)
     case $F77 in
       ifort | */ifort)
           FLIBS="/link libifcorert.lib $LIBS /NODEFAULTLIB:libc.lib";;
     esac;;
   *-hp-*)
       FLIBS="$FLIBS -lm";;
   *-ibm-*)
       FLIBS=`echo $FLIBS | sed 's/-lc)/-lc/g'` ;;
   *-linux-*)
     case "$F77" in
       pgf77 | */pgf77 | pgf90 | */pgf90)
# ask linker to go through the archives multiple times
# (the Fortran compiler seems to do that automatically...
         FLIBS="-Wl,--start-group $FLIBS -Wl,--end-group" ;;
     esac
esac

]) # AC_COIN_F77_WRAPPERS


###########################################################################
#                          COIN_INIT_AUTOMAKE                             #
###########################################################################

# This macro calls the regular INIT_AUTOMAKE and MAINTAINER_MODE
# macros, and defines additional variables and makefile conditionals,
# that are used in the maintainer parts of the makfile.  It also
# checks if the correct versions of the autotools are used.

AC_DEFUN([AC_COIN_INIT_AUTOMAKE],
[AC_REQUIRE([AC_PROG_EGREP])
# Stuff for automake
AM_INIT_AUTOMAKE
AM_MAINTAINER_MODE

coin_have_externals=no
coin_maintainer_small=no
if test "$enable_maintainer_mode" = yes; then

  # If maintainer mode is chosen, we make sure that the correct versions
  # of the tools are used, and that we know where libtoo.m4 is (to
  # recreate acinclude.m4)

  AC_SUBST(LIBTOOLM4)
  LIBTOOLM4=

  # Check if we have autoconf
  AC_CHECK_PROG([have_autoconf],[autoconf],[yes],[no])
  if test $have_autoconf = no; then
    AC_MSG_ERROR([You specified you want to use maintainer mode, but I cannot find autoconf in your path.])
  fi

  # Check whether autoconf is the correct version
  correct_version='2.59'
  grep_version=`echo  $correct_version | sed -e 's/\\./\\\\\\./g'`
  AC_MSG_CHECKING([whether we are using the correct version ($correct_version) of autoconf])
  autoconf --version > confauto.out 2>&1
  if $EGREP $grep_version confauto.out >/dev/null 2>&1; then
    AC_MSG_RESULT([yes])
  else
    rm -f confauto.out
    AC_MSG_RESULT([no])
    AC_MSG_ERROR([You don't have the correct version of autoconf as the first one in your path.])
  fi
  rm -f confauto.out

  # Check if we have automake
  AC_CHECK_PROG([have_automake],[automake],[yes],[no])
  if test $have_automake = no; then
    AC_MSG_ERROR([You specified you want to use maintainer mode, but I cannot find automake in your path.])
  fi
  
  # Check whether automake is the correct version
  correct_version='1.9.6'
  grep_version=`echo  $correct_version | sed -e 's/\\./\\\\\\./g'`
  AC_MSG_CHECKING([whether we are using the correct version ($correct_version) of automake])
  automake --version > confauto.out 2>&1
  if $EGREP $grep_version confauto.out >/dev/null 2>&1; then
    AC_MSG_RESULT([yes])
  else
    rm -f confauto.out
    AC_MSG_RESULT([no])
    AC_MSG_ERROR([You don't have the correct version of automake as the first one in your path.])
  fi
  rm -f confauto.out

  # Check if we can find the libtool file
  if test "${LIBTOOLPREFIX:+set}" != set; then
    for p in $HOME ; do
      AC_CHECK_FILE([$p/share/aclocal/libtool.m4],
                    [LIBTOOLM4="$p/share/aclocal/libtool.m4"
                     LIBTOOLPREFIX="$p"],)
      if test x"$LIBTOOLM4" != x; then
        break;
      fi
    done
    if test x"$LIBTOOLM4" = x; then
      AC_MSG_ERROR([You specified you want to use maintainer mode, but I cannot find the file libtool.m4 on your system.  Please set the prefix of the location of the correct file with the LIBTOOLPREFIX variable, so that it is in $LIBTOOLPREFIX/share/aclocal.  We assume here that it is the plain version obtained from the GNU tarball.])
    fi
  else
    AC_CHECK_FILE([$LIBTOOLPREFIX/share/aclocal/libtool.m4],
                  [LIBTOOLM4="$LIBTOOLPREFIX/share/aclocal/libtool.m4"],
                  [AC_MSG_ERROR([You specified LIBTOOLPREFIX, but I cannot find the file libtool.m4 in $LIBTOOLPREFIX/share/aclocal.])])
  fi

  # Check if this is the correct version of libtool (with escaped dots)
  correct_version='1.5.22'
  grep_version=`echo  $correct_version | sed -e 's/\\./\\\\\\./g'`
  AC_CHECK_FILE([$LIBTOOLPREFIX/share/libtool/ltmain.sh],
	        [have_ltmain=yes],
                [have_ltmain=no])
  AC_MSG_CHECKING([whether we are using the correct version ($correct_version) of libtool.])
  if test $have_ltmain = yes; then
    if $EGREP $grep_version $LIBTOOLPREFIX/share/libtool/ltmain.sh >/dev/null 2>&1; then
      AC_MSG_RESULT([yes])
    else
      AC_MSG_RESULT([no])
      AC_MSG_ERROR([You don't have the correct version of libtool.  Please set LIBTOOLPREFIX to the correct installation prefix, so that the correct version of ltmain.sh is in $LIBTOOLPREFIX/share/libtool.])
    fi
  else
    AC_MSG_ERROR([I cannot find the file ltmain.sh in $LIBTOOLPREFIX/share/libtool])
  fi  

  # Check if we have an Externals file
  if test -r $srcdir/Externals; then
    coin_have_externals=yes
  fi

  # Check if this is a limited project (without config.guess)
  if test -r $srcdir/config.guess; then :; else
    coin_maintainer_small=yes
  fi

  # Find the location of the BuildTools directory
  BUILDTOOLSDIR=
  if test -r $srcdir/BuildTools/coin.m4; then
    BUILDTOOLSDIR=$srcdir/BuildTools
  else
    if test -r $srcdir/../BuildTools/coin.m4; then
      BUILDTOOLSDIR=$srcdir/../BuildTools
    else
      if test -r $srcdir/../../BuildTools/coin.m4; then
        BUILDTOOLSDIR=$srcdir/../../BuildTools
      else
        AC_MSG_ERROR(Cannot find the BuildTools directory)
      fi
    fi
  fi
  AC_SUBST(BUILDTOOLSDIR)

  # The following variable is set to the name of the directory where
  # the autotool scripts are located
  AC_SUBST(AUX_DIR)
  AUX_DIR=$ac_aux_dir
fi
AM_CONDITIONAL(HAVE_EXTERNALS,test $coin_have_externals = yes)
AM_CONDITIONAL(MAINTAINER_SMALL,test $coin_maintainer_small = yes)
]) # AC_COIN_INIT_AUTOMAKE



###########################################################################
#                         COIN_INIT_AUTO_TOOLS                            #
###########################################################################

# Initialize the auto tools automake and libtool, with all
# modifications we want for COIN packages.
#
# This also defines the AC_SUBST variables:
# pkg_source_dir     absolute path to source code for this package
# pkg_bin_dir        absolute path to the directory where binaries are
#                    going to be installed (prefix/bin)
# pkg_lib_dir        absolute path to the directory where libraries are
#                    going to be installed (prefix/lib)
# pkg_include_dir    absolute path to the directory where the header files
#                    are installed (prefix/include)

# This is a trick to have this code before AC_COIN_PROG_LIBTOOL
AC_DEFUN([AC_COIN_DISABLE_STATIC],
[
# On Cygwin, building DLLs doesn't work
case $build in
  *-cygwin*)
    coin_disable_shared=yes
  ;;
  *-mingw*)
    case $CXX in
      cl)
        coin_disable_shared=yes
    ;;
    esac
  ;;
esac
if test x"$coin_disable_shared" = xyes; then
  if test x"$enable_shared" = xyes; then
    AC_MSG_WARN([On Cygwin, shared objects are not supported. I'm disabling your choice.])
  fi
  enable_shared=no
fi
# By default, we only want the shared objects to be compiled
AC_DISABLE_STATIC
])

AC_DEFUN([AC_COIN_INIT_AUTO_TOOLS],
[AC_BEFORE([AC_COIN_PROG_CXX],[$0])
AC_BEFORE([AC_COIN_PROG_CC],[$0])
AC_BEFORE([AC_COIN_PROG_F77],[$0])
AC_REQUIRE([AC_COIN_DISABLE_STATIC])

# Initialize automake
AC_COIN_INIT_AUTOMAKE

# Stuff for libtool
AC_COIN_PROG_LIBTOOL

# helpful variable for the base directory of this package
pkg_source_dir=`cd $srcdir; pwd`

# Stuff for example Makefiles
full_prefix=`echo $exec_prefix | pwd`
AC_SUBST(pkg_lib_dir)
pkg_lib_dir=$full_prefix/lib
AC_SUBST(pkg_include_dir)
pkg_include_dir=$full_prefix/include
AC_SUBST(pkg_bin_dir)
pkg_bin_dir=$full_prefix/bin

]) # AC_COIN_INIT_AUTO_TOOLS

###########################################################################
#                           COIN_PROG_LIBTOOL                             #
###########################################################################

# Setup the libtool stuff together with any modifications to make it
# work on additional platforms

AC_DEFUN([AC_COIN_PROG_LIBTOOL],
[AC_REQUIRE([AC_COIN_DLFCN_H])

# We check for this header here in a non-standard way to avoid warning
# messages
AC_PROG_LIBTOOL

# Fix bugs in libtool script for Windows native compilation:
# - cygpath is not correctly quoted in fix_srcfile_path
# - paths generated for .lib files is not run through cygpath -w


# - lib includes subdirectory information; we want to replace
#
# old_archive_cmds="lib /OUT:\$oldlib\$oldobjs\$old_deplibs"
#
# by
#
# old_archive_cmds="echo \$oldlib | grep .libs >/dev/null; if test \$? = 0; then cd .libs; lib /OUT:\`echo \$oldlib\$oldobjs\$old_deplibs | sed -e s@\.libs/@@g\`; cd .. ; else lib /OUT:\$oldlib\$oldobjs\$old_deplibs ; fi"
#
#          -e 's%old_archive_cmds="lib /OUT:\\\$oldlib\\\$oldobjs\\\$old_deplibs"%old_archive_cmds="echo \\\$oldlib \| grep .libs >/dev/null; if test \\\$? = 0; then cd .libs; lib /OUT:\\\`echo \\\$oldlib\\\$oldobjs\\\$old_deplibs \| sed -e s@\\.libs/@@g\\\`; cd .. ; else lib /OUT:\\\$oldlib\\\$oldobjs\\\$old_deplibs; fi"%' \

# The following was a hack for chaniing @BACKSLASH to \
#          -e 'sYcompile_command=`\$echo "X\$compile_command" | \$Xsed -e '"'"'s%@OUTPUT@%'"'"'"\$output"'"'"'%g'"'"'`Ycompile_command=`\$echo "X\$compile_command" | \$Xsed -e '"'"'s%@OUTPUT@%'"'"'"\$output"'"'"'%g'"'"' | \$Xsed -e '"'"'s%@BACKSLASH@%\\\\\\\\\\\\\\\\%g'"'"'`Y' \

# Correct cygpath for minGW (ToDo!)
case $build in
  *-mingw*)
    CYGPATH_W=echo
    ;;
esac

case $build in
  *-cygwin* | *-mingw*)
  case "$CXX" in
    cl | */cl) 
      AC_MSG_NOTICE(Applying patches to libtool for cl compiler)
      sed -e 's|fix_srcfile_path=\"`cygpath -w \"\$srcfile\"`\"|fix_srcfile_path=\"\\\`'"$CYGPATH_W"' \\\"\\$srcfile\\\"\\\`\"|' \
          -e 's|fix_srcfile_path=\"\"|fix_srcfile_path=\"\\\`'"$CYGPATH_W"' \\\"\\$srcfile\\\"\\\`\"|' \
          -e 's%compile_deplibs=\"\$dir/\$old_library \$compile_deplibs\"%compile_deplibs="'\`"$CYGPATH_W"' \$dir/\$old_library | sed -e '"'"'sY\\\\\\\\Y/Yg'"'"\`' \$compile_deplibs\"'% \
          -e 's%compile_deplibs=\"\$dir/\$linklib \$compile_deplibs\"%compile_deplibs="'\`"$CYGPATH_W"' \$dir/\$linklib | sed -e '"'"'sY\\\\\\\\Y/Yg'"'"\`' \$compile_deplibs\"'% \
	  -e 's%lib /OUT:%lib -OUT:%' \
	  -e "s%cygpath -w%$CYGPATH_W%" \
	  -e 's%$AR x \\$f_ex_an_ar_oldlib%bla=\\`lib -nologo -list \\$f_ex_an_ar_oldlib | xargs echo\\`; echo dd \\$bla; for i in \\$bla; do lib -nologo -extract:\\$i \\$f_ex_an_ar_oldlib; done%' \
	  -e 's/$AR t/lib -nologo -list/' \
      libtool > conftest.bla

      mv conftest.bla libtool
      chmod 755 libtool
      ;;
    
  esac
esac
]) # AC_COIN_PROG_LIBTOOL

# This is a trick to force the check for the dlfcn header to be done before
# the checks for libtool
AC_DEFUN([AC_COIN_DLFCN_H],
[AC_LANG_PUSH(C)
AC_COIN_CHECK_HEADER([dlfcn.h])
AC_LANG_POP(C)
]) # AC_COIN_DLFCN_H

###########################################################################
#                            COIN_RPATH_FLAGS                             #
###########################################################################

# This macro, in case shared objects are used, defines a variable
# RPATH_FLAGS that can be used by the linker to hardwire the library
# search path for the given directories.  This is useful for example
# Makefiles

AC_DEFUN([AC_COIN_RPATH_FLAGS],
[RPATH_FLAGS=

if test "$GXX" = "yes"; then
  RPATH_FLAGS=
  for dir in $1; do
    RPATH_FLAGS="$RPATH_FLAGS -Wl,--rpath -Wl,$dir"
  done
else
  case $build in
    *-linux-*)
      case "$CXX" in
      icpc | */icpc)
        RPATH_FLAGS=
        for dir in $1; do
          RPATH_FLAGS="$RPATH_FLAGS -Wl,--rpath -Wl,$dir"
        done
      esac ;;
    *-ibm-*)
      case "$CXX" in
      xlC* | */xlC* | mpxlC* | */mpxlC*)
        RPATH_FLAGS=nothing ;;
      esac ;;
    *-hp-*)
        RPATH_FLAGS=nothing ;;
    *-mingw32)
        RPATH_FLAGS=nothing ;;
    *-sun-*)
        RPATH_FLAGS=
        for dir in $1; do
          RPATH_FLAGS="$RPATH_FLAGS -R$dir"
        done
   esac
fi

if test "$RPATH_FLAGS" = ""; then
  AC_MSG_WARN([Could not automatically determine how to tell the linker about automatic inclusion of the path for shared libraries.  The test examples might not work if you link against shared objects.  You will need to set the LD_LIBRARY_PATH or LIBDIR variable manually.])
fi
if test "$RPATH_FLAGS" = "nothing"; then
  RPATH_FLAGS=
fi

AC_SUBST(RPATH_FLAGS)
]) # AC_COIN_RPATH_FLAGS

###########################################################################
#                        COIN_VPATH_CONFIG_LINK                           #
###########################################################################

# This macro makes sure that a symbolic link is created to a file in
# the source code directory tree if we are in a VPATH compilation, and
# if this package is the main package to be installed

AC_DEFUN([AC_COIN_VPATH_LINKS],
[AC_REQUIRE([AC_COIN_CHECK_VPATH])
if test $coin_vpath_config = yes; then
  AC_CONFIG_LINKS($1:$1)
fi
]) #AC_COIN_VPATH_CONFIG_LINK

###########################################################################
#                       COIN_ENABLE_GNU_PACKAGES                          #
###########################################################################

# This macro defined the --enable-gnu-packages flag.  This can be used
# to check if a user wants to compile GNU packges (such as readline or
# zlib) into the executable.  By default, GNU packages are disabled.

AC_DEFUN([AC_COIN_ENABLE_GNU_PACKAGES],
[AC_ARG_ENABLE([gnu-packages],
               [AC_HELP_STRING([--enable-gnu-packages],
                               [compile with GNU packages (disabled by default)])],
	       [coin_enable_gnu=$enableval],
	       [coin_enable_gnu=no])
]) # AC_COIN_ENABLE_GNU_PACKAGES

###########################################################################
#                             COIN_CHECK_ZLIB                             #
###########################################################################

# This macro checks for the libz library.

AC_DEFUN([AC_COIN_CHECK_ZLIB],
[AC_REQUIRE([AC_COIN_ENABLE_GNU_PACKAGES])
AC_BEFORE([AC_COIN_PROG_CXX],[$0])
AC_BEFORE([AC_COIN_PROG_CC],[$0])
AC_BEFORE([AC_COIN_PROG_F77],[$0])
AC_BEFORE([$0],[AC_COIN_FINISH])

if test $coin_enable_gnu = yes; then
  coin_has_zlib=no
  AC_COIN_CHECK_HEADER([zlib.h],[coin_has_zlib=yes])

  if test $coin_has_zlib = yes; then
    AC_CHECK_LIB([z],[gzopen],
                 [ADDLIBS="-lz $ADDLIBS"],
                 [coin_has_zlib=no])
  fi

  if test $coin_has_zlib = yes; then
    AC_DEFINE([COIN_HAS_ZLIB],[1],[Define to 1 if zlib is available])
  fi
fi
]) # AC_COIN_CHECK_ZLIB


###########################################################################
#                            COIN_CHECK_BZLIB                             #
###########################################################################

# This macro checks for the libbz2 library.

AC_DEFUN([AC_COIN_CHECK_BZLIB],
[AC_REQUIRE([AC_COIN_ENABLE_GNU_PACKAGES])
AC_BEFORE([AC_COIN_PROG_CXX],[$0])
AC_BEFORE([AC_COIN_PROG_CC],[$0])
AC_BEFORE([AC_COIN_PROG_F77],[$0])
AC_BEFORE([$0],[AC_COIN_FINISH])

if test $coin_enable_gnu = yes; then
  coin_has_bzlib=no
  AC_COIN_CHECK_HEADER([bzlib.h],[coin_has_bzlib=yes])

  if test $coin_has_bzlib = yes; then
    AC_CHECK_LIB([bz2],[BZ2_bzReadOpen],
                 [ADDLIBS="-lbz2 $ADDLIBS"],
                 [coin_has_bzlib=no])
  fi

  if test $coin_has_bzlib = yes; then
    AC_DEFINE([COIN_HAS_BZLIB],[1],[Define to 1 if bzlib is available])
  fi
fi
]) # AC_COIN_CHECK_BZLIB


###########################################################################
#                           COIN_CHECK_READLINE                           #
###########################################################################

# This macro checks for GNU's readline.  It verifies that the header
# readline/readline.h is available, and that the -lreadline library
# contains "readline".  It is assumed that #include <stdio.h> is included
# in the source file before the #include<readline/readline.h>

AC_DEFUN([AC_COIN_CHECK_READLINE],
[AC_REQUIRE([AC_COIN_ENABLE_GNU_PACKAGES])
AC_BEFORE([AC_COIN_PROG_CXX],[$0])
AC_BEFORE([AC_COIN_PROG_CC],[$0])
AC_BEFORE([AC_COIN_PROG_F77],[$0])
AC_BEFORE([$0],[AC_COIN_FINISH])

if test $coin_enable_gnu = yes; then
  coin_has_readline=no
  AC_COIN_CHECK_HEADER([readline/readline.h],
                       [coin_has_readline=yes],[],
                       [#include <stdio.h>])

  coin_save_LIBS="$LIBS"
  LIBS=
  # First we check if tputs and friends are available
  if test $coin_has_readline = yes; then
    AC_SEARCH_LIBS([tputs],[ncurses termcap curses],[],
                   [coin_has_readline=no])
  fi

  # Now we check for readline
  if test $coin_has_readline = yes; then
    AC_CHECK_LIB([readline],[readline],
                 [ADDLIBS="-lreadline $LIBS $ADDLIBS"],
                 [coin_has_readline=no])
  fi

  if test $coin_has_readline = yes; then
    AC_DEFINE([COIN_HAS_READLINE],[1],[Define to 1 if readline is available])
  fi

  LIBS="$coin_save_LIBS"
fi
]) # AC_COIN_CHECK_READLINE

###########################################################################
#                             COIN_HAS_DATA                               #
###########################################################################

# This macro makes sure that the data files in the Data subdirectory
# are available.  The argument is the subdirectory name in the Data
# COIN project.  This macro defines the preprocessor macro
# COIN_HAS_DATA_SUBDIR (where SUBDIR is the name of the subdirectory
# in capital letters) and the makefile conditional with the same name.
# If this is the base project, it also adds the directory to the
# recursive list.

AC_DEFUN([AC_COIN_HAS_DATA],
[AC_MSG_CHECKING([whether Data directory $1 is available])
if test -r ../Data/$1; then
  AC_DEFINE(m4_toupper(COIN_HAS_DATA_$1),[1],
            [Define to 1 if Data subdirectory $1 is available])
  AC_MSG_RESULT(yes)
  have_data=yes
else
  have_data=no
fi
AC_MSG_RESULT($have_data)
AM_CONDITIONAL(m4_toupper(COIN_HAS_DATA_$1),test $have_data = yes)
]) # AC_COIN_HAS_DATA

###########################################################################
#                          COIN_EXAMPLE_FILES                             #
###########################################################################

# This macro determines the names of the example files (using the
# argument in an "ls" command) and sets up the variables EXAMPLE_FILES
# and EXAMPLE_CLEAN_FILES.  If this is a VPATH configuration, it also
# creates soft links to the example files

AC_DEFUN([AC_COIN_EXAMPLE_FILES],
[AC_REQUIRE([AC_COIN_CHECK_VPATH])
files=`cd $srcdir; ls $1`
# We need to do the following loop to make sure that are no newlines
# in the variable
for file in $files; do
  EXAMPLE_FILES="$EXAMPLE_FILES $file"
done
if test $coin_vpath_config = yes; then
  AC_PROG_LN_S
  AC_MSG_NOTICE([Creating links to the example files ($1)])
  for file in $EXAMPLE_FILES; do
    rm -f $file
    $LN_S $srcdir/$file $file
  done
  EXAMPLE_CLEAN_FILES='$1'
else
  EXAMPLE_CLEAN_FILES=
fi

AC_SUBST(EXAMPLE_FILES)
AC_SUBST(EXAMPLE_CLEAN_FILES)
]) #AC_COIN_EXAMPLE_FILES

###########################################################################
#                            COIN_HAS_PROJECT                             #
###########################################################################

# This macro sets up usage of a Coin package.  It defines the
# PKGSRCDIR and PKGOBJDIR variables, refering to the main source and
# object directory of the package, respectively.  It also defines
# a COIN_HAS_PKG preprocessor macro and makefile conditional.  The
# argument should be the name (Pkg) of the project (in correct lower
# and upper case)

AC_DEFUN([AC_COIN_HAS_PROJECT],
[AC_MSG_CHECKING([for COIN project $1])

# First check, if the sub-project is actually available (ToDo: allow
# other locations)

m4_tolower(coin_has_$1)=unavailable
if test $PACKAGE_TARNAME = m4_tolower($1); then
  m4_tolower(coin_has_$1)=.
else
  if test -d $srcdir/../$1; then
    m4_tolower(coin_has_$1)=../$1
  fi
fi

if test $m4_tolower(coin_has_$1) != unavailable; then
  # Set the #define if the component is available
  AC_DEFINE(m4_toupper(COIN_HAS_$1),[1],[Define to 1 if the $1 package is used])

  # Set the variables for source and object code location
  AC_SUBST(m4_toupper($1SRCDIR))
  m4_toupper($1SRCDIR)=`cd $srcdir/$m4_tolower(coin_has_$1); pwd`
  AC_SUBST(m4_toupper($1OBJDIR))
  m4_toupper($1OBJDIR)=`pwd`/$m4_tolower(coin_has_$1)
fi

  # Define the Makefile conditional
AM_CONDITIONAL(m4_toupper(COIN_HAS_$1),
               test $m4_tolower(coin_has_$1) != unavailable)
AC_MSG_RESULT([$m4_tolower(coin_has_$1)])
]) # AC_COIN_HAS

###########################################################################
#                        COIN_HAS_USER_LIBRARY                            #
###########################################################################

# This macro sets up usage of a library with header files.  It defines
# the LBRYINCDIR variable, and it defines COIN_HAS_LBRY preprocessor
# macro and makefile conditional.  The first argument should be the
# full name (LibraryName) of the library, and the second argument (in
# upper case letters) the abbreviation (LBRY).  This macro also
# introduces the configure arguments --with-libraryname-incdir and
# --with-libraryname-lib which have to be both given by a user to use
# this solver to tell the configure script where the include files and
# the library are located.  Those arguments can also be given as
# environement variables LBRYINCDIR and LBRYLIB, but a --with-*
# argument overwrites an environment variable.  If a third argument is
# given, it is assumed that this is the name of a header file that can
# be checked for in the given include directory, and if a fourth
# argument is given, it is assumed to be the name of a C function
# which is given and defined in the library, and a test is done to
# check if that symbol is defined in the library.

AC_DEFUN([AC_COIN_HAS_USER_LIBRARY],
[AC_REQUIRE([AC_COIN_SRCDIR_INIT])
AC_MSG_CHECKING(if user provides library for $1)

# Check for header file directory
AC_ARG_WITH(m4_tolower($1)-incdir,
            AC_HELP_STRING([--with-m4_tolower($1)-incdir],
                           [specify the directory with the header files for library $1]),
                           [$2INCDIR=`cd $withval; pwd`])
# Check for library directory
AC_ARG_WITH(m4_tolower($1)-lib,
            AC_HELP_STRING([--with-m4_tolower($1)-lib],
                           [specify the flags to link with the library $1]),
                           [$2LIB=$withval])

if test x"$$2INCDIR" != x || test x"$$2LIB" != x; then
  m4_tolower(coin_has_$2)=true
else
  m4_tolower(coin_has_$2)=false
fi

if test $m4_tolower(coin_has_$2) = true; then
# Check either both arguments or none are given
  if test x"$$2INCDIR" = x || test x"$$2LIB" = x; then
    AC_MSG_ERROR([You need to specify both --with-m4_tolower($1)-incdir and --with-m4_tolower($1)-lib if you want to use library $1])
  fi
  AC_MSG_RESULT(yes)
  # Check if the given header file is there
  m4_ifvaln([$3],[AC_CHECK_FILE([$$2INCDIR/$3],[],
                 [AC_MSG_ERROR([Cannot find file $3 in $$2INCDIR])])])
  # Check if the symbol is provided in the library
  # ToDo: FOR NOW WE ASSUME THAT WE ARE USING THE C++ COMPILER
  m4_ifvaln([$4],[coin_save_LIBS="$LIBS"
                  LIBS="$$2LIB $ADDLIBS"
		  AC_MSG_CHECKING([whether symbol $4 is available with $2])
                  AC_TRY_LINK([extern "C" {void $4();}],[$4()],
                              [AC_MSG_RESULT(yes)],
			      [AC_MSG_RESULT(no)
                               AC_MSG_ERROR([Cannot find symbol $4 with $2])])
                  LIBS="$coin_save_LIBS"])
  ADDLIBS="$$2LIB $ADDLIBS"
  AC_DEFINE(COIN_HAS_$2,[1],[Define to 1 if the $1 package is used])
else
  AC_MSG_RESULT(no)
fi

AC_SUBST($2INCDIR)
AC_SUBST($2LIB)
AM_CONDITIONAL(COIN_HAS_$2,
               test $m4_tolower(coin_has_$2) = true)
]) #AC_COIN_HAS_SOLVER 
