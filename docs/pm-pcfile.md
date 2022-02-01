


# The pkg-config configuration files of a project

COIN-OR uses [pkg-config](http://en.wikipedia.org/wiki/Pkg-config) to *check for dependencies* of COIN-OR projects, to *communicate compiler and linker flags* that are required to build and link against other projects, and to provide an easy way for users to build and link against COIN-OR projects.


## Introduction

The way it works is that each project provides one or several pkg-config configuration files (so called *`.pc` files*) which contain all necessary information to build and link against a particular library, especially compiler flags that specify the location of header files, linker flags that specify location and names of libraries, and a list of dependencies of this library.

For example, the `clp.pc` file of the Clp library may look like this:
```
prefix=/home/johndoe/Coin-Clp/build
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include/coin

Name: CLP
Description: COIN-OR Linear Programming Solver
URL: https://projects.coin-or.org/Clp
Version: 1.14.0
Libs: -L${libdir} -lClp
Cflags: -I${includedir}
Requires: coinutils 
```

The variable specifications at the top are only used inside the `.pc` file to simplify the specifications in the `Libs` and `Cflags` fields.
The *`Requires` field* gives a list of projects by their `.pc` file name which the Clp library depends on. Here, this is only CoinUtils, which, of course, may have several further dependencies by its own.

The information from a `.pc` file can be accessed via the tool `pkg-config`.
The tool searches the paths given in the *environment variable `PKG_CONFIG_PATH`* for the `.pc` files that correspond to a given package name.

For example, the command
```
pkg-config --exists clp >= 1.13
```
checks whether a Clp library with version at least 1.13 is available. The specification of version number(s) is optional.

The command
```
pkg-config --cflags clp
```
returns the C/C++ compiler flags that are necessary to build against the Clp library _and it's dependencies_, i.e., the location of the CoinUtils and Clp header files.

The command
```
pkg-config --libs clp
```
returns the linker flags that are necessary to link against the Clp library _and it's dependencies_, i.e., the location of the CoinUtils and Clp library, their names, and the linker flags of the CoinUtils dependencies, e.g., Blas, Lapack, Glpk.

The COIN-OR autoconf macro `AC_COIN_CHECK_PACKAGE` uses these commands (if pkg-config is available) to retrieve information which packages are available and how to build and link against them.


## The .pc file of an installed COIN-OR project library

If a COIN-OR project provides a library `xyz` that is also installed, then it should also provide a file `xyz.pc.in` file that can be transformed into a `.pc` file by configure and contains information on how to compile and link against the _installed version_ of the library.

A typical `xyz.pc.in` file may be
```
prefix=`@`prefix`@`
exec_prefix=`@`exec_prefix`@`
libdir=`@`libdir`@`
includedir=`@`includedir`@`/coin

Name: Xyz
Description: COIN-OR Xyz
URL: https://projects.coin-or.org/Xyz
Version: `@`PACKAGE_VERSION`@`
Libs: -L${libdir} -lXyz `@`XYZ_PCLIBS`@`
Cflags: -I${includedir}
Requires: `@`XYZ_PCREQUIRES`@`
```
The variables `prefix`, `exec_prefix`, `libdir`, and `includedir` are setup from default configure variables.
The `Version` field is setup to contain the value of ``@`PACKAGE_VERSION`@``. This variable holds the value of the second parameter of the `AC_INIT` macro in the [beginning of the configure.ac file](./pm-structure-config.md#Beginningofaconfigure.acfile).
The `Libs` and `Requires` fields make use of the variables ``@`XYZ_PCLIBS`@`` and ``@`XYZ_PCREQUIRES`@`` variables as they are setup by the [AC_COIN_CHECK_* macros](./pm-project-config.md#CheckforotherCOIN-ORComponents) in the configure.ac file. They contain an accumulated list of dependencies in form of linker flags and names of `.pc` files, respectively.

The `xyz.pc.in` file is translated into a `xyz.pc` file by replacing all ``@`...`@`` variables by their value as computed by configure, if the `xyz.pc.in` file is listed in the `AC_CONFIG_FILES` macro at
[the end of the configure.ac file](./pm-structure-config.md#TheEndoftheconfigure.acFile).
When "`make install`" is executed, it should be installed together with the `Xyz` library into the directory `$(libdir)/pkgconfig` as described [here](./pm-project-make.md#TheProjectMainDirectoryMakefile.amFile).


## The .pc file of an uninstalled COIN-OR project library

In a classic setup, a user checks out a COIN-OR base directory of a project with the source of that project _and all dependencies_, then configures all projects, builds them, and finally installs them.
Thus, at the time configure is executed for a project, its dependencies have been configured, but not yet been build and installed.
Therefore, one needs to *build against an _uninstalled_ version of a dependency*.

Using pkg-config and .pc files, the distinction between building against installed or uninstalled versions of a dependency can be done mostly transparent for the project.
All it requires is that each dependency `xzy` *additionally provides a file `xyz-uninstalled.pc.in`* that contains information on how to compile and link against the uninstalled version of `xyz`.

When pkg-config is asked about information about a project `xyz`, it checks for both files `xyz-uninstalled.pc` and `xyz.pc` (in this order), so that from the user-side there is no distinction between the build against an uninstalled or an installed library.

A typical `xyz-uninstalled.pc.in` file has the form
```
prefix=`@`prefix`@`
libdir=`@`ABSBUILDDIR`@`/src

Name: Xyz
Description: COIN-OR Xyz
URL: https://projects.coin-or.org/Xyz
Version: `@`PACKAGE_VERSION`@`
Libs: ${libdir}/libXyz.la `@`XYZLIB_PCLIBS`@`
Cflags: -I`@`abs_source_dir`@`/src -I`@`ABSBUILDDIR`@`/inc
Requires: `@`XYZLIB_PCREQUIRES`@`
```
In difference to the `xyz.pc.in` file, the `libdir` is now not set to the library installation directory, but to the *directory where the library is build*: ``@`ABSBUILDDIR`@`/src`. The variable `@`ABSBUILDDIR`@` is automatically setup by configure (in the AC_COIN_FINALIZE macro) to contain the absolute path to the project's build directory.

In the *`Libs` field*, we now do not use `-L/-l` notation to specify the library path and name, but provide the name of the libraries libtool auxiliary file (`.la`) with full (absolute) path.
The reason is that this way the value in the `Libs` field can be used to setup the `_DEPENDENCIES` variable of a binary in a `Makefile.am`, see [here](./pm-source-make.md#SpecifyingLinkingFlags).
Since the location of an uninstalled library depends on whether a shared or static library is build and since the `xyz-uninstalled.pc` files are not meant for use outside of COIN-OR, it is ok to specify an `.la` file here.

In the *`Cflags` field*, we specify the location of header files before the project is installed.
The variable ``@`abs_source_dir`@`` is thereby setup by configure to contain the absolute path of the projects main directory.
Note that next to the `src` subdirectory, we also specify the `inc` directory which contains the `config_xyz.h` file. (This is likely to change in the future.)

The `xyz-uninstalled.pc.in` file is translated into a `xyz-uninstalled.pc` file by replacing all ``@`...`@`` variables by their value as computed by configure, if the `xyz-uninstalled.pc.in` file is listed in the `AC_CONFIG_FILES` macro at
[the end of the configure.ac file](./pm-structure-config.md#TheEndoftheconfigure.acFile).
In order to allow other projects to find this file, it is assumed that it is put into the main build directory of the project.
It should not be installed.

As an example, the `clp-uninstalled.pc` file as generated by configure may be
```
prefix=/home/johndoe/Coin-Clp/build
libdir=/home/johndoe/Coin-Clp/build/Clp/src

Name: CLP
Description: COIN-OR Linear Programming Solver
URL: https://projects.coin-or.org/Clp
Version: 1.14.0
Libs: ${libdir}/libClp.la 
Cflags: -I/home/johndoe/Coin-Clp/build/Clp/src -I/home/johndoe/Coin-Clp/build/Clp/inc
Requires: coinutils 
```


## The NO pkg-config case

One requirement when upgrading the build system to use `.pc files` was that it should still be usable with a basic set of unix tools as before.
I.e., the classic setup where one checks out and builds a project with all its dependencies from source had to be kept working - also in the case where pkg-config is not available or it's use has been disabled by the user (`configure --disable-pkg-config`).

Therefore, the COIN-OR build system contains some *fallback macros which parse `.pc` files by simple shell scripting*.
Of course, this comes with *limitations*, which are:
* It is not possible to build against installed versions of other projects, i.e., the macro ignores `PKG_CONFIG_PATH` and searches only in the configure directories setup by a [project's base configure file](./pm-base-config.md).

* The syntax in the `xyz-uninstalled.pc` file that can be processed by the macro may be limited. (To retrieve compiler and linker flags, the macro replaces the strings `Cflags: ` and `Libs: ` by an `echo` command, then eliminates all remaining lines that start with a string of the form `[A-Za-z]*:`, and finally executes the resulting file as shell script.)

* The Makefiles for examples require the flags to compile and link against the _installed_ version of a package.
  While in a setup with pkg-config, the .pc files can be processed by pkg-config at the time an example is build, this is not possible in a no-pkg-config setup.
  However, since the fallback macro already process `xyz-uninstalled.pc` files, it has been extended to process also `xyz.pc` files _before_ there are installed. This requires that configure writes the `xyz.pc` files into the same directory of the `xyz-uninstalled.pc` files, i.e., the main directory of project xyz.