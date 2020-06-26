# The Main Directory Makefile.am File

The purpose of the Makefile here is to recurse into the source code directories to compile the code, to do the project specific installations, and to provide a `test` target to run the project's unit test (if available).

A typical COIN-OR project main subdirectory `Makefile.am` file looks like this example taken from Clp:
```
# Copyright (C) 2006 International Business Machines and others.
# All Rights Reserved.
# This file is distributed under the Eclipse Public License.

# Author:  John Doe              IIM    2011-04-01

include BuildTools/Makemain.inc
```

One should always start with a copyright note and author information.

The include of `BuildTools/Makemain.inc` defines
* targets that install AUTHORS(.md), README(.md), LICENSE(.md), if available,
* targets to build documentation via doxygen and installing and uninstalling it, and
* variables that hold the name of the directories where to install header files, data, documentation, and pkg-config files.
If you need any of these, then add this `include` to your `Makefile.am` file.

```
########################################################################
#            Subdirectories and installation of .pc files              #
########################################################################

SUBDIRS = src

pkgconfiglib_DATA = clp.pc

# Build OsiClp only if Osi is available.

if COIN_HAS_OSI
  SUBDIRS += src/OsiClp
  pkgconfiglib_DATA += osi-clp.pc
endif

# We don't want to compile the test subdirectory unless the test target
# is specified.  But we need to list it as subdirectory to make sure that
# it's included in the tarball.

if ALWAYS_FALSE
  SUBDIRS += test
endif
```

In the **SUBDIRS** variable we specify the subdirectories into which to recurse in order to compile the libraries, programs, and whatever other products this project has to offer.
In this examples, is is always the `src` directory.
If `Osi` is also available (`COIN_HAS_OSI` is an automake conditional defined in [configure](./configure)), then we also recurse into the `src/OsiClp` directory.
Alternatively, one could have specified `OsiClp` as subdirectory in `src/Makefile.am`.   
The lines with the `ALWAYS_FALSE` Automake conditional (which is always false :) are a trick to skip recursion into the `test` subdirectory for a usual run of `make` to build the products, but it will cause a `make dist` to pick up the files in the `test` directory (even though we don't use the `make dist` mechanism to generate the COIN-OR tarballs.).

The `pkgconfiglib_DATA` variable specifies the **pkg-config configuration files** that should be installed in directory `$(pkgconfiglibdir)` (typically `$prefix/lib/pkg-config`).
The files specified here will be installed by `make install` and removed again by `make uninstall`.
The pkg-config configuration files are used to communicate project dependencies, compiler flags, and linker flags between projects.


```
########################################################################
#                           Extra Targets                              #
########################################################################

test: all
	cd test; $(MAKE) test

unitTest: test

clean-local: clean-doxygen-docs
	if test -r test/Makefile; then cd test; $(MAKE) clean; fi

install-exec-local: install-doc

uninstall-local: uninstall-doc uninstall-doxygen-docs

.PHONY: test unitTest
```

The *test* (and *unitTest*) target, which first makes sure that everything has been compiled (since it depends on `all`), changes into the `test` subdirectory, where it runs the `test` target.
If the project does not provide a unit test, this should of course not be there.

The *clean-local*, *install-exec-local*, and *uninstall-local* targets are special Automake targets.
They are "called", when the user does a "`make clean`", "`make install`", and "`make uninstall`", respectively.
It allows us to specify additional actions for those default targets.

Here, we want to make sure that the `test` subdirectory is cleaned as part of the `clean` target; by default it is not, since it is not included in the `SUBDIRS` variable because the `ALWAYS_FALSE` Automake conditional is always false.
The command line simply checks if the Makefile in the `test` subdirectory exists, and if it does, the corresponding target is made.

Further, we redirect to targets for installation, uninstallation, and cleaning of [doxygen documentation](./doxygen) and `AUTHORS`, `README`, and `LICENSE` files.
Note, that doxygen documentation is not build or installed by any of these targets, thus a user is required to manually call "`make install-doxygen-docs`".
<!--For C++ packages, we usually also provide a target *doxydoc*, which runs the `doxygen` program for all projects that have a doxydoc directory.
The doxygen documentations may be connected with doxygen tag files to other projects.-->
