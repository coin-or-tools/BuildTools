
 In the [directory structure example](./user-directories), the project main directories are `Clp` and `CoinUtils`.

The purpose of the Makefile here is to recurse into the source code directories to compile the code, to do the project specific installations, and to provide a `test` target to run the project's unit test (if available).

A typical COIN project main subdirectory `Makefile.am` file looks like this example taken from Clp:

```
# Copyright (C) 2006 International Business Machines and others.
# All Rights Reserved.
# This file is distributed under the Common Public License.

## $Id: Makefile.am 788 2006-06-01 18:57:08Z andreasw $

# Author:  Andreas Waechter           IBM    2006-04-13

AUTOMAKE_OPTIONS = foreign

########################################################################
#                          Subdirectories                              #
########################################################################

SUBDIRS = src

# We don't want to compile the test subdirectory, unless the test target is
# specified.  But we need to list it as subdirectory to make sure that it is
# included in the tarball

if ALWAYS_FALSE
  SUBDIRS += test
endif
```

 * One should always start with a copyright note and author information, and include the `svn:keyword` "`$Id`".  The line with the keyword should start with "`##`" so that it is not copied into the generated `Makefile.in` file, which causes some confusion for subversion.

 * Like in a [base directory Makefile.am file](./pm-base-make), we first specify, in the *SUBDIRS* variable the subdirectories into which to recurse in order to compile the libraries, programs, and whatever other products this project has to offer.  In this examples, this is only one directory, but in order to organize your code, you might want to split the source files into different directories, in which case you need to specify them all here.  These lines with the `ALWAYS_FALSE` Automake conditional (which is always false :) are a trick to skip recursion into the `test` subdirectory for a usual run of `make` to build the products, but it will cause a `make dist` to pick up the files in the `test` directory (even though we don't use the `make dist` mechanism to generate the COIN tarballs.)

```
########################################################################
#             Additional files to be included in tarball               #
########################################################################

# Here we need include all files that are not mentioned in other Makefiles

EXTRA_DIST = \
        doc/authors.xml \
        doc/basicmodelclasses.xml \
        doc/clpexe.xml \
        doc/clpuserguide.xml \
        examples/driver.cpp \
        examples/dualCuts.cpp \
        examples/ekk.cpp \
        examples/ekk_interface.cpp \
        examples/hello.cpp \
        examples/hello.mps \
        examples/input.130 \
        examples/INSTALL
```

 * In this section we specify additional files that should be included in a `make dist` tarball, using the *EXTRA_DIST* Automake variable.  Even if one doesn't have any such files, there must be a line with only "`EXTRA_DIST = `", because otherwise automake will complain (related to the included Makefile).

```
########################################################################
#                           Extra Targets                              #
########################################################################

test: all
        cd test; $(MAKE) test

unitTest: test

clean-local:
        if test -r test/Makefile; then cd test; $(MAKE) clean; fi

distclean-local:
        if test -r test/Makefile; then cd test; $(MAKE) distclean; fi

.PHONY: test unitTest
```

In this section we define some extra targets:

 * The *test* (and *unitTest*) target, which first makes sure that everything has been compiled (since it depends on `all`), changes into the `test` subdirectory, where it runs the `test` target.  If the project does not provide a unit test, this should of course not be there.

 * The *clean-local* and *distclean-local* targets are special Automake targets.  They are "called", when the user does a "`make clean`" and "`make distclean`", respectively. It allows us to specify additional actions for those default targets.  Here, we want to make sure that the `test` subdirectory is cleaned; by default it is not, since it is not included in the `SUBDIRS` variable because the `ALWAYS_FALSE` Automake conditional is always false.  The command line simply checks if the Makefile in the `test` subdirectory exists, and if it does, the corresponding target is made.

```
########################################################################
#                  Installation of the addlibs file                    #
########################################################################

addlibsfile = clp_addlibs.txt

install-exec-local:
        $(install_sh_DATA) $(addlibsfile) $(DESTDIR)$(libdir)/$(addlibsfile)

uninstall-local:
        rm -f $(DESTDIR)$(libdir)/$(addlibsfile)
```

 * These lines make sure that the *..._addlibs.txt* file is installed.  This is the file containing additional library link flags required in order to link with the library generated by this project's Makefiles.  You only have to adapt the *addlibsfile* variable to use this in your own `Makefile.am`.

```
########################################################################
#                         Maintainer Stuff                             #
########################################################################

# Files that are generated and should be cleaned with make distclean
DISTCLEANFILES =

include ../BuildTools/Makemain.inc
```

 * This makes sure that some maintainer-specific things are taken care of automatically.  Just copy this to the end of your own `Makefile.am` file.
