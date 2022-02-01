


# Brief Tutorial on Switching from BuildTools 0.5 to 0.7

With BuildTools 0.6, major changes have been made to the COIN-OR build system, and some further adjustments have been made in BuildTools 0.7.
This tutorial attempts to explain how to change the existing build system of a project to use the new build system.

The major changes are:

 1. Support for the *`pkg-config`* command to build lists of dependencies and command line options. Configuration files associated with pkg-config are used when the `pkg-config` command is present.
 1. All dependent projects are treated more or less as "third-party", so that it is now easy to *link against installed versions of COIN-OR projects* (using pkg-config, if it is available). This also means that what were truly "third-party" projects are now treated more or less the same as COIN-OR projects. We provide build, pkg-config, and install support for these projects if source is available and otherwise provide a mechanism for linking to installed libraries, as before.
 1. The generation of *doxygen* documentation has been revised and improved. *Doxygen tag files* are now used to create links between the documentation of several projects. The steps to use this new doxygen system are detailed [at this page](https://projects.coin-or.org/BuildTools/wiki/pm-doxygen).


## What Needs to be Edited

For the purposes of illustration, we shall assume that the project to be switched is Xyz. The project has been checked out with externals in the directory `Root/` with project source code residing in the directory `Root/Xyz`. To make the switch, the following files need to be edited:
 * `Root/configure.ac`
 * `Root/Makefile.am`
 * `Root/Xyz/configure.ac`
 * `Root/Xyz/Makefile.am`
 * `Root/Xyz/src/Makefile.am`
 * `Root/Xyz/test/Makefile.am`
 * `Root/Xyz/examples/Makefile.in`
 * `Root/Externals`
 * `Root/Xyz/src/XyzConfig.h`
 * `Root/Xyz/inc/config_xyz.h`
the following files need to be created:
 * `Root/Xyz/xyz.pc.in`
 * `Root/Xyz/xyz-uninstalled.pc.in`
 * `Root/Dependencies`
and the following files need to be deleted:
 * `Root/Xyz/xyz_addlibs.txt.in`

For using the new doxygen setup, additionally the files
 * `Root/doxydoc/doxygen.conf.in`
 * `Root/Xyz/doxydoc/doxygen.conf.in`
need to be created and the file
 * `Root/doxydoc/doxygen.conf`
need to be deleted.


## Externals to Dependencies

Another change with the new setup is that it is now highly recommended to use release versions in your externals. To make this easy, there is a script called `set_externals` that is part of the build tools that will automatically set your externals. To use it, you maintain a "dependencies" file (usually called `Root/Dependencies`) as opposed to an "externals" file. The dependencies files will usually contain the stable versions on which a project depends in the same format as the current `Externals` file. When you run the command `set_externals Dependencies`, the dependencies files will be parsed and externals set to latest release versions automatically. Note that if your dependencies files contains trunk or specific release versions, these will be used instead, overriding the mechanism for using the latest release version. For example:

```
BuildTools        https://projects.coin-or.org/svn/BuildTools/stable/0.7
Data/Sample       https://projects.coin-or.org/svn/Data/Sample/stable/1.2/
ThirdParty/ASL    https://projects.coin-or.org/svn/BuildTools/ThirdParty/ASL/stable/1.2
ThirdParty/Blas   https://projects.coin-or.org/svn/BuildTools/ThirdParty/Blas/stable/1.2
ThirdParty/Glpk   https://projects.coin-or.org/svn/BuildTools/ThirdParty/Glpk/stable/1.8
ThirdParty/HSL    https://projects.coin-or.org/svn/BuildTools/ThirdParty/HSL/stable/1.3
ThirdParty/Lapack https://projects.coin-or.org/svn/BuildTools/ThirdParty/Lapack/stable/1.3
ThirdParty/Mumps  https://projects.coin-or.org/svn/BuildTools/ThirdParty/Mumps/stable/1.4
CoinUtils         https://projects.coin-or.org/svn/CoinUtils/stable/2.8/CoinUtils
Cbc               https://projects.coin-or.org/svn/Cbc/stable/2.7/Cbc
Cgl               https://projects.coin-or.org/svn/Cgl/stable/0.57/Cgl
Clp               https://projects.coin-or.org/svn/Clp/stable/1.14/Clp
Osi               https://projects.coin-or.org/svn/Osi/stable/0.105/Osi
Vol               https://projects.coin-or.org/svn/Vol/stable/1.3/Vol
DyLP              https://projects.coin-or.org/svn/DyLP/stable/1.8/DyLP
Ipopt             https://projects.coin-or.org/svn/Ipopt/stable/3.9/Ipopt
Bonmin            https://projects.coin-or.org/svn/Bonmin/trunk/Bonmin
cppad             https://projects.coin-or.org/svn/CppAD/stable/20110101
```

See also the updated documentation on [Handling Subversion Externals](./pm-svn-externals.md).


## Changes to Installation Directories

This is a list where *things get installed*.

- pkgconfig files (.pc) go to `<libdir>/pkgconfig`

- binaries of coin projects go to `<bindir>`

- libraries of coin projects go to `<libdir>`

- header files of coin projects go to `<includedir>/coin`

- data goes to `<datadir>/coin/Data`

- documentation goes to `<datadir>/coin/doc`  [was <datadir>/doc/coin before]

- libraries of coin build third party projects go to `<libdir>`  [was not installed before]

- headers of coin build third party projects go to `<includedir>/coin/ThirdParty`  [was not installed before]

*Defaults* for the above variables are:

- <prefix> = build directory (the directory where configure is called)

- <exec_prefix> = <prefix>

- <bindir> = <exec_prefix>/bin

- <libdir> = <exec_prefix>/lib

- <includedir> = <prefix>/include

- <datadir> = <prefix>/share


## Changes to autotools files


### `Root/configure.ac`

In the `Root/configure.ac` file, the changes are as follows:

 1. Calls to `AC_COIN_MAIN_SUBDIRS()` should generally be changed to `AC_COIN_MAIN_PACKAGEDIR()`. For example, `AC_COIN_MAIN_SUBDIRS(CoinUtils)` => `AC_COIN_MAIN_PACKAGEDIR(CoinUtils)`
 1. Calls to `AC_COIN_THIRDPARTY_SUBDIRS()` should *also* be changed to `AC_COIN_MAIN_PACKAGEDIR()` (these packages are treated more or less the same way as COIN-OR packages now). One difference between COIN-OR projects and third part projects is that the source is typically checked out into a subdirectory `ThirdParty` to make the separation clear. There is also a mechanism for checking to make sure that the project source is actually present (since this has to be downloaded separately by the user using the `get.Yyy` script. These capabilities are implemented using the optional second and third arguments of `AC_COIN_MAIN_PACKAGEDIR()`, similar to the arguments of `AC_COIN_THIRDPARTY_SUBDIRS()` previously. The second argument denotes the subdirectory in which the project is to be found and the third argument is a file to check for to make sure that the source is present. So for BLAS, the call would be `AC_COIN_MAIN_PACKAGEDIR(Blas,ThirdParty,daxpy.f)`.
 1. Note also that most calls to `AC_COIN_HAS_USER_LIBRARY()` for libraries like CPLEX are not needed in the `configure.ac` files in the root directory of higher-level projects, as these checks are made in the configure script of `Osi` and the list of libraries needed on the link line is automatically constructed and passed on to the higher-level project.


### `Root/Makefile.am`

In the `Root/Makefile.am` file, the changes are as follows:

 1. The `SUBDIRS` variables does not need to be set to an explicit list of dependencies, the available subdirectories are determined automatically according to which projects are present in source form. So the command `SUBDIRS = $(subdirs)` replaces any command setting the value of `SUBDIRS` that was previously present.
 1. The command `DISTCLEANFILES = coin_subdirs.txt` should be set to clean up the file in which the list of subdirectories was written. Previously, this variable was set to the empty string.


### `Root/Xyz/configure.ac`

 1. The function `AC_COIN_PROJECTDIR_INIT` now takes as an argument the name of the project, so the call would now be `AC_COIN_PROJECTDIR_INIT(Xyz)`.
 1. Calls to `AC_COIN_HAS_PROJECT()` should be replaced with calls to `AC_COIN_CHECK_PACKAGE()`. There are also three arguments now. 
   * The first argument is the name of the "package", which can consist of multiple COIN-OR projects. For example, one can defined a "package" consisting of both CoinUtils and Clp, called `CoinDepend` and make the configuration bail out when any component of the package is not present. This mechanism is meant for cases in which a project is not useful by itself, but only in combination with others. 
   * The second argument are the names the pkg-config files associated with the projects that make up the package, with the optional ability to specify specific required versions (see example below).
   * The third argument can be used to specify a particular library or binary to which the particular dependency applies. This is for cases where the project exports both a library and a binary executable and these have different dependencies. In this case, different command lines are built up for each of them separately.
   * An example of how this comes together is the call `AC_COIN_CHECK_PACKAGE(CoinDepend, [coinutils >= 2.7 osi >= 0.104 alps >= 1.2], [DipLib])`, which defines a package called `CoinDepend` that consists of the trunk versions of CoinUtils, Osi, and Alps. The dependency applies to the Dip library. We'll see below how this specification comes to play in the Makefiles.
 1. Calls to the function `AC_COIN_HAS_USER_LIBRARY()` can generally be replaced with calls to `AC_COIN_CHECK_PACKAGE()` if they apply to solvers to be used through Osi. This is because the `OsiYyy` packages now have pkg-config support. So the call to check for the presence of CPLEX, for example, is now `AC_COIN_CHECK_PACKAGE(Cpx,  [osi-cplex],  [DipLib])`.
  Other uses of the macros `AC_COIN_HAS_USER_LIBRARY` should be renamed to `AC_COIN_CHECK_USER_LIBRARY`.
 1. The list of files to be created by the configure script (listed as arguments to the `AC_CONFIG_FILES` command must now include `xyz.pc` and `xyz-uninstalled.pc` (see below for a description of the corresponding .in files).
 1. The list of configuration header files to be created is changed to `AC_CONFIG_HEADER([src/config.h src/config_xyz.h])`, see below for more information.


### `Root/Xyz/Makefile.am`

The main change here is that we are now replacing the old `xyz_addlibs.txt` file with `xyz.pc` and `xyz-uninstalled.pc` files (see below).

If the pkg-config command is present, an addlibs file can be created in from the `.pc` files.

If the pkg-config command is not present, then the AC_COIN_CHECK_PACKAGE macro in configure has setup variables that contain the flags for linking against installed dependency libraries.
This variable can then be used to setup the addlibs file.

So we have the following changes:
```
addlibsfile = xyz_addlibs.txt 
addlibsdir = $(prefix)/share/doc/coin/$(PACKAGE_NAME) 
```
should be replaced with
```
pkgconfiglibdir = $(libdir)/pkgconfig 
pkgconfiglib_DATA = xyz.pc
```
The block
```
install-exec-local: install-doc 
        $(install_sh_DATA) $(addlibsfile) $(DESTDIR)$(addlibsdir)/$(addlibsfile) 

uninstall-local: uninstall-doc 
        rm -f $(addlibsdir)/$(addlibsfile) 
```
should be replaced with
```
addlibsdir = $(DESTDIR)$(datadir)/coin/doc/Xyz

install-data-hook: 
       `@`$(mkdir_p) "$(addlibsdir)" 
if COIN_HAS_PKGCONFIG 
       PKG_CONFIG_PATH=`@`COIN_PKG_CONFIG_PATH`@` \ 
       $(PKG_CONFIG) --libs xyz > $(addlibsdir)/xyz_addlibs.txt
else
if COIN_CXX_IS_CL
       echo "-libpath:`$(CYGPATH_W) `@`abs_lib_dir`@`` libxyz.lib `@`XYZLIB_LIBS_INSTALLED`@`" > $(addlibsdir)/xyz_addlibs.txt
else
       echo -L`@`abs_lib_dir`@` -lxyz `@`XYZLIB_LIBS_INSTALLED`@` > $(addlibsdir)/xyz_addlibs.txt
endif
endif 

uninstall-hook: 
        rm -f $(addlibsdir)/xyz_addlibs.txt 
```


### `Root/Xyz/xyz.pc.in`

This is the template for the pkg-config file that will be produced at configure time. It has a very simple form something like the following.
```
prefix=`@`prefix`@`
exec_prefix=`@`exec_prefix`@`
libdir=`@`libdir`@`
includedir=`@`includedir`@`/coin

Name: Xyz
Description: Xyz does nothing useful
Version: `@`PACKAGE_VERSION`@`
Libs: -L${libdir} -lXyz `@`XYZLIB_PCLIBS`@`
Cflags: -I${includedir}
Requires: `@`XYZLIB_PCREQUIRES`@`
```


### `Root/Xyz/xyz-uninstalled.pc.in`

This the pkg-config file for finding uninstalled versions of a given library built from source.
In difference to above, we use here path's in the build directory.
Further, instead of specifying linker flags via -L and -l, we list here the .la file with full path explicitly.
This is necessary to setup the DEPENDENCIES variable in the Makefile's that use project Xyz.
```
prefix=`@`prefix`@`
libdir=`@`ABSBUILDDIR`@`/src
includedir=`@`includedir`@`/coin

Name: Xyz
Description: Xyz does nothing useful
Version: `@`PACKAGE_VERSION`@`
Libs: ${libdir}/libXyz.la `@`XYZLIB_PCLIBS`@`
Cflags: -I`@`abs_source_dir`@`/src
Requires: `@`XYZLIB_PCREQUIRES`@`
```


### `Root/Xyz/src/Makefile.am`

The main difference in the construction of the various `Makefile.am` files is that not so much work has to be done now to build up the command lines and lists of dependent libraries. This is all done automatically. For each package Yyy defined in `configure.ac`, there are now four variables: `YYY_CFLAGS`, `YYY_LIBS`, `YYY_DEPENDENCIES`, and `YYY_DATA` that hold the flags for compiling individual C and C++ files (i.e., the include paths, etc.), the linker flags for linking to dependent libraries, a list of dependent libraries (not using -l or -L syntax), and the directory where a project may store data, respectively. The situation will be slightly different for each project, but for the most part, we can replace blocks like
```
AM_CPPFLAGS = \ 
        -I`$(CYGPATH_W) $(COINUTILSSRCDIR)/src` \ 
        -I`$(CYGPATH_W) $(COINUTILSOBJDIR)/inc` \ 
        -I`$(CYGPATH_W) $(OSISRCDIR)/src`       \ 
        -I`$(CYGPATH_W) $(OSISRCDIR)/inc`
        -I`$(CYGPATH_W) $(CLPSRCDIR)/src` \ 
        -I`$(CYGPATH_W) $(OSISRCDIR)/src/OsiClp`   \ 
        -I`$(CYGPATH_W) $(CLPOBJDIR)/inc` 
myprog_LDADD = $(COINUTILSOBJDIR)/src/libCoinUtils.la    \ 
        $(OSIOBJDIR)/src/libOsi.la    \ 
        $(OSIOBJDIR)/src/OsiClp/libOsiClp.la    \ 
        $(CLPOBJDIR)/src/libClp.la 
```
with something simpler like this:
```
AM_CPPFLAGS = $(COINDEPEND_CFLAGS)
myprog_LDADD = $(COINDEPEND_LIBS)
myprog_DEPENDENCIES = $(COINDEPEND_DEPENDENCIES)
```
Note that the names of the variables correspond exactly to the names given to the libraries and binaries in the third argument `AC_COIN_CHECK_PACKAGE()`, as described in the section on the `Root/Xyz/configure.ac` file above. Hence, the command `AC_COIN_CHECK_PACKAGE(CoinDepend, [coinutils >= 2.7 osi >= 0.104 alps >= 1.2], [XyzLib])` will result in the libraries and flags for each of those dependencies being put into variables called `XYZLIB_LIBS` and `XYZLIB_CFLAGS` respectively.

Further, there is no longer any `ADDLIBS` variable defined, as the additional libraries are all included as dependencies when the lists of libraries are built up.


### `Root/Xyz/test/Makefile.am`

The changes here are similar to those described above. 


### `Root/Xyz/examples/Makefile.in`

The changes to the examples Makefile's are more involved, since compiler and linker flags are assembled differently, depending on whether pkg-config is available or not. Supporting a build under cygwin with cl messes up the Makefile additionally.

Note that currently a build of the examples under cygwin with cl or icl compiler and with pkg-config available is **not supported**.

Further, the changes suggested below will work only with **GNU make**. To support other make's, features like "ifeq" and "+=" have to be avoided. See [here](https://projects.coin-or.org/Ipopt/browser/trunk/Ipopt/examples/Cpp_example/Makefile.in) for an example.

Next to the following, please read also the [updated documentation for COIN-OR users on Makefiles for examples](./user-examples).

A typical examples Makefile.in starts like before:
```
# Copyright (C) ...
# All Rights Reserved.
# This file is distributed under the Eclipse Public License.

# $Id$

##########################################################################
#    You can modify this example makefile to fit for your own program.   #
#    Usually, you only need to change the five CHANGEME entries below.   #
##########################################################################

# To compile other examples, either changed the following line, or
# add the argument DRIVER=problem_name to make
DRIVER = driver

# CHANGEME: This should be the name of your executable
EXE = $(DRIVER)`@`EXEEXT`@`

# CHANGEME: Here is the name of all object files corresponding to the source
#           code that you wrote in order to define the problem statement
OBJS =  $(DRIVER).`@`OBJEXT`@`

# CHANGEME: Additional libraries
ADDLIBS =

# CHANGEME: Additional flags for compilation (e.g., include flags)
ADDINCFLAGS =

# CHANGEME: Directory to the sources for the (example) problem definition
# files
SRCDIR = `@`srcdir`@`
VPATH = `@`srcdir`@`

##########################################################################
#  Usually, you don't have to change anything below.  Note that if you   #
#  change certain compiler options, you might have to recompile the      #
#  COIN package.                                                         #
##########################################################################
```

Next, we define a few variables:
```
COIN_HAS_PKGCONFIG = `@`COIN_HAS_PKGCONFIG_TRUE`@`TRUE
COIN_CXX_IS_CL = `@`COIN_CXX_IS_CL_TRUE`@`TRUE
COIN_HAS_SAMPLE = `@`COIN_HAS_SAMPLE_TRUE`@`TRUE
COIN_HAS_NETLIB = `@`COIN_HAS_NETLIB_TRUE`@`TRUE
```
This leads to storing the value TRUE in COIN_HAS_PKGCONFIG, if pkg-config is used.
Also COIN_CXX_IS_CL is set to TRUE if the MS or Intel compiler (cl, icl) is used under Windows.
The variables COIN_HAS_SAMPLE and COIN_HAS_NETLIB get the value TRUE, if the Sample or Netlib data projects were found during configure.

Setting the compiler and compiler flags works as before:
```
# C++ Compiler command
CXX = `@`CXX`@`

# C++ Compiler options
CXXFLAGS = `@`CXXFLAGS`@`

# additional C++ Compiler options for linking
CXXLINKFLAGS = `@`RPATH_FLAGS`@`

# C Compiler command
CC = `@`CC`@`

# C Compiler options
CFLAGS = `@`CFLAGS`@`
```

Some examples have paths to Data directories compiled into their binaries.
This is achieved by setting a compiler define in the compiler flags:
```
# Sample data directory
ifeq ($(COIN_HAS_SAMPLE), TRUE)
  ifeq ($(COIN_HAS_PKGCONFIG), TRUE)
    CXXFLAGS += -DSAMPLEDIR=\"`PKG_CONFIG_PATH=`@`COIN_PKG_CONFIG_PATH`@` `@`PKG_CONFIG`@` --variable=datadir coindatasample`\"
      CFLAGS += -DSAMPLEDIR=\"`PKG_CONFIG_PATH=`@`COIN_PKG_CONFIG_PATH`@` `@`PKG_CONFIG`@` --variable=datadir coindatasample`\"
  else
    CXXFLAGS += -DSAMPLEDIR=\"`@`SAMPLE_DATA_INSTALLED`@`\"
      CFLAGS += -DSAMPLEDIR=\"`@`SAMPLE_DATA_INSTALLED`@`\"
  endif
endif

# Netlib data directory
ifeq ($(COIN_HAS_NETLIB), TRUE)
  ifeq ($(COIN_HAS_PKGCONFIG), TRUE)
    CXXFLAGS += -DNETLIBDIR=\"`PKG_CONFIG_PATH=`@`COIN_PKG_CONFIG_PATH`@` `@`PKG_CONFIG`@` --variable=datadir coindatanetlib`\"
      CFLAGS += -DNETLIBDIR=\"`PKG_CONFIG_PATH=`@`COIN_PKG_CONFIG_PATH`@` `@`PKG_CONFIG`@` --variable=datadir coindatanetlib`\"
  else
    CXXFLAGS += -DNETLIBDIR=\"`@`NETLIB_DATA_INSTALLED`@`\"
      CFLAGS += -DNETLIBDIR=\"`@`NETLIB_DATA_INSTALLED`@`\"
  endif
endif
```
Here, SAMPLEDIR is defined if COIN_HAS_SAMPLE is TRUE. If pkg-config is available, then the path to the sample directory is obtained by calling pkg-config.
If pkg-config is not available, then the AC_COIN_CHECK_PACKAGE macro in configure.ac should have setup a variable SAMPLE_DATA_INSTALLED that contains the path to the installed sample data. Not that the variable SAMPLE_DATA_INSTALLED is only setup if pkg-config is not available, because only then the coindatasample.pc file is parsed by configure itself.

Next we setup the include-flags.
Again, we distinguish between a setup where pkg-config is available (and thus is used to check for compiler flags) and where it is not available.
In the latter case, the AC_COIN_CHECK_PACKAGE macro should have setup a variable XYZLIB_CFLAGS_INSTALLED.
```
ifeq ($(COIN_HAS_PKGCONFIG), TRUE)
  INCL = `PKG_CONFIG_PATH=`@`COIN_PKG_CONFIG_PATH`@` `@`PKG_CONFIG`@` --cflags xyz`
else
  INCL = `@`XYZLIB_CFLAGS_INSTALLED`@`
endif
INCL += $(ADDINCFLAGS)
```

Finally, the linker flags containing all library dependencies.
If pkg-config is available, then we use it to request the dependencies.
If it is not available, then AC_COIN_CHECK_PACKAGE has setup a variable XYZLIB_LIBS_INSTALLED that contains all dependencies of our project.
Additionally, we need to list the library of our project.
Since the cl and icl compiler use a different syntax, we have to distinguish here between which type of compiler is used.
For the XYZLIB_LIBS_INSTALLED variable, configure has already done this.
```
# Linker flags
ifeq ($(COIN_HAS_PKGCONFIG), TRUE)
  LIBS = `PKG_CONFIG_PATH=`@`COIN_PKG_CONFIG_PATH`@` `@`PKG_CONFIG`@` --libs xyz`
else
  ifeq ($(COIN_CXX_IS_CL), TRUE)
    LIBS = -link -libpath:`$(CYGPATH_W) `@`abs_lib_dir`@`` libXyz.lib `@`XYZLIB_LIBS_INSTALLED`@`
  else
    LIBS = -L`@`abs_lib_dir`@` -lXyz `@`XYZLIB_LIBS_INSTALLED`@`
  endif
endif
```

The rest is as before:
```
# The following is necessary under cygwin, if native compilers are used
CYGPATH_W = `@`CYGPATH_W`@`

# Here we list all possible generated objects or executables to delete them
CLEANFILES = \
        driver.`@`OBJEXT`@` driver`@`EXEEXT`@` \
        driverC.`@`OBJEXT`@` driverC`@`EXEEXT`@`

all: $(EXE)

.SUFFIXES: .cpp .c .o .obj

$(EXE): $(OBJS)
        bla=;\
        for file in $(OBJS); do bla="$$bla `$(CYGPATH_W) $$file`"; done; \
        $(CXX) $(CXXLINKFLAGS) $(CXXFLAGS) -o $`@` $$bla $(LIBS) $(ADDLIBS)

clean:
        rm -rf $(CLEANFILES)

.cpp.o:
        $(CXX) $(CXXFLAGS) $(INCL) -c -o $`@` `test -f '$<' || echo '$(SRCDIR)/'`$<


.cpp.obj:
        $(CXX) $(CXXFLAGS) $(INCL) -c -o $`@` `if test -f '$<'; then $(CYGPATH_W) '$<'; else $(CYGPATH_W) '$(SRCDIR)/$<'; fi`

.c.o:
        $(CC) $(CFLAGS) $(INCL) -c -o $`@` `test -f '$<' || echo '$(SRCDIR)/'`$<


.c.obj:
        $(CC) $(CFLAGS) $(INCL) -c -o $`@` `if test -f '$<'; then $(CYGPATH_W) '$<'; else $(CYGPATH_W) '$(SRCDIR)/$<'; fi`
```


## Changes to configuration header files


### `Root/Xyz/inc/config*` and `Root/Xyz/src/XyzConfig.h`

It is considered a bad thing to distribute configuration files in the way it has been done before.
So far, `XyzConfig.h` had two sections. If the build was occurring on a system where the configure script could run, `XyzConfig.h` would include `config_xyz.h` (the file generated by configure).
If configure wasn't present (e.g., MSVS), `XyzConfig.h` would fall through to the second half.
This would include `configall_system.h` and then add whatever else was necessary.

The new system uses two files generated by configure: `config.h`, which is what is used when building libXyz, and a smaller `config_xyz.h`, which is what a client uses when building against libXyz.
`XyzConfig.h` no longer includes a second section for use by MSVS.
Instead, this information is moved into `config_xyz_default.h` and `config_xyz.h`.

By changing the `configure.ac` statement from `AC_CONFIG_HEADER([config_xyz.h])` to `AC_CONFIG_HEADER([config.h config_xyz.h])`, the new file `config.h` takes the role of the previous `config_xyz.h`. It is created automatically by autoconf, which is run by `run_autotools`. The new `config_xyz.h` is for defining public symbols only. It's template file `config_xyz.h.in` has to be created by hand. See [here](./pm-config-header.md) for more information.

To make it easier to update the MSVS projects, the configuration header files also move from the `inc` directory to the directory where `XyzConfig.h` resides. The change further requires to update the DEFAULT_INCLUDES statement in all Makefile.am files to point to `-I${topbuilddir}/src` instead of `-I${topbuilddir}/inc`, provided the `config.h` file is created in the `src` subdirectory by configure.
Further, the last flag in the Cflags line of `xyz-uninstalled.pc.in` need to be changed to `-I`@`ABSBUILDDIR`@`/src`.