
 In the [directory structure example](./user-directories), the package base directory is `Coin-Clp`.

A typical COIN package base directory `Makefile.am` file looks like this example taken from Clp:

```
# Copyright (C) 2006 International Business Machines and others.
# All Rights Reserved.
# This file is distributed under the Common Public License.

## $Id: Makefile.am 788 2006-06-01 18:57:08Z andreasw $

# Author:  Andreas Waechter           IBM    2006-04-13

AUTOMAKE_OPTIONS = foreign

EXTRA_DIST = doxydoc/doxygen.conf
```

 * One should always start with a *copyright note and author information*, and include the *`svn:keyword`* "*`$Id`*".  The line with the keyword should start with "`##`" so that it is not copied into the generated `Makefile.in` file, which causes some confusion for subversion.

 * The *AUTOMAKE_OPTIONS* variable is a special variable that indicates certain options for the `automake` run.  The *foreign* option tells `automake` that it should not enforce strict conformance with GNU guidelines.

 * The *EXTRA_DIST* variable is set to every file that should be included in a tarball generated with `make dist`.  One only needs to list non-source files, and non-autotools related files.  In the above example, the only file in this category is the configuration file for doxygen.


```
########################################################################
#                          Subdirectories                              #
########################################################################

# subdirs is set by configure as the list of all subdirectories to recurse
# into
SUBDIRS = $(subdirs)
```

 * The `Makefile.am` in a package base directory needs to be told the subdirectories into which it should recurse.  This is done with the *SUBDIRS* variable.  The Autoconf output variable `subdirs` is already automatically set to the correct value by `configure`, based on the results of the `AC_COIN_MAIN_SUBDIRS` macro tests.

```
########################################################################
#                           Extra Targets                              #
########################################################################

test: all
	cd Clp; $(MAKE) test

unitTest: test

tests:
	for dir in $(subdirs); do \
	  if test -r $$dir/test/Makefile; then \
	    (cd $$dir; $(MAKE) test) \
	  fi; \
	done

unitTests: tests
```

 * In this section we can define *extra Makefile targets*.  As you can see, the *test* (and *unitTest*) targets first make sure that everything is compiled (the target `all` is the automatically generated target for compilation of everything).  Then it changes into the package's project directory and runs the `test` target there.  It is also nice to provide a *tests* (and *unitTests*) target, which runs the `test` targets in every project subdirectory that seems to have a `test` subdirectory with a Makefile.


```
doxydoc:
	cd $(srcdir); doxygen doxydoc/doxygen.conf

.PHONY: test unitTest tests unitTests doxydoc
```

 * For C++ packages, we usually also provide a target *doxydoc*, which runs the `doxygen` program for all source code found in subdirectories.  Note the "*cd $(srcdir)*" here.  In the case of a VPATH compilation, the Makefile generated from this `Makefile.am` file is not run in the directory where `doxygen` should be run.  The Autoconf output variable *srcdir* is set to the directory which contains the source code (such as the `Makefile.am` file) corresponding to the VPATH directory.

```
########################################################################
#                         Maintainer Stuff                             #
########################################################################

# Files that are generated and should be cleaned with make distclean
DISTCLEANFILES =

include BuildTools/Makemain.inc
```

 * Finally, we *include the BuildTools include file Makemain.inc*.  This makes sure that additional maintainer-specific targets are defined (such as an automatic update of the `svn:externals` property when the `Externals` file has been changed).  Since values are added to the *DISTCLEANFILES* variable in this include file, this variable has to be "initalized" here, even if it is set to an empty value.