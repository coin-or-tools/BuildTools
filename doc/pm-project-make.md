


# The Project Main Directory Makefile.am File

In the [directory structure example](./user-directories), the project main directories are `Clp`, `CoinUtils`, and `Osi`.

The purpose of the Makefile here is to recurse into the source code directories to compile the code, to do the project specific installations, and to provide a `test` target to run the project's unit test (if available).

A typical COIN-OR project main subdirectory `Makefile.am` file looks like this example taken from Clp:

```
# Copyright (C) 2011 International Icecream Machines and others.
# All Rights Reserved.
# This file is distributed under the Eclipse Public License.

## $Id: Makefile.am 788 2011-04-01 11:11:11Z johndoe $

# Author:  John Doe              IIM    2011-04-01

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

 * Like in a [base directory Makefile.am file](./pm-base-make), we first specify, in the *SUBDIRS* variable the subdirectories into which to recurse in order to compile the libraries, programs, and whatever other products this project has to offer.  In this examples, this is only one directory, but in order to organize your code, you might want to split the source files into different directories, in which case you need to specify them all here.  These lines with the `ALWAYS_FALSE` Automake conditional (which is always false :) are a trick to skip recursion into the `test` subdirectory for a usual run of `make` to build the products, but it will cause a `make dist` to pick up the files in the `test` directory (even though we don't use the `make dist` mechanism to generate the COIN-OR tarballs.)

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

# Tests

test: all
        cd test; $(MAKE) test

unitTest: test

# Doxygen documentation

doxydoc:
	doxygen doxydoc/doxygen.conf

clean-doxydoc:
	( cd doxydoc ; rm -rf html *.log *.tag )

clean-local: clean-doxydoc
        if test -r test/Makefile; then cd test; $(MAKE) clean; fi

distclean-local:
        if test -r test/Makefile; then cd test; $(MAKE) distclean; fi

install-exec-local: install-doc

uninstall-local: uninstall-doc

.PHONY: test unitTest doxydoc
```

In this section we define some extra targets:

 * The *test* (and *unitTest*) target, which first makes sure that everything has been compiled (since it depends on `all`), changes into the `test` subdirectory, where it runs the `test` target.  If the project does not provide a unit test, this should of course not be there.

 * The *doxydoc* target, which can be used to [generate documentation via doxygen](./pm-doxygen).

 * The *clean-local* and *distclean-local* targets are special Automake targets.  They are "called", when the user does a "`make clean`" and "`make distclean`", respectively. It allows us to specify additional actions for those default targets.  Here, we want to make sure that the `test` subdirectory is cleaned; by default it is not, since it is not included in the `SUBDIRS` variable because the `ALWAYS_FALSE` Automake conditional is always false.  The command line simply checks if the Makefile in the `test` subdirectory exists, and if it does, the corresponding target is made.

 * The *install-exec-local* and *uninstall-local* targets are also special Automake targets. They are "called", when the user does a "`make install`" and "`make uninstall`", respectively. They only redirect to the targets `install-doc` and `uninstall-doc`, which are defined in the file Makemain.inc that is included at the very end and lead to installation (and uninstallation) of the files `README`, `INSTALL`, and `LICENSE`, if present.

```
########################################################################
#                    Installation of the .pc file                      #
########################################################################

pkgconfiglibdir = $(libdir)/pkgconfig
pkgconfiglib_DATA = clp.pc
```

 * These lines take care of *installing a pkg-config configuration file* when `make install` is executed. This files is used by the COIN-OR build system to communicate project dependencies, compiler flags, and linker flags between projects. Installation of the `.pc` file allows other projects to easily build against this project by requesting compiler and linker flags via pkg-config.

 *Note* that the .pc file is also installed if the use of pkg-config has been disabled or pkg-config is not available. Since it still contains valid information, there is no reason to not install the file.

```
########################################################################
#                    Creation of the addlibs file                      #
########################################################################

addlibsdir = $(DESTDIR)$(datadir)/coin/doc/Clp
	
install-data-hook:
	`@`$(mkdir_p) "$(addlibsdir)"
if COIN_HAS_PKGCONFIG
	PKG_CONFIG_PATH=`@`COIN_PKG_CONFIG_PATH`@` \
	$(PKG_CONFIG) --libs clp > $(addlibsdir)/clp_addlibs.txt
else
if COIN_CXX_IS_CL
	echo "/libpath:`$(CYGPATH_W) `@`abs_lib_dir`@`` libClp.lib `@`CLPLIB_LIBS_INSTALLED`@`" > $(addlibsdir)/clp_addlibs.txt
else
	echo -L`@`abs_lib_dir`@` -lClp `@`CLPLIB_LIBS_INSTALLED`@` > $(addlibsdir)/clp_addlibs.txt
endif
endif

uninstall-hook:
	rm -f $(addlibsdir)/clp_addlibs.txt
```

 * In previous COIN-OR build systems (i.e., BuildTools 0.5), an *"addlibs file"* was used to communicate additional library link flags required in order to link with the library generated by this project's Makefiles. In the current system (BuildTools >= 0.6), these files are not necessary anymore for building COIN-OR projects, but for backward compatibility reasons, we still install these files for projects that had generated them previously (with the only difference that they now contain all library link flags required to link with a library, not only _additional_ ones).

 * The *`install-data-hook`* target is "executed" by make after files specified in `_DATA` targets have been installed, that is, after the `.pc` files of the project have been installed. The target first makes sure that the directory where the addlibs files is to be installed exists, and then either executes pkg-config (if available) or uses the `X_LIBS_INSTALLED` variables as setup by configure to write the linker flags for the project into the addlibs file.

  The variable `COIN_PKG_CONFIG_PATH` is setup by configure to contain the system `PKG_CONFIG_PATH` accumulated with the installation directories of `.pc` files, so the successive call to pkg-config can find the `.pc` files of the project and all it's dependencies.

  If pkg-config is not used, then the [macros in the project's configure file](./pm-project-config), esp. the _fallback_ mechanism of the `AC_COIN_CHECK_PACKAGE` should have setup a variable `X_LIBS_INSTALLED` where X is a target like `CLPLIB` in this example. This variable contains the linker flags that are _additionally_ necessary to link against the projects library - where it is assumed that all dependencies have been installed already. Together with the flags for linking against the projects library itself, they are writting into the addlibs file.

  Since that is not complicated enough yet, we also distinguish between possible users of the addlibs file here. If the current C++ compiler is the MS or Intel compiler under Windows (cl or icl), then the automake conditional `COIN_CXX_IS_CL` is set to `TRUE`. In this case, we write the linker flags in the syntax expected by this compiler, otherwise we can use standard syntax.

```
########################################################################
#                         Maintainer Stuff                             #
########################################################################

# Files that are generated and should be cleaned with make clean
CLEANFILES = 

# Files that are generated and should be cleaned with make distclean
DISTCLEANFILES =

include BuildTools/Makemain.inc
```

 * This makes sure that some maintainer-specific things are taken care of automatically.  Just copy this to the end of your own `Makefile.am` file.
