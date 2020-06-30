


# The Package Base Directory Makefile.am File

In the [directory structure example](./user-directories), the package base directory is `Coin-Clp`.

A typical COIN-OR package base directory `Makefile.am` file looks like this example taken from Clp:

```
# Copyright (C) 2011 International Icecream Machines and others.
# All Rights Reserved.
# This file is distributed under the Eclipse Public License.

## $Id: Makefile.am 4242 2011-04-01 11:11:11Z johndoe $

# Author:  John Doe           IIM    2011-04-01

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

# subdirs is set by configure as the list of all subdirectories to recurse into
SUBDIRS = $(subdirs)
```

 * The `Makefile.am` in a package base directory needs to be told the subdirectories into which it should recurse.  This is done with the *SUBDIRS* variable.  The Autoconf output variable `subdirs` is already automatically set to the correct value by `configure`, based on the results of the `AC_COIN_MAIN_PACKAGEDIR` macro tests.

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
# Generate doxygen doc'n in subdirectories (except `@`PACKAGE_NAME`@`) if a doxydoc
# directory is present, then do the base, if present.

doxydoc:
        for dir in $(subdirs) ; do \
          if test $$dir != `@`PACKAGE_NAME`@` && test -r $$dir/doxydoc ; then \
            (cd $$dir ; $(MAKE) doxydoc) \
          fi ; \
        done ; \
        if test -r doxydoc/doxygen.conf ; then \
          doxygen doxydoc/doxygen.conf ; \
        fi

clean-doxydoc:
        ( cd doxydoc ; rm -rf html *.log *.tag )

# DocInstallDir is defined in Makemain.inc and is specific to the package.

install-doxydoc: doxydoc
        if test -r doxydoc/doxygen.conf ; then \
          $(mkdir_p) $(DocInstallDir) ; \ 
          cp -R doxydoc $(DocInstallDir) ; \
        fi

uninstall-doxydoc:
        rm -rf $(DocInstallDir)/doxydoc

clean-local: clean-doxydoc
# install-data-local: install-doxydoc
uninstall-local: uninstall-doxydoc


.PHONY: test unitTest tests unitTests doxydoc
```

 * For C++ packages, we usually also provide a target *doxydoc*, which runs the `doxygen` program for all projects that have a doxydoc directory. The doxygen documentations may be connected with doxygen tag files, so we create first the doxygen projects of all other projects and finally the one of our project. See the [Using Doxygen in COIN-OR Documentation](./pm-doxygen) for more details.

```
########################################################################
#                         Maintainer Stuff                             #
########################################################################

# Files that are generated and should be cleaned with make distclean
DISTCLEANFILES = coin_subdirs.txt

include BuildTools/Makemain.inc
```

 * Finally, we *include the BuildTools include file Makemain.inc*.  This makes sure that additional maintainer-specific targets are defined (such as an automatic update of the `svn:externals` property when the `Dependencies` file has been changed).  Since values are added to the *DISTCLEANFILES* variable in this include file, this variable has to be "initalized" here. The file `coin_subdirs.txt` is setup by the configure in the base directory and stores the project directories which are recursed into. It is used by project's configure script to find other projects and should be removed when `make distclean` is called.