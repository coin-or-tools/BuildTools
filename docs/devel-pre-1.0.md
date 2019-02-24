
 One this page we can share our thought on what should go into a new version of the BuildTools.





## Technical Aspects


### Use of newer autotools

Changing:

 1. Autoconf 2.61 (currently 2.59).  Advantages? 
 (LH) Well, for one, it fixes an issue with the declaration of exit() that is pervasive across many basic autoconf tests which construct and compile short code fragments.
 Along the lines of Andreas' comment below about libtool, there are many comments in autoconf macros to the effect that cl support really needs some attention. Are we up for this? Might save time in the long run to get the changes we need into the autoconf source tree. Not to mention the warm fuzzy feeling of contributing back to autoconf.

 1. Automake 1.10 (currently 1.9.6).  Advantages?

 1. Libtool stays at 1.5.22; nothing new has been released yet.  However, that version has a number of bugs that we currently patch "by hand".  Maybe we can use a new non-official version?  All that is needed is really the libtool.m4 file, and we might be able to distribute a good working version together with BuildTools?  This way, we can also easily suggest fixes to the Libtool developers and include their changes.

AW: I will start with this on my settings now, using Bonmin as the example.  At some point I will also create a pseudo "CoinAll" project which we can use to test the new coin.m4 etc on.

LH: I've been using autoconf 2.61 across several platforms for about 10 days now, with no noticeable ill effects.

KM: Given some of the unrest among project managers recently I think we should go very SLOWLY about requiring a new set of auto tools. Unless there are significant advantages (and there may be) to using new versions I would vote to make BuildTools 1.0 compatible with 2.59, 1.9.6 etc.  


### Creating libtool only once (libtool reuse)

At the moment, the libtool script is created for every subprojects, and those annoying timeconsuming tests are run many times.  It should be possible to change that so that the libtool script is created only once in the package's base directory.

AW: I'm going to look into this.

LH: Some care is required. We need to get our compilers and compilation flags set correctly before calling COIN_INIT_AUTOTOOLS, else various macros down in the guts of autotools will 'help' us by providing defaults which are often incorrect (particularly in non-GCC environments).

AW: I did a first attempt of this - it is now in BuildTools/trunk (not yet in devel-pre-1.0).  We using it with Bonmin, and it seems to work Ok, also on Cygwin.  What I did when the libtool script is NOT created (and the tests are skipped), I still read the values of come autoconf output variables and a few #define's from the config.status file in the directory where the libtool script is.

LH: This is working really well. The basic idea has held up well across all the platforms I've tested. I ended up adding one additional pair of variables to the set Andreas selected from config.status to get it to work in a Solaris/GCC environment. There's a potential 'gotcha' with a format change in config.status moving up to autoconf 2.61. Details in a series of
[posts on the buildtools list](http://list.coin-or.org/pipermail/buildtools/2006-December/000028.html).

LH: Now incorporated into BuildTools/stable/0.5.


### Avoiding aclocal.m4 creation

At the moment, we create a aclocal.m4 file in maintainer mode, that combines libtool.m4 and our coin.m4.  Instead, we can probably use the -I flag for aclocal.  Also, we think about disaggregating coin.m4 into different files, if the tests are truly independent.

AW: I'm going to look into this.


## New or improved features


### Different handling of DOS compilation

Lou's suggested handling of --enable-doscompile?

LH: I've attached versions of [BuildTools/coin.m4](devel-pre-1.0/coin.m4) and [CoinUtils/configure.ac](devel-pre-1.0/configure.ac) which implement the --enable-doscompile idea for msvc (cl/link) and mingw (gcc/g++/ld with -mno-cygwin). If you omit --enable-doscompile, you'll get a standard cygwin build. Msys is missing; I don't have that environment to play with. The files also cope with absence of a Fortran compiler, as mentioned in the mailing list. These files expect to see autoconf 2.61.

AW: I saw in the proposed implementation that --enable-discompile can be given different arguments.  But I think we need to use a --with- configure argument for that?  (--enable- is only yes or no...?)

LH: --with is fine by me, I just want the functionality. I've done a reimplementation that fixes up CPPFLAGS (really the critical point for -mno-cygwin) and works with autoconf 2.59 --- it's in the coin.m4 in a tar file attached to [this buildtool post](http://list.coin-or.org/pipermail/buildtools/2006-December/000031.html). I should check this page more often, I'd have changed --enable to --with while I was at it.

LH: Now incorporated into BuildTools/stable/0.5.


### Skipping Projects

At present, users can set the environment variable `COIN_SKIP_PROJECTS` if they want to skip configuration of a project. LH suggested that it would be nice if the `run_autotools` script also observed `COIN_SKIP_PROJECTS`. LL suggests that it would be nice if we also supported `--skip-project` as a command line option for `configure`.

LH: I will look into this.  See [this BuildTools post](http://list.coin-or.org/pipermail/buildtools/2007-January/000044.html) for an augmented `run_autotools`.


## Names & Initials

| AW | Andreas Waechter |
|----|------------------|
| KM | Kipp Martin |
| LH | Lou Hafer |
| LL | Laci Ladanyi |

---

Attachments:
 * [coin.m4](devel-pre-1.0/coin.m4)
 * [configure.ac](devel-pre-1.0/configure.ac)
