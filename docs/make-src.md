# The Source Directories Makefile.am Files

The source code directories are usually the `src` directory in a project's subdirectory, or subdirectories under `src`.

The Makefiles in these directories take care of the fun stuff.
They define what is to be built (libraries, executables), how it is built, and where (and if) the products are to be installed.


## Beginning of the Makefile.am File

```
# Copyright (C) 2011 International Icecream Machines and others.
# All Rights Reserved.
# This file is distributed under the Eclipse Public License.
#
# Author:  John Doe           IIM    2011-04-01

include $(top_srcdir)/BuildTools/Makemain.inc
```

As usual, we start with a **copyright note** and **author information**.

The inclusion of `Makemain.inc` makes a variable where to install header files available.

## Building a Library

### Name of the Library

```
# Name of the library compiled in this directory.
# We want it to be installed in the 'lib' directory.
lib_LTLIBRARIES = libClp.la
```

First we tell Automake the **name of the library** that we want to create.
The extension "`.la`" is used, since we are using the Libtool utility to handle libraries, which allows us to build both static and shared libraries on almost all platforms.
The final name of the library(ies) depends on the platform.

In the above example, we use the Automake prefix **`lib_`** to tell Automake that we want this library **to be installed in the `lib` installation directory**.
As the Automake primary we use **`LTLIBRARIES`** (as opposed to `LIBRARIES`) to tell Autoconf that we want to use Libtool.

If we want to build a library that is not going to be installed, we use the **`noinst_`** prefix.
For example, we might have the source code for the final library distributed into different directories, but in the end we only want to install one library that contains everything.
In this case, we can **create auxiliary libraries** in each source code directory (except for one), that are later collected into a single library.
The auxiliary libraries should not be installed.

The corresponding line in the `Makefile.am` file for an auxiliary library then looks like:
```
# Name of the library compiled in this directory.
# We don't want it to be installed since it will be collected into the libCgl library.
noinst_LTLIBRARIES = libCglTwomir.la
```


### Source Files for the Library

```
# List all source files for this library
libClp_la_SOURCES = \
        ClpCholeskyBase.cpp \
        ClpCholeskyDense.cpp \
        ClpCholeskyUfl.cpp \
        Clp_C_Interface.cpp
.
.
.
```

To tell Automake which source files should be compiled in order to build the library, we use the **library name as prefix** (with "`.`" and "`-`" replaced by "`_`") and the **SOURCES** primary.

Based on the extension of the source files, `automake` will figure out how they are to be compiled.
Many COIN-OR projects use **".c" for C code**, **".cpp" for C++ code**, **".f" for Fortran 77 code**, and **".F" for Fortran 90 code**.


### Dependencies on Other Libraries

```
# List all additionally required libraries
libCgl_la_LIBADD = $(CGL_SUBLIBS) $(CGLLIB_LFLAGS)
libCgl_la_DEPENDENCIES = $(CGL_SUBLIBS)
```

If a library depends on other libraries, then t
The **LIBADD** primary tells Autoconf which other libraries a library depends on or should include.

In this example, the final library to be installed is `libCgl` (with the appropriate extension, such as "`.a`").
The `CGL_SUBLIBS` variable contains the names of all Cgl libraries that where build in other directories but are not installed, like the `libCglTwomir.la` from above.
Libtool will then take care of adding the objects from all these libraries into `libCgl`.

The `CGLLIB_LFLAGS` variable contains all additional libraries that the Cgl library depend on, e.g., CoinUtils and Osi.
This variable has been setup in [configure](./configure).
Libtool will record these dependencies in `libCgl.la` and, if building a shared library, ensure that also the shared library (e.g., `libCgl.so`) has these dependencies (e.g., `libCoinUtils.so`, `libOsi.so`) recorded.

The **DEPENDENCIES** primay is used by make to generate dependency rules for the library, so that it is recompiled if one of its dependencies is modified.
The default mechanism of automake for setting up the `DEPENDENCIES` variable does not work here, since it sets up this variable based on the value of the `LIBADD` primary at the time automake is executed.
However, at this time, the values of the `CGL_SUBLIBS` variable is not known, since it is determined by configure, so the dependencies would be incomplete.

## Building a Program


### Name of the Program

```
# Name of the executable compiled in this directory.
# We want it to be installed in the 'bin' directory.
bin_PROGRAMS = clp
```

First we tell Automake the **name of the executable** that we want to create (skip the "`.exe`" extension even if you are working under Windows).
Usually, we want programs to be installed in the `bin` installation directory, as indicated by the **`bin_`** prefix.
However, the unit test program is usually not installed, in which case one uses the **`noinst_`** prefix.


### Source Files for the Executable

```
# List all source files for this executable
clp_SOURCES = ClpMain.cpp
```

Just as for libraries, one lists all source files in a variable which has the **program name as prefix** and uses the **SOURCES** primary.


### Specifying Linking Flags

```
# List all additionally required libraries
clp_LDADD = libClpSolver.la libClp.la $(CLPLIB_LFLAGS)
```

The **LDADD** primary is used to specify all library dependencies of a the binary (using the libtool extension "`.la`"), very similar to the **LIBADD** primary for libraries.
For the `clp` binary, we specify here the ClpSolver and Clp library, and all libraries that are required to link against the Clp library.
This is probably more than actually required, since the ClpSolver library also requires the Clp library and the Clp library also requires what is specified in `$(CLPLIB_LFLAGS)`.



## Additional Flags


### Include Directories

```
########################################################################
#                            Additional flags                          #
########################################################################

# Here list all include flags, relative to this "srcdir" directory.
AM_CPPFLAGS = -I$(srcdir)/.. $(OSICLPLIB_CFLAGS)
```

To specify the compiler flags for include directories for header files, one should use the **AM_CPPFLAGS** variable.
Alternatively, one can specify library specify flags via `libXyz_la_CPPFLAGS` variables.

The [macros that check for other projects and libraries in configure](./configure) already setup a variable that contain all compiler flags (esp. specifications of include directories) necessary to build against these projects.
Additionally, we may have to specify other directories with header files in this project.

In this example, which is taken from `src/OsiClp/Makefile.am` in `Clp`, we specify the path to find the header files for Clp itself `$(srcdir)/..` (= `src/OsiClp/..` = `src`) and all flags that `configure` has assembled for the build of `Clp`.

### Additional Preprocessor Definitions

```
# List additional defines
# CbcOrClpParam seem to require COIN_HAS_CLP so that it knows that it
# is built within Clp
AM_CPPFLAGS += -DCOIN_HAS_CLP
```

Additional flags for the preprocessor should also be added to the **AM_CPPFLAGS** variable.


### Additional Linker Flags

```
# Use additional libtool flags
AM_LDFLAGS = $(LT_LDFLAGS)
```

The `LDFLAGS` primary specifies **additional flags that should be used when linking a library or program**.
Here we set it to the `LT_LDFLAGS`, which is setup by configure.
If the project is a point release, then it contains a libtool option to **specify the version number**, which is then used in the name of the generated library.
It may also contain a flag to indicate an "all-static" build, i.e., that `-static` should be passed to the compiler.

Since the version number applies to libraries but the static flag to binary, `LT_LDFLAGS` is added here for all targets by adding it to the generic `AM_LDFLAGS` target.
(Since results in libtool warnings about specifying a version number for a binary build.)
One can also add additional flags to a specific binary or library via `libXyz_la_LDFLAGS` or `progxyz_LDFLAGS` variables.


## Installation of Header Files

```
########################################################################
#                Headers that need to be installed                     #
########################################################################

# Here list all the header files that are required by a user of the library,
# and that therefore should be installed in 'include/coin-or'
includecoindir = $(pkgincludedir)
includecoin_HEADERS = \
	Clp_C_Interface.h \
	ClpCholeskyBase.hpp \
	ClpCholeskyDense.hpp \
	ClpConstraint.hpp \
	ClpConstraintLinear.hpp \
.
.
.
```

In order to use a library (if it is written in C or C++), a user typically uses some of the header files in the source directories to compile her/his own code.
For this reason, we specify the required header files (which might only be a subset of all header files in the source directory) using the **HEADERS** primary.
The specification of **includecoindir** and the prefix **includecoin_** tells `automake` that these files should be copied into the directory given by `$(pkgincludedir)`, which is defined in `Makemain.inc` as the `coin-or` subdirectory of the `include` installation directory.

```
nobase_includecoin_HEADERS = foo.h bar/bar.h
```

If you need header files to be installed into subdirectories of the include directory instead of the default _flat_ directory structure, you can use the prefix **nobase_includecoin_** instead of **includecoin_**.
In the example, the file `foo.h` is copied to `include/coin-or/foo.h`, while the file `bar/bar.h` is copied to `include/coin-or/bar/bar.h`.

```
#######################################################################
# Create the Config.h file that has all public defines and install it #
#######################################################################

install-exec-local:
	$(install_sh_DATA) config_clp.h $(DESTDIR)$(includecoindir)/ClpConfig.h

uninstall-local:
	rm -f $(DESTDIR)$(includecoindir)/ClpConfig.h

```

As discussed in the [Configuration Header Files page](./config-header), in COIN-OR we don't include the configuration header files `config*.h` directly.
Instead, this is done via the **_Pkg_`Config.h`** file to make sure that the compilation can also be done smoothly in a non-autotools setup.
However, when building against an installed version of a project, only the _public_ configuration header file is required.
Thus, the above lines ensure that the public header is installed as **_Pkg_`Config.h`** file.
**Do not install the _private_ configuration header file `config.h`**, recall the information [here](./config-header).

The `install-exec-local` is run by the generated Makefile for a `make install`, and the commands for `uninstall-local` are executed for a `make uninstall`.
