# COIN-OR BuildTools

BuildTools provides a set of macros and patches for projects that use the
[GNU autotools](https://en.wikipedia.org/wiki/GNU_Autotools) for their
build system. Typically, but not necessarily, these are projects in COIN-OR.

The autoconf macros in coin*.m4, the automake include Makefile.inc, and
the patches for autotools scripts (e.g., libtool, compile) provide additional
functionality to simplify the setup of configure scripts, Makefiles, and
configuration headers, and improve usability of a generated build system
under Windows/MSys2.   
Documentation for this main part of BuildTools is available in the docs/
subdirectory, which is the source for https://coin-or-tools.github.io/BuildTools.

Additionally, scripts are provided that prepare a project for a release
or a new stable branch. These scripts mainly update the version number in
configure.ac and configuration headers and create tags or branches.
Run these scripts without options to get some help.

## Quick Start: Rerunning autotools for a project that uses BuildTools

As BuildTools applies additional patches to autotools scripts, the autotools
automatisms to regenerate the build scripts after a modification to
configure.ac, Makefile.am, etc., should not be used.
Additionally, we strongly suggest that all developers of a project use
the exact same version of the autotools.

Detailed information on how to run the autotools can be found
[in the documentation](https://coin-or-tools.github.io/BuildTools/autotools).
For the impatient, we repeat here the recommended steps to rerun the autotools
for an already existing BuildTools-based project.

1. Set environment variable `COIN_AUTOTOOLS_DIR` to the prefix under
   which to install or find the autotools, e.g.,
   ```
   export COIN_AUTOTOOLS_DIR=$HOME/local
   ```
2. Run the script [install_autotools.sh](./install_autotools.sh) to
   (re)install autoconf, autoconf-archive, automake, and libtool under
   `$COIN_AUTOTOOLS_DIR`. If `COIN_AUTOTOOLS_DIR` has not been set,
   the default prefix will be used, which is usually `/usr/local`
   (so root permissions will be required for the `make install` step
    in the script; edit the script accordingly)
3. Run the script [run_autotools](./run_autotools) with the path for the
   main directory of a project that uses this branch of BuildTools as
   argument, i.e.,
   ```
   ./run_autotools /path/to/project
   ```
   If `COIN_AUTOTOOLS_DIR` is set, then the script will prefix `$PATH`
   with `$COIN_AUTOTOOLS_DIR/bin` before running the autotools.

Run `./run_autotools` with option `-h` to see available options.
