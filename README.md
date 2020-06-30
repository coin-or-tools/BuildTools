# COIN-OR BuildTools

BuildTools provides a set of macros and patches for projects
(typically but not necessarily in COIN-OR) that use the
[GNU autotools](https://en.wikipedia.org/wiki/GNU_Autotools) for their
build system.

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
