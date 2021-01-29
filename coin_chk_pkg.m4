
###########################################################################
#                     COIN_FIND_PRIM_PKG                                  #
###########################################################################
# COIN_FIND_PRIM_PKG([prim],[pcfile(s)],[default action],[cmdlineopts])

# Determine whether we can use primary package prim ($1) by passing [pcfile(s)]
# to pkgconf. From the result, assemble information on the required pkgconfig
# (.pc) files, library flags (prim_lflags), compiler flags (prim_cflags),
# and data directories (prim_data).

# cmdlineopts ($4) specifies the set of configure command line options
# defined and processed: 'nodata' produces --with-prim, --with-prim-libs, and
# --with-prim-cflags; 'dataonly' produces --with-prim and --with-prim-data;
# 'all' produces all four. Anything else defaults to 'nodata'.  Shell code
# produced by the macro is tailored based on cmdlineopts.

# --with-prim is interpreted as follows:
#   * --with-prim=no or --without-prim
#     prim status is set to skipping
#   * --with-prim or --with-prim=yes
#     prim status is set to requested
#   * --with-prim=build
#     prim status is set to requested but we look first for coinxxx.pc,
#     then xxx.pc
#   * Any other value is taken as equivalent to
#       --with-prim-data=value (dataonly) or
#       --with-prim-lflags=value (anything else)
#     prim status is set to requested

# The algorithm first checks for a user-specified value of --with-prim;
# values are interpreted as above.  Next, it looks for user specified values
# given with command line parameters --with-prim-lflags, --with-prim-cflags,
# and --with-prim-data. If any of these are specified, they override the .pc
# file(s) specified in [pcfiles(s)] and are accepted with no futher testing.
# Be careful!

# The usage portion of [dfltaction] ($3) (default_skip, default_use,
# default_build) is used as the default value of --with-prim if the user
# offers no guidance via command line parameters. Since FIND_PRIM_PKG does
# no checks, it's useless to specify linkage in [dfltaction].

# To repeat the warning with CHK_PKG, `default_build' ('build' from the
# command line) hasn't a hope of working for anything except a COIN
# Third-party package, where the convention is to name the .pc file
# coinprim.pc. The code below will take whatever is in [pcfile(s)] and prepend
# the string 'coin'. This will almost surely fail to do what the user expects
# if [pcfile(s)] actually contains more than one .pc file name.

# The macro doesn't test that the specified values actually work. This is
# deliberate.  There's no guarantee that user-specified libraries and/or
# directories actually exist yet. The same possibility exists for values
# returned when pkgconf checks the .pc file.

AC_DEFUN([AC_COIN_FIND_PRIM_PKG],
[
  AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])

dnl Issue a warning that 'default_build' is deprecated.
  AC_COIN_DEPRECATE_BUILD_OPTION([COIN_FIND_PRIM_PKG],[$3])

dnl Set the default action and status from the macro parameters.

  m4_case(AC_COIN_LIBHDR_DFLT_HACK([usage],[$3],[default_use]),
    default_use,
      [m4_tolower(coin_has_$1)=requested],
    default_build,
      [m4_tolower(coin_has_$1)=requested
       m4_tolower($1_build)=yes],
    default_skip,
      [m4_tolower(coin_has_$1)=skipping
       m4_tolower($1_failmode)='default'],
    [m4_tolower(coin_has_$1)=requested])

dnl Set default values for flags, data, pcfiles
  m4_tolower($1_lflags)=
  m4_tolower($1_cflags)=
  m4_tolower($1_data)=
  m4_ifnblank([$2],
    [m4_tolower($1_pcfiles)="$2"],
    [m4_tolower($1_pcfiles)=m4_tolower($1)])

dnl See if the user specified --with-prim.  If the value is something other
dnl than 'yes', 'build', or 'no' and the client specified dataonly, the
dnl value is assigned to prim_data, otherwise to prim_lflags. But in the
dnl absence of an explicit 'no', allow non-null lflags, cflags, or data to
dnl be equivalent to 'yes'.

  withval="$m4_tolower(with_$1)"
  if test -n "$withval" ; then
    case "$withval" in
      no )
        m4_tolower(coin_has_$1)=skipping
        m4_tolower($1_failmode)='command line'
        ;;
      yes )
        m4_tolower(coin_has_$1)=requested
        m4_tolower($1_failmode)=''
        ;;
      build )
        m4_tolower(coin_has_$1)=requested
        m4_tolower($1_build)=yes
        m4_tolower($1_failmode)=''
        ;;
      * )
        m4_tolower(coin_has_$1)=requested
        m4_tolower($1_failmode)=''
        m4_if(m4_default($8,nodata),dataonly,
          [m4_tolower($1_data)="$withval"],
          [m4_tolower($1_lflags)="$withval"])
        ;;
    esac
  else
    if test -n "$m4_tolower(with_$1_lflags)" ||
       test -n "$m4_tolower(with_$1_cflags)" ||
       test -n "$m4_tolower(with_$1_data)" ; then
      m4_tolower(coin_has_$1)=requested
      m4_tolower($1_failmode)=''
    fi
  fi

dnl As long as we're not dataonly and we're not skipping prim, check for
dnl --with-prim-lflags and --with-prim-cflags. If we see any of no, yes,
dnl build, declare them invalid. Otherwise, we're not going to check so
dnl accept them on faith.

  m4_if(m4_default($4,nodata),dataonly,[],
    [if test "$m4_tolower(coin_has_$1)" != skipping ; then
       withval="$m4_tolower(with_$1_lflags)"
       if test -n "$withval" ; then
         case "$withval" in
           build | no | yes )
             AC_MSG_ERROR(m4_normalize(
               ["$withval" is not useful here; please specify link flags]
               [appropriate for your environment.]))
             ;;
           * )
             m4_tolower(coin_has_$1)=yes
             m4_tolower($1_lflags)="$withval"
             ;;
         esac
       fi

       withval="$m4_tolower(with_$1_cflags)"
       if test -n "$withval" ; then
         case "$withval" in
           build | no | yes )
             AC_MSG_ERROR(m4_normalize(
               ["$withval" is not useful here; please specify compile flags]
               [appropriate for your environment.]))
             ;;
           * )
             m4_tolower(coin_has_$1)=yes
             m4_tolower($1_cflags)="$withval"
             ;;
         esac
       fi
     fi])

dnl If we're not nodata and we're not skipping prim, check for
dnl --with-prim-data. A value will override the parameter value. Here we
dnl really can't do anything except accept on faith.

  m4_if(m4_default($4,nodata),nodata,[],
    [if test "$m4_tolower(coin_has_$1)" != skipping ; then
       withval="$m4_tolower(with_$1_data)"
       if test -n "$withval" ; then
         m4_tolower(coin_has_$1)=yes
         m4_tolower($1_data)="$withval"
       fi
     fi])

dnl At this point, coin_has_prim can be one of skipping (user said no, or
dnl default was no without override), requested (user said yes or build,
dnl or default was yes or build without override), or yes (user provided
dnl --with-prim-lflags, --with-prim-cflags, or --with-prim-data on the
dnl command line).  If we're still looking, but pkg-config is not available,
dnl print a big warning and say the package isn't available.  Otherwise, look
dnl for the specified .pc files. If the user has requested build, prepend
dnl 'coin' to the pcfiles string and try that first. This will do the right
dnl thing if the .pc file name is the first word in the pcfile string

  if test $m4_tolower(coin_has_$1) = requested ; then
    if test -n "$PKG_CONFIG" ; then
      if test x"$m4_tolower($1_build)" = xyes ; then
        pcfile="coin$m4_tolower($1)_pcfiles"
        AC_COIN_CHK_MOD_EXISTS([$1],[$pcfile],
         [m4_tolower(coin_has_$1)=yes],
         [m4_tolower(coin_has_$1)=no])
      fi
      if ! test $m4_tolower(coin_has_$1) = yes ; then
        pcfile="$m4_tolower($1)_pcfiles"
        AC_COIN_CHK_MOD_EXISTS([$1],[$pcfile],
          [m4_tolower(coin_has_$1)=yes],
          [m4_tolower(coin_has_$1)=no])
      fi
      if test $m4_tolower(coin_has_$1) = yes ; then
        m4_tolower($1_data)=`PKG_CONFIG_PATH="$COIN_PKG_CONFIG_PATH" $PKG_CONFIG --variable=datadir "$pcfile" 2>/dev/null`
        m4_tolower($1_pcfiles)="$pcfile"
      fi
    else
      AC_MSG_WARN(m4_normalize(
        [Check for $1 via pkg-config could not be performed as there is no pkg-config available.]
        [Consider installing pkg-config or  provide appropriate values for --with-m4_tolower($1)-lflags and --with-m4_tolower($1)-cflags.]))
      m4_tolower(coin_has_$1)=no
    fi
  fi

dnl The final value of coin_has_prim will be yes, no, or skipping.  No means
dnl we looked (with pkgconfig) and didn't find anything.  Skipping means
dnl the user said no or no was the default and not overridden.  Yes means we
dnl have something, from the user or from pkgconfig.  Note that we haven't
dnl run a useability test!

dnl Define BUILDTOOLS_DEBUG to enable debugging output
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

# COIN_CHK_PKG([prim],[clients],[.pc file(s)],
#              [dfltaction],[cmdopts])

# Determine whether we can use primary package prim ($1) and assemble
# information on the required pkgconfig files (prim_pcfiles), linker
# flags (prim_lflags), compiler flags (prim_cflags), and data directories
# (prim_data).

# The configure command line options offered to the user are controlled
# by cmdopts ($5). 'nodata' offers --with-prim, --with-prim-lflags, and
# --with-prim-cflags. 'dataonly' offers --with-prim and --with-prim-data.
# 'all' offers all four. DEF_PRIM_ARGS and FIND_PRIM_PKG are tailored
# accordingly. The (hardwired) default is 'nodata'.

# Default action ($4) (no, yes, build) is the default action if the user
# offers no guidance via command line parameters. 'build' is deprecated
# and has no hope of working except for COIN-OR ThirdParty packages. Don't
# use it.

# If no .pc file names are specified, the macro will look for prim.pc. If
# there's exactly one .pc file name xxx.pc (either explicit or default) and
# [dfltaction] is build, the macro searches first for coinxxx.pc, then xxx.pc
# (this happens in CHK_PRIM_PKG).

# Define an automake conditional COIN_HAS_PRIM to record the result. If we
# decide to use prim, also define a preprocessor symbol COIN_HAS_PRIM.

# Linker and compiler flag information will be propagated to the space-
# separated list of client packages [clients] ($2) using the _PCFILES variable
# if a .pc file is used, otherwise by the _LFLAGS and _CFLAGS variables of
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
dnl Issue a warning that 'default_build' is deprecated.
  AC_COIN_DEPRECATE_BUILD_OPTION([COIN_CHK_PKG],[$4])

  AC_REQUIRE([AC_COIN_HAS_PKGCONFIG])

  AC_MSG_CHECKING([for package $1])

dnl Make sure the necessary variables exist for each client package.

  m4_foreach_w([myvar],[$2],
    [AC_SUBST(m4_toupper(myvar)_LFLAGS)
     AC_SUBST(m4_toupper(myvar)_CFLAGS)
     AC_SUBST(m4_toupper(myvar)_PCFILES)
    ])

dnl Check if the user has overridden configure parameters from the
dnl environment.

  m4_tolower(coin_has_$1)=noInfo
  if test x"$COIN_SKIP_PROJECTS" != x ; then
    for pkg in $COIN_SKIP_PROJECTS ; do
      if test "$m4_tolower(pkg)" = "$m4_tolower($1)" ; then
        m4_tolower(coin_has_$1)=skipping
      fi
    done
  fi

dnl If we are not skipping this primary, define and process the
dnl command line options according to the cmdopts parameter. Then invoke
dnl FIND_PRIM_PKG to do the heavy lifting.
dnl Note that we're grandfathering 'build' as an alternative keyword for
dnl 'default_build'. This should go away eventually. -lh,210118-

  if test "$m4_tolower(coin_has_$1)" != skipping ; then
    m4_case(m4_default($5,nodata),
      nodata,  [AC_COIN_DEF_PRIM_ARGS([$1],yes,yes,yes,no,
                  AC_COIN_LIBHDR_DFLT_HACK([usage],[$4],[default_use]))],
      dataonly,[AC_COIN_DEF_PRIM_ARGS([$1],yes,no,no,yes,
                  AC_COIN_LIBHDR_DFLT_HACK([usage],[$4],[default_use]))],
      all,     [AC_COIN_DEF_PRIM_ARGS([$1],yes,yes,yes,yes,
                  AC_COIN_LIBHDR_DFLT_HACK([usage],[$4],[default_use]))],
      [AC_COIN_DEF_PRIM_ARGS([$1],yes,yes,yes,no,
         AC_COIN_LIBHDR_DFLT_HACK([usage],[$4],[default_use]))])
    AC_COIN_FIND_PRIM_PKG(m4_tolower($1),m4_default([$3],m4_tolower($1)),
                          m4_if([$4],[build],[default_build],[$4]),
                          m4_default([$5],nodata))
    AC_MSG_RESULT([$m4_tolower(coin_has_$1)])
  else
    AC_MSG_RESULT([$m4_tolower(coin_has_$1) (COIN_SKIP_PROJECTS)])
  fi

dnl Possibilities are `yes', `no', or `skipping'. 'Skipping' implies we
dnl decided to skip the package for some reason. 'No' means we wanted the
dnl package but pkgconfig couldn't find the .pc files. 'Yes' means pkgconfig
dnl found the .pc files.  Normalise to yes or no for the remainder.

  if test "$m4_tolower(coin_has_$1)" != yes ; then
    m4_tolower(coin_has_$1)=no
  fi

dnl Create an automake conditional COIN_HAS_PRIM.

  AM_CONDITIONAL(m4_toupper(COIN_HAS_$1),[test $m4_tolower(coin_has_$1) = yes])

dnl If we've located the package, define preprocessor symbol PACKAGE_HAS_PRIM
dnl and augment the necessary variables for the client packages.

  if test $m4_tolower(coin_has_$1) = yes ; then
    AC_DEFINE(m4_toupper(AC_PACKAGE_NAME)_HAS_[]m4_toupper($1),[1],
      [Define to 1 if $1 is available.])
    m4_foreach_w([myvar],[$2],
      [m4_toupper(myvar)_PCFILES="$m4_tolower($1_pcfiles) $m4_toupper(myvar)_PCFILES"
       m4_toupper(myvar)_LFLAGS="$m4_tolower($1_lflags) $m4_toupper(myvar)_LFLAGS"
       m4_toupper(myvar)_CFLAGS="$m4_tolower($1_cflags) $m4_toupper(myvar)_CFLAGS"
      ])

dnl Finally, set up PRIM_DATA, unless the user specified nodata.
    m4_if(m4_default([$5],nodata),nodata,[],
      [AC_SUBST(m4_toupper($1)_DATA)
       m4_toupper($1)_DATA=$m4_tolower($1_data)])
  fi
])   # COIN_CHK_PKG


