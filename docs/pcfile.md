# The pkg-config Configuration File

COIN-OR uses [pkg-config](http://en.wikipedia.org/wiki/Pkg-config) to **check for dependencies** to other projects, to **communicate compiler and linker flags** that are required to build and link against other projects, and to provide an easy way for users to build and link against COIN-OR projects.


## Introduction

The way it works is that each project provides one or several pkg-config configuration files (so called **`.pc` files**) which contain all necessary information to build and link against a particular library, especially compiler flags that specify the location of header files, linker flags that specify location and names of libraries, and a list of further dependencies of this library.

For example, the `coinutils.pc` file of the CoinUtils library may look like this:
```
prefix=/usr/local
#prefix=${pcfiledir}/../..
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include/coin-or

Name: CoinUtils
Description: COIN-OR Utilities
URL: https://github.com/coin-or/CoinUtils
Version: master
Cflags: -I${includedir}
Libs: -L${libdir} -lCoinUtils
Requires.private: coinasl coinglpk
#Libs: -L${libdir} -lCoinUtils -lreadline -lncurses -lbz2 -lz -L/opt/intel/mkl/lib/intel64 -lmkl_core -lmkl_intel_lp64 -lmkl_gnu_thread -fopenmp -lm 
#Requires: coinasl coinglpk 
```

The variable specifications at the top are only used inside the `.pc` file to simplify the specifications in the `Libs` and `Cflags` fields.
These fields just specify the `-I` compiler flag to locate the CoinUtils header files and the `-L` and `-l` flags to find and link the CoinUtils library.
The **`Requires` and `Requires.private` field** gives a list of projects by their `.pc` file name which the CoinUtils library depends on.
Here, these are libraries build by the ThirdParty-ASL and ThirdParty-Glpk projects.
However, since the user typically does not need to be aware of this dependency, it is only recorded in the `Requires.private` field.

The information from a `.pc` file can be accessed via the tool `pkg-config`.
The tool searches the paths given in the **environment variable `PKG_CONFIG_PATH`** for the `.pc` files that correspond to a given package name.

For example, the command
```
pkg-config --exists coinutils >= 2.10
```
checks whether a Clp library with version at least 1.13 is available. The specification of version number(s) is optional.

The command
```
pkg-config --cflags coinutils
```
returns the C/C++ compiler flags that are necessary to build against the CoinUtils library _and it's dependencies_, which gives here the location of the CoinUtils, ASL, and Glpk header files.

The command
```
pkg-config --libs coinutils
```
returns the linker flags that are necessary to link against the CoinUtils library _and it's public dependencies_.
Since coinasl and coinglpk are only "privately required", this gives here only the linker flags for the CoinUtils library (which by itself has the dependencies on the ASL and GLPK libraries recorded).

If a static CoinUtils library had been build (e.g., `libCoinUtils.a`), which does not record its dependencies by itself, the last two lines (commented out in this example) would be active:
```
Libs: -L${libdir} -lCoinUtils -lreadline -lncurses -lbz2 -lz -L/opt/intel/mkl/lib/intel64 -lmkl_core -lmkl_intel_lp64 -lmkl_gnu_thread -fopenmp -lm 
Requires: coinasl coinglpk 
```
Now, `pkg-config --libs coinutils` would return the linker flags to link against CoinUtils itself, but also its (now public) dependencies, e.g., readline, libbz2, libz, MKL Lapack, ASL, and Glpk.

The COIN-OR autoconf macro `AC_COIN_CHK_PKG` uses these commands (if pkg-config is available) to retrieve information which packages are available and how to build and link against them.


## The .pc.in file of a library

If a COIN-OR project provides a library `xyz` that is also installed, then it should also provide a `xyz.pc.in` file that can be transformed into a `xyz.pc` file by configure and contains information on how to compile and link against the library after it has been installed.

The `coinutils.pc.in` file is
```
@COIN_RELOCATABLE_FALSE@prefix=@prefix@
@COIN_RELOCATABLE_TRUE@prefix=${pcfiledir}/../..
exec_prefix=@exec_prefix@
libdir=@libdir@
includedir=@includedir@/coin-or

Name: @PACKAGE_NAME@
Description: COIN-OR Utilities
URL: @PACKAGE_URL@
Version: @PACKAGE_VERSION@
Cflags: -I${includedir}
@COIN_STATIC_BUILD_FALSE@Libs: -L${libdir} -lCoinUtils
@COIN_STATIC_BUILD_FALSE@Requires.private: @COINUTILSLIB_PCFILES@
@COIN_STATIC_BUILD_TRUE@Libs: -L${libdir} -lCoinUtils @COINUTILSLIB_LFLAGS_NOPC@
@COIN_STATIC_BUILD_TRUE@Requires: @COINUTILSLIB_PCFILES@
```
The variables `prefix`, `exec_prefix`, `libdir`, and `includedir` are setup from configure variables.
However, if the configure option `--enable-relocatable` has been used, in which case the automake conditional `COIN_RELOCATABLE` has been enabled, then `prefix` is set to be relative to the location of the `.pc` file.
This has the advantage that moving the installed package to another location still provides valid paths, but assumes that the prefix indeed equals `${pcfiledir}/../..`, which may not be the case if the user has specified an own `--libdir`.

The `Name`, `URL`, and `Version` fields are setup to contain the value of `@PACKAGE_NAME@`, `@PACKAGE_URL@`, and `@PACKAGE_VERSION@`, respectively.
These variable hold the value of the first, fifth, and second parameter of the `AC_INIT` macro in the [beginning of the configure.ac file](./configure), respectively.

The `Libs`, `Requires`, and `Requires.private` fields may make use of the variables `XYZ_PCFILES` and `XYZ_LFLAGS_NOPC` as they are setup by the [AC_COIN_CHK_* macros](./configure) in the configure.ac file.
They contain an accumulated list of dependencies in form of linker flags and names of `.pc` files, respectively.
We use here `COINUTILSLIB_LFLAGS_NOPC` instead of `COINUTILSLIB_LFLAGS` to specify only those linker flags that are not retrieved from pkg-config files, as the latter are covered by `Requires: @COINUTILSLIB_PCFILES@`.

`COIN_STATIC_BUILD` is an automake condititional which is true if static libraries are build, i.e., the configure option `--disable-shared` has been used.
Since in this case the library does not record its own dependencies, additional linker flags will be required by those that link against the library.
(See also the comments in the previous section.)

The `xyz.pc.in` file is translated into a `xyz.pc` file by replacing all `@...@` variables by their value as computed by configure, if the `xyz.pc.in` file is listed in the `AC_CONFIG_FILES` macro at [the end of the configure.ac file](./configure).
When "`make install`" is executed, it should be installed together with the `Xyz` library into the directory `$(libdir)/pkgconfig` as described [here](./make-main).
