# The `configure.ac` File

Make sure you read the [introduction to the autotools](./autotools-intro) first.
[Here you can find the full autoconf documentation](http://www.gnu.org/software/autoconf/manual/).

The purpose of the configuration script is to test for everything required for
the compilation of the project's source code and assemble the necessary
information to set up all Makefiles.


## General Concepts

Autoconf works by running the macro expansion program `m4` using the
`configure.ac` file as input.
This file contains **macros** that are expanded (recursively) to produce the
`configure` file, a pure `sh` shell script.
The `configure.ac` input file can also contain **`sh` commands**, which will
appear literally in the final `configure` script.

Everything in a line following a "`#`" is a **comment**.
Comments are usually copied into the generated `configure` script unless the
line starts with at least two "`#`" characters.

By convention, macro names are capitalized and start with **`AC_`** if the
macro is an `autoconf` macro, **`AX_`** if it's an `autoconf-archive` macro,
and **`AM_`** if it's an `automake` macro.
We provide additional custom macros for COIN-OR configuration
(in the files `coin*.m4`), which start with **`AC_COIN_`**.
In the [autoconf documentation](http://www.gnu.org/software/autoconf/manual/)
and [autoconf-archive documentation](https://www.gnu.org/software/autoconf-archive/The-Macros.html#The-Macros)
you can find descriptions of the predefined autoconf macros.

Like subroutines, macros can be written to have parameters and can be invoked
with arguments for those parameters.
Parameters and arguments are separated by commas.
The **quotation symbols** for `autoconf` are the square brackets
"`[`" and "`]`".
If a single argument contains a comma, the argument must be quoted by enclosing it in brackets.
If in doubt, use quotation.
If a macro is written to use four parameters, but only two arguments are
provided, the last two parameters are assumed to be unset (equivalent to an
argument of `[]`).

It is possible (indeed, common) to give a shell command as an argument for
a macro.
**Don't forget that `autoconf` and `automake` only perform macro expansion.**
Shell commands given as arguments to macros are just text strings
to `autoconf`.
The shell command will not be executed until the generated `configure` script
is executed.
**This is a feature!**

**Most COIN-OR macros expect literal strings as arguments.**
If you're trying to do clever things with shell variable expansion or shell
commands, you probably want to fall back to the underlying autoconf macros.
Read the
[autoconf documentation](http://www.gnu.org/software/autoconf/manual/)
and the COIN-OR macro source files to understand the limitations.

## The Beginning of a `configure.ac` File

At the beginning of a `configure.ac` file in COIN-OR you will find something
like the following:

```
## Copyright (C) 2011 International Icecream Machines.
# All Rights Reserved.
# This file is distributed under the Eclipse Public License 2.0.
#
# Author:  John Doe                     IIM    2011-04-01

#############################################################################
#                       Names and other basic things                        #
#############################################################################

AC_INIT([SuperSolver],[1.2.1],[https://github.com/coin-or/SuperSolver/issues/new],,[https://github.com/coin-or/SuperSolver])

AC_COPYRIGHT([
Copyright 2011 International Icecream Machines and others.
All Rights Reserved.
This file is part of the open source package COIN-OR which is distributed
under the Eclipse Public License 2.0.])

# List one file in the package so that the configure script can test
# whether the package is actually there
AC_CONFIG_SRCDIR(src/SuperSolverMain.cpp)

# Do some project-level initialization work (version numbers, ...)
AC_COIN_INITIALIZE
```

 * The file should contain the **copyright notice**, information about the **authors**, and state under what **license** the file is made available.

 * The **`AC_INIT`** macro takes as arguments the name of the project, its
   version number, contact information in case a user wants to report a bug, a
   tar ball name (omitted here;
   the default is the project name in lower case: `supersolver`), and a URL.
   The project name and version number determine the name of the preprocessor
   defines for `config.h` that capture the version number
   (`SUPERSOLVER_VERSION`, `SUPERSOLVER_VERSION_MAJOR`,
   `SUPERSOLVER_VERSION_MINOR`, `SUPERSOLVER_VERSION_RELEASE`).

 * The argument of the **`AC_COPYRIGHT`** macro becomes the copyright notice
   in the generated `configure` script.

 * The **`AC_CONFIG_SRCDIR`** macro arranges for a sanity check.
   When the `configure` script is executed, it will test to see if it is in
   the correct location with respect to the code of the project.
   The argument to `AC_CONFIG_SRCDIR` specifies a file (typically a source
   file) that belongs to the project.

 * The **`AC_COIN_INITIALIZE`** macro does several COIN-OR specific
   initializations, like setting automake options, getting the build and
   host type, and setting up the preprocessor defines mentioned above.


## The Body of a `configure.ac` File

After the initialization described above, `configure.ac` usually contains a number of **macros that will be expanded into the tests** that are to be run by the `configure` script.
In general, one
  * checks for the **availability and names of programs** (such as compilers and other tools),
  * tests for the presence of **header files, libraries, _etc._**, including other COIN-OR projects,
  * executes other project specific tests and settings (such as the byte size of a type, _etc._),
  * sets the values of `autoconf` output variables and
    [configuration header](./autotools-intro) `#define`s, and
  * generates links to files required for unit tests or example programs in case of a VPATH configuration.

Autoconf output variables used for substitution in Makefiles, header files,
and other output files generated during configuration are created by
invoking the **`AC_SUBST` macro.
The value of the output variable will be the value of the corresponding shell
variable in the `configure` script.
For example,
```
AC_SUBST(ONEVAR)
ONEVAR="value1 and maybe a few more"

AC_SUBST(TWOVAR,["value2 and yet more"])
```
**The `sh` shell does not allow spaces before and after the '`=`' character!**

In order to include a "`#define`" into the configuration header file that
the `configure` script is going to create, one uses the **`AC_DEFINE`** and
**`AC_DEFINE_UNQUOTED`** macros.

See the [autoconf](http://www.gnu.org/software/autoconf/manual/) and
[automake](http://www.gnu.org/software/automake/manual) documentation
for the full explanation of how variables are substituted into the files
generated during configuration.

A primary goal of COIN-OR configuration is to assemble sets of output
variables specifying the compiler and linker flags necessary to build 
a component of a project (library or executable) from subcomponents.
COIN-OR provides macros `AC_COIN_CHK_PKG` and `AC_COIN_CHK_LIBHDR`
(described in later sections) that check for the presence of
subcomponents and record the information required to use them.
For a component `X`, up to four `autoconf` output variables may be created:
* `X_CFLAGS` accumulates compiler command line flags required to compile `X`.
* `X_LFLAGS` accumulates linker command line flags required to link `X`.
* `X_PCFILES` accumulates the names of `.pc` files for subcomponents that
   provide them.
   At the end of configuration, [`pkgconf`](./pcfile) will be invoked to
   extract compiler and linker flags contained in these files and add them to
   `X_CFLAGS` and `X_LFLAGS`.
* `X_DATA` records the location of data provided by `X`.

Note the subtle difference between `X_DATA` and the other variables.
`X_DATA` records the location of data supplied by `X`.
The other variables record information about subcomponents required to build
`X`.

Borrowing from a later example, the Clp library requires the COIN-OR project
CoinUtils and can be built with MUMPS as an optional subcomponent.
If you look at `config.log`, you can see
* The string `-I/my/build/of/mumps/include -I/my/build/of/mumps/libseq`
  might be part of the value of `CLPLIB_CFLAGS`
* The string `-L/my/build/of/mumps/lib -lmumps`
  might be part of the value of `CLPLIB_LFLAGS`
* The string `coinutils` will be part of the value of `CLPLIB_PCFILES`

For a subcomponent `Z`, the `AC_COIN_CHK_PKG` and `AC_COIN_CHK_LIBHDR`
macros also provide a standard set of `configure`
command line parameters:
* `--with-Z` can be used to control whether or not subcomponent `Z` is
  included in the build of component `X`, overriding any default specified in
  `configure.ac`.
* `--with-Z-cflags` can be used to provide compilation flags
  for `Z`, overriding any defaults specified in `configure.ac`
* `--with-Z-lflags` can be used to provide link flags for
  `Z`, overriding any defaults specified in `configure.ac`
* `--with-Z-data` can be used to specify the location of data provided by
  `Z`, overriding any defaults specified in `configure.ac`

If `Z` provides only data, `--with-Z-cflags` and `--with-Z-lflags` are not
provided as command line parameters.
If `Z` does not provide data, `--with-Z-data` is not provided as a command
line parameter.

Again borrowing from the configuration of the Clp library, `configure`
provides the command line parameters
* `--with-mumps`
* `--with-mumps-lflags`
* `--with-mumps-cflags`

As the author of a `configure.ac` file, you can specify default
compilation flags, link flags, and data locations.
Explicit use of the command line parameters `--with-Z-cflags=string`,
`--with-Z-lflags=string`, or `--with-Z-data=string` allows a user to override
these defaults.
As a nod to common usage, if a string given as `--with-Z=string` is anything
other than `yes` or `no`, it is interpreted as if the user specified
```
--with-Z --with-Z-lflags=string
```
As a special case, if `Z` supplies only data, `--with-Z=string` is
interpreted as
```
--with-Z --with-Z-data=string
```

As the author of a `configure.ac` file, you can specify whether a
subcomponent `Z` should be used by default or skipped by default.
This default choice can be altered at configuration time in the following
ways:
* If the name of subcomponent `Z` appears in the environment variable
  `COIN_SKIP_PROJECTS`, `Z` will be skipped.
  In a departure from standard usage, `COIN_SKIP_PROJECTS` **overrides** the
  configure command line parameters described in the next two bullets.
  This is a feature.
* Explicit use of `--with-Z` or `--with-Z=yes` will force the use of `Z`.
  Explicit use of `--without-Z` or `--with-Z=no` will force `Z` to be skipped.
* Explicit use of any of `--with-Z-cflags=string`, `--with-Z-lflags=string`, or
  `--with-Z-data=string` will force `Z` to be used.


In the following we describe the individual parts of the `configure.ac` file
body in more detail and present examples.


### Initialization of Tools and Compilers

This part usually looks like this:

```
#############################################################################
#                         Standard build tool stuff                         #
#############################################################################

# Get the name of the C, C++, and Fortran compilers and appropriate compiler options.
AC_COIN_PROG_CC
AC_COIN_PROG_CXX
AC_COIN_PROG_F77

# If there is a Fortran compiler, then setup everything to use it, including F77_FUNC
if test -n "$F77" ; then
  AC_COIN_F77_SETUP
fi

# Initialize libtool
AC_COIN_PROG_LIBTOOL

# set RPATH_FLAGS to the compiler link flags required to hardcode location
# of the shared objects (expanded_libdir is set somewhere in configure before)
AC_COIN_RPATH_FLAGS([$expanded_libdir])

# Get the C++ runtime libraries in case we want to link a static library
# with a C or Fortran compiler
AC_COIN_CXXLIBS

# Doxygen
AC_COIN_DOXYGEN

# SUPERSOLVER_VERBOSITY and SUPERSOLVER_DEBUGLEVEL
AC_COIN_DEBUGLEVEL
```

 * The macros **`AC_COIN_PROG_CC`**, **`AC_COIN_PROG_CXX`**, **`AC_COIN_PROG_F77`**, and **`AC_COIN_PROG_FC`** determine the name of the C, C++, Fortran 77, and Fortran 90 compilers, and choose the default compiler options.
   One only needs to specify those compilers that are required to compile the source code in the project.
   If the source code does not contain Fortran source, one should omit **`AC_COIN_PROG_F77`** and **`AC_COIN_PROG_FC`**.
   
 * The macro **`AC_COIN_F77_SETUP`** determines variables required to compile Fortran object files and invoke Fortran functions from C/C++ code.
   This has been separated out from **`AC_COIN_PROG_F77`** to allow a projects configure to succeed even if a Fortran compiler is not found (in which case building of Fortran code must be omitted).

 * The macro **`AC_COIN_PROG_LIBTOOL`** executes a number of tests, and then creates the [libtool script](./autotools-intro).
 
 * The macro **`AC_COIN_RPATH_FLAGS`** defines a variable `RPATH_FLAGS` that can be used by the linker to hardwire the library search path for the given directories into a shared library.
   This is useful to setup Makefiles for examples or tests, but not used for
   the project's own libraries or executable binaries.

 * The macro **`AC_COIN_CXXLIBS`** stores the C++ runtime libraries required for linking a C++ library with a Fortran or C compiler in variable `CXXLIBS`.
   Most projects do not need this macro.

 * The macro **`AC_COIN_DOXYGEN`** macro is used to initialize variables that are used in the doxygen configuration file of the project. See [here](./doxygen) for more information on using Doxygen in COIN-OR.

 * The macro **`AC_COIN_DEBUGLEVEL`** makes the `--with-`_prjct_`-verbosity`, and `--with-`_prjct_`-checklevel` available for `configure`, which allow a finer project-specific control of debug and verbosity levels.


### Check for Packages

Many software components (including COIN-OR projects) provide specification
files (extension `.pc`) for use with the
[pkgconf (previously, pkg-config)](./pcfile) utility.
The `AC_COIN_CHK_PKG` macro described in this section can be used to check
for subcomponents that define a `.pc` file.
Components that supply a `.pc` file are often referred to as packages.

This part looks like this:
```
AC_COIN_CHK_PKG(CoinUtils,[ClpLib OsiClpUnitTest])
if test $coin_has_coinutils != yes ; then
  AC_MSG_ERROR([Required package CoinUtils not available.])
fi
AC_COIN_CHK_PKG(Osi,[OsiClpLib OsiClpUnitTest])
AC_COIN_CHK_PKG(OsiTests,[OsiClpUnitTest],[osi-unittests])
AC_COIN_CHK_PKG(Sample,,[coindatasample],[],dataonly)
AC_COIN_CHK_PKG(Netlib,,[coindatanetlib],[],dataonly)
```

For each subcomponent that is required to build a component (library or
program) in this project (including unit tests and example programs), we
list their names as arguments of an invocation of **`AC_COIN_CHK_PKG`**.
This example is taken from the `configure.ac` file for Clp.
Clp builds a number of components; three, named ClpLib, OsiClpLib, and
OsiClpUnitTest, are involved here. 

All arguments should be literal strings.
The arguments have the following meaning:

1. The first argument is the **name of the subcomponent (package)** to be
   located.
1. The second argument specifies the components being
   built (libraries or executable binaries) which require the first argument
   as a subcomponent.
1. The third argument specifies the **name of the pkgconf file associated
   with the subcomponent**, without the `.pc` extension.
   If the third argument is not given, it defaults to the name of the
   subcomponent, in lower case, _e.g._, `osi`.
   The argument is passed unchanged to pkgconf so it is possible to specify
   version requirements, _e.g._, `[coinutils >= 2.11]`, which pkgconf can
   use to check that the right version of CoinUtils is available.
   It is also possible to specify multiple `.pc` files, _e.g._, `[coinutils >=
   2.11 osi]`; in this case, the name given as the first argument really does
   refer to a package of subcomponents.
   However, specifying multiple `.pc` files can make it difficult to
   determine which subcomponent is responsible for failure.
1. The fourth argument specifies the default usage for the subcomponent, one
   of the strings `default_use` or `default_skip`.
   Most often, configuration is checking for a subcomponent because its 
   use is beneficial, hence the default for this argument is `default_use`.
   Occasionally, it may be useful to define a check with `default_skip`.
   This will make configure command line arguments (described above) available
   to the user, who can then require the subcomponent be used if desired.

1. The fifth argument can be one of the strings `nodata`, `dataonly`, or `both`.
   If the subcomponent provides a library or application but no data, `nodata`
   (the default) is appropriate.
   If the subcomponent provides only data (_e.g._,`Sample` and `Netlib`), use
   `dataonly`.
   If the subcomponent provides both, specify `both`.
   This is used to reduce the number of configure command line options
   (`--with-`_Z_`-*`) created by this macro.

The names used in the first and second arguments can be anything that's
useful for a human.
They are just strings and have no additional meaning other than occasional use
as defaults (_e.g._, construction of a default `.pc` file name from the first
argument).

The general behaviour of `AC_COIN_CHK_PKG` with respect to creation of
variables and command line options is as described
[earlier](#the-body-of-the-configureac-file).

**If any of the configure command line options `--with-`_Z_`-cflags`,
`--with-`_Z_`-lflags`, or `--with-`_Z_`-data` are specified,
`AC_COIN_CHK_PKG` will not check them
for correctness and will ignore the `.pc` file.**
It assumes the user knows what they are doing and declares the subcomponent
found.

If `pkgconf` is available, it is used to check for the existence of the
specified subcomponent using the third argument.
For the `pkgconf` call, the search path for `.pc` files is prefixed with the
`pkgconfig` subdirectory of the library installation directory of the project,
_i.e._, `$libdir/pkgconfig`, to simplify the build and installation of a series
of projects under the same `$prefix`.

**If `pkgconf` is not present, the macro issues a warning and declares the
subcomponent not found.**

If the subcomponent is declared found (either via pkgconf or because configure
command line flags were given), a number of variables are setup.
In the variable names below, `PROJECT` is replaced by the name of the
project being configured (from the first argument to `AC_INIT`),
capitalised.
`SUB` is replaced by the name of the subcomponent (the first
argument to `AC_COIN_CHK_PKG`), capitalised, and `sub` is replaced by the name
of the subcomponent, in lower case.
  * A `#define` will be set in the configuration header files with the
    name `PROJECT_HAS_SUB`.
    _E.g_, for the first `AC_COIN_CHK_PKG` in the example above,
    `CLP_HAS_COINUTILS` will be defined.
  * An Automake conditional with the name `COIN_HAS_SUB` is set to true.
  * The shell variable `coin_has_sub` will be set to `yes`.
  * The **compiler and linker flags, pkgconf dependencies, and data
    directories are augmented** for each library `X` specified in the
    second argument.
    * C/C++ compiler flags are added to `X_CFLAGS` variables.
    * Linker flags are added to `X_LFLAGS` variables.
    * pkgconf dependencies are added to `X_PCFILES` variables.
  * If the subcomponent provides data, a directory where the subcomponent's
    data can be found is stored in a `SUB_DATA` variable.

Note that information about compilation and link flags held in `.pc` files has
**not** been added to the various `X_CFLAGS` and `X_LFLAGS` variables.
The variables `X_CFLAGS` and `X_LFLAGS` are updated at a later point by the
macro `AC_COIN_FINALIZE_FLAGS`.
  
In the example, the following variables for use in Makefiles are created:
* `COIN_HAS_COINUTILS`, `COIN_HAS_OSI`,
  `COIN_HAS_OSITESTS`, `COIN_HAS_SAMPLE`, and `COIN_HAS_NETLIB`,
* `CLPLIB_CFLAGS`, `CLPLIB_LFLAGS`, `CLPLIB_PCFILES`,
* `OSICLPLIB_CFLAGS`, `OSICLPLIB_LFLAGS`, `OSICLPLIB_PCFILES`,
* `OSICLPUNITTEST_CFLAGS`, `OSICLPUNITTEST_LFLAGS`,
  `OSICLPUNITTEST_PCFILES`,
* `SAMPLE_DATA`,
* `NETLIB_DATA`

The values of the `X_PCFILES` variables would be
* `CLPLIB_PCFILES='coinutils'`
* `OSICLPLIB_PCFILES='osi'`
* `OSICLPUNITTEST_PCFILES='coinutils osi osi-unittests'`

If the subcomponent is not found, the configuration does not end with an error.
It sets up variables to indicate the package is not present:
  * An Automake conditional with the name `COIN_HAS_SUB` is set to false.
  * The shell variable `coin_has_sub` will be set to `no`.

As in the example above, the variable `coin_has_sub` can be used in
`configure.ac` to check whether a package is found and stop with an error
if a required package is not found.
In the example, CoinUtils is required, while Osi, OsiTests, Sample,
and Netlib are optional.


### Check for Libraries

For libraries that do not provide a `.pc` file, or where an explicit test for
usability is required, the macro **`AC_COIN_CHK_LIB`** is appropriate.
It sets up the same variables and `#define`s as `AC_COIN_CHK_PKG`.
In addition, it can run compilation and linkage tests to ensure that the
library is usable.

A typical invocation looks like this:
```
AC_COIN_CHK_LIB(MKL,MklTest,
  [-L${MKLROOT}/lib/intel64 -lmkl_intel_ilp64 -lmkl_sequential -lmkl_core],
  [-DMKL_ILP64 -m64 -I${MKLROOT}/include],[],
  [dgemm],[mkl.h])
```

All arguments should be literal strings.
The arguments have the following meaning:

1. The first argument is the **name of the subcomponent (library)** to be
   located.
1. The second argument specifies the components being
   built (libraries or executable binaries) which require this library
   as a subcomponent.
1. The third argument specifies a default set of flags to use to link
   against the library.
1. The fourth argument specifies a default set of flags to use to compile
   against the library package.
1. The fifth argument specifies the default location for data supplied by the
   subcomponent.
1. The sixth argument specifies the name of a C function provided by the
   library.
   If a function name is given, it will be used with the link flags specified
   in the third argument to check that it is possible to link against the
   library.
1. The seventh argument specifies a header file used when compiling code that
   uses the library.
   If a header file name is given, it will be used with the compilation flags
   to check that it is possible to compile the header.
1. The eighth argument (not shown above) specifies the default usage for the
   library, as described for `AC_COIN_CHK_PKG`.
1. The ninth argument (not shown above) specifies whether the subcomponent
   provides just the
   library, just data, or both, as described for `AC_COIN_CHK_PKG`.

Link and compile tests are run only if the sixth and seventh arguments,
respectively, are present.
The link test redeclares the function as void with no arguments (for
the example above, `void dgemm()`).
The compile test checks that the header alone can be compiled.
The library will be declared as not found if any test fails.
If the function name and header file name are both absent, no tests are
performed and the macro will declare the library as found.

As with `AC_COIN_CHK_PKG`, the user can override the default usage, compile
flags, link flags, or data directory from the configure command line.
However, link and compile checks, if requested, are still performed using the
user-specified flags and their results determine whether the subcomponent is
declared to be found or not found.

After completion of the tests, variables are setup in the same way
as for `AC_COIN_CHK_PKG`, with the exception that
`X_PCFILES` is not created or modified by `AC_COIN_CHK_LIB`.

The `AC_COIN_CHK_LIB` macro is a wrapper for a more flexible macro,
`AC_COIN_CHK_LIBHDR`, which provides the additional ability to run a
combined link check using code prologue and code body arguments specified by
the user.
As an illustration, this call of `AC_COIN_CHK_LIBHDR` is equivalent to the
example call of `AC_COIN_CHK_LIB` shown above.
```
AC_COIN_CHK_LIBHDR(MKL,MklTest,
  [-L${MKLROOT}/lib/intel64 -lmkl_intel_ilp64 -lmkl_sequential -lmkl_core],
  [-DMKL_ILP64 -m64 -I${MKLROOT}/include],[],
  [#ifdef __cplusplus
extern "C"
#endif
void dgemm() ;

int main () {
dgemm() ;
return (0) ; }],[#include "mkl.h"],[separate default_use])
```
The first five arguments are exactly as for `AC_COIN_CHK_LIB`.

The eighth argument is augmented with two new keywords, `separate` and
`together`.
* `separate` requests separate compile and link checks.
  The content of the seventh argument (code prologue) is used for the compile
  check.
  The content of the sixth argument (code body) is used for the link check.
* `together` requests that the contents of the code prologue and code body be
  used together as a complete program for the link check.
  The compile check is still performed, using only the code prologue.

`AC_COIN_CHK_LIBHDR` assumes that if both the code prologue and code body are
present it should use both for the link check.
In the example above, `separate` is necessary to avoid including the code
prologue as part of the code used in the link check.

Here's an example invocation asking for a link check that
combines the seventh (code prologue) and sixth (code body) arguments.
```
AC_COIN_CHK_LIBHDR(MKL5,Mkl5Test,
  [-L${MKLROOT}/lib/intel64 -lmkl_intel_ilp64 -lmkl_sequential -lmkl_core],
  [-DMKL_ILP64 -m64 -I${MKLROOT}/include],[],
  [const char *transa, *transb ;
   const double *dummy1, *dummy2, *dummy3, *dummy4 ;
   double *dummy5 ;
   const MKL_INT *n, *m, *k, *l, *p, *q ;
   dgemm(transa,transb,n,m,k,dummy1,dummy2,l,dummy3,p,dummy4,dummy5,q) ;],
  [#include "mkl.h"])
```
The eighth and ninth arguments are omitted here.
Their defaults, `together default_use` and `nodata`, are correct for this
case.

As an alternate explanation, useful for those familiar with the underlying
autoconf macros, a simplified version of the code used in the underlying
compile check is
```
AC_LANG_PROGRAM([seventh argument],[])
```
A simplified version of the code used in the underlying separate link check is
```
AC_LANG_SOURCE([sixth argument])
```
and a simplified version of the code used in the underlying combined link
check is
```
AC_LANG_PROGRAM([seventh argument],[sixth argument])
```

### Using One Project Component in Another

It often happens that one component of the project being built uses another
component of the same project as a subcomponent.
The macro `AC_COIN_CHK_HERE` is intended for exactly this use.
Here's an example
```
AC_COIN_FINALIZE_FLAGS([ClpLib OsiClpLib OsiClpUnitTest])
AC_COIN_CHK_HERE([ClpLib],[OsiClpLib],[clp])
```
All arguments should be literal strings.
The arguments have the following meanings:
1. The first argument is the **name of the project component** to be used.
1. The second argument specifies the components being
   built which require the first argument as a subcomponent.
1. The third argument specifies the **name of the pkgconf file associated
   with the project component specified in the first argument**, without
   the `.pc` extension.
   If the third argument is not given, it defaults to the name of the
   subcomponent, in lower case.

Unlike `AC_COIN_CHK_PKG`, the third argument is **not** interpreted by
`pkgconf`.
A simple file name is all that's allowed here.

The reader might have wondered, in the examples above, why the OSI layer for
clp (OsiClpLib) didn't depend on the base clp library (ClpLib).
And there is definitely a `.pc` file, `clp.pc`, created so that other code can
find and use the clp library.
Unfortunately, `clp.pc` will not be created until the end of configuration and
it will not be installed until `make install` is run,
long after the completion of configuration, so `AC_COIN_CHK_PKG` cannot be
used.
Similarly for `libclp.so`, so `AC_COIN_CHK_LIB` cannot be used.

However, all the necessary information --- compilation flags, link flags, and
the name `clp.pc` --- are readily available during the execution of the
`configure` script.
`AC_COIN_CHK_HERE` finds this information and augments the variables
`X_CFLAGS`, `X_FLAGS`, and `X_PCFILES` for the components `X` listed in the
second argument.

For technical reasons (see the description of `AC_COIN_FINALIZE_FLAGS` below),
this macro needs to be run after `AC_COIN_FINALIZE_FLAGS` is run on the
component specified in the first argument.
(In a nutshell, we don't want `pkgconf` looking for a non-existent `.pc`
file.)

### Checks for some specific System Libraries

#### Checks for Math Library, ZLib, BZlib, Readline, and GMP

Special COIN-OR macros are available to check for often used libraries:

 * **`AC_COIN_CHK_LIBM`**: Check for the math library
   (_e.g._, `libm.so` on Linux systems).
 * **`AC_COIN_CHK_BZLIB`**: Check for the bzlib compression library.
 * **`AC_COIN_CHK_GMP`**: Check for the GNU multiple precission library.
 * **`AC_COIN_CHK_GNU_READLINE`**: Check for the GNU readline library.
 * **`AC_COIN_CHK_ZLIB`**: Check for the zlib compression library.

Each macro expects as its argument a list of components being built to
which this dependency applies, as described for the second argument of
`AC_COIN_CHK_PKG`.
For example,
```
AC_COIN_CHK_LIBM(CoinUtilsLib)
```

If the package is available, it adds the flags required for linking to the
`X_LFLAGS` variable for each component in the argument.
The `X_CFLAGS` variable is not modified as it's assumed that the header files
are in a standard system location.
Except for AC_COIN_CHK_LIBM, the macros also
* `#define` the appropriate preprocessor symbol (_e.g._, `COINUTILS_HAS_ZLIB`)
  in the configuration header file,
* define an Automake conditional (_e.g._, `COIN_HAS_ZLIB`), and
* define a shell variable (_e.g._, `coin_has_zlib`),
* add a configure option to disable the check for the library
  (_e.g._, `--disable-zlib`).

Note that CoinUtils already checks for the math library and thus every
project using CoinUtils automatically has the math library in its
dependencies and thus does not need to check for it separately.

#### Check for LAPACK

For Lapack, a customized macro `AC_COIN_CHK_LAPACK` has been setup.

If a user did not specify flags for linking against Lapack using the
configure command line flags `--with-lapack` or `--with-lapack-lflags`,
the macro checks for installed versions of Lapack on the system.
The first checks are for optimised versions that may be found on specific
systems, _e.g._, Intel MKL on multiple system types,
the `Accelerate` framework on macOS, and
the Sun Performance Library on Solaris.
If nothing is found, the macro will look for `lapack.pc` and `blas.pc` and
finally fall back to a generic link check against `-llapack -lblas`.

The argument for this macro is again a list of components being built that
depend on the presence of Lapack.
For example,
```
AC_COIN_CHK_LAPACK(CoinUtilsLib)
```
will add flags to link against Lapack to `COINUTILSLIB_LFLAGS`.

Additionally, the following variables are setup:
* A shell variable `coin_has_lapack` is set to `yes` or `no`.
* An automake conditional `COIN_HAS_LAPACK` is defined.
* A `#define PROJECT_HAS_LAPACK` for configuration headers is defined,
  where `PROJECT` is replaced by the name of the project (from `AC_INIT`),
  capitalised.

To accommodate the wide range of Lapack implementations, `AC_CHK_LAPACK` also
determines the name mangling convention for Lapack functions and
macros `PROJECT_LAPACK_FUNC` and `PROJECT_LAPACK_FUNC_` are added for
configuration headers.

A separate macro to check for Blas only has been omitted, but it can be
assumed that availablity of Lapack is sufficient to indicate availability
of Blas.


### Finalizing compiler and linker flags

`AC_COIN_CHK_PKG` records the `.pc` files for subcomponents in variables
`X_PCFILES`.
The macro **`AC_COIN_FINALIZE_FLAGS`** invokes `pkgconf` to retrieve the
linker and compiler flags from these `.pc` files and augment the
corresponding `X_LFLAGS` and `X_CFLAGS` variables.
This should be done when all dependencies of a component have been checked,
to gain the most benefit from `pkgconf`'s ability to remove duplicate link
and compile flags.

**`AC_COIN_FINALIZE_FLAGS`** takes as its single argument a space-separated
list of component names `X`.
For each of them:
* The current value of `X_LFLAGS` and `X_CFLAGS` is stored in new variables
  `X_LFLAGS_NOPC` and `X_CFLAGS_NOPC`.
  These variables are appropriate to setup `.pc` files for component `X`,
  along with the set of `.pc` files in `X_PCFILES`.
* The compiler and linker flags retrieved by `pkgconf` from the `.pc` files
  in `X_PCFILES` are stored at the beginning of variables `X_LFLAGS` and
  `X_CFLAGS`.
* A configuration header variable `X_EXPORT` is defined and set to
  `__declspec(dllimport)` if shared libraries are being built under Windows.
* `-DX_BUILD` is added to `X_CFLAGS`.
  This can be recognized in the project's header files to expose internal
  detail in the header when the project is being built and hide it when the
  project is simply being used.

To continue the example above, using the macro
```
AC_COIN_FINALIZE_FLAGS(ClpLib)
```
could lead to the following variable values:
* `CLPLIB_CFLAGS_NOPC="-I/my/build/of/mumps/include -I/my/build/of/mumps/libseq"`
* `CLPLIB_LFLAGS_NOPC="-L/my/build/of/mumps/lib -lmumps"`
* `CLPLIB_CFLAGS="-I/usr/local/include/coin-or -I/my/build/of/mumps/include -I/my/build/of/mumps/libseq"`
* `CLPLIB_LFLAGS="-L/usr/local/lib -lCoinUtils -L/my/build/of/mumps/lib -lmumps"`
* `CLPLIB_PCFILES=coinutils`

Note that the compiler and linker flags for CoinUtils, as retrieved from
`coinutils.pc`, have been added to `CLPLIB_CFLAGS` and `CLPLIB_LFLAGS`,
respectively.


### Generation of Links for Data Files

Some unit test programs and example programs require input data files.
In a VPATH configuration (_i.e._, the directory where compilation takes place is different from the directory containing the source files) it is important to make sure that links to those data files exist so that the programs can be run in the compilation directory.

To this purpose, the **`AC_COIN_VPATH_LINK`** macro should be used for each such file, e.g.,
```
AC_COIN_VPATH_LINK(examples/VolUfl/ufl.par)
AC_COIN_VPATH_LINK(examples/VolUfl/data.gz)
```

This macro simply expands to repeated use of the `AC_CONFIG_LINKS` macro:
```
AC_DEFUN([AC_COIN_VPATH_LINK],
[
  m4_foreach_w(linkvar,[$1],[AC_CONFIG_LINKS(linkvar:linkvar)])
])
```

### Project Specific Tests

If you need to perform other tests, you might need to use further autoconf
macros and/or write some `/bin/sh` code.
For this, please consult the
[autoconf documentation](http://www.gnu.org/software/autoconf/manual).
If your project-specific tests start to obscure the main flow of your
`configure.ac`, `run_autotools` supports a project `m4` directory.
See, for example, the CoinUtils project.


## The End of the `configure.ac` File

At the end of the `configure.ac` file, we need to make sure that the
**output is written**.
In COIN-OR, the bottom of the file usually looks like this:

```
##############################################################################
#                   Finish up by writing all the output                   #
##############################################################################

# Here list all the files that configure should create (except for the
# configuration header file)
AC_CONFIG_FILES([Makefile
                 examples/Makefile
                 src/Makefile
                 test/Makefile
                 supersolver.pc.in])

# Here put the location and name of the configuration header file
AC_CONFIG_HEADER([inc/config.h inc/config_supersolver.h])

# Finally, we let configure write all the output...
AC_COIN_FINALIZE
```

 * The **`AC_CONFIG_FILES`** macro takes as its single argument a space-separated list of the files that are to be created from the corresponding `.in` template files.
   These are all the `Makefile`s and maybe some additional files.
   In the example shown here, the project installs a _prjct_`.pc` file, and this will also be created from a template.
   **A template file must exist for each file listed in the argument to `AC_CONFIG_FILES`.**

 * The **`AC_CONFIG_HEADER`** macro takes as its single argument a space-separated list of names of [configuration header](./autotools-intro) files that are to be created by `configure`.
   For the first file in this list, the template will be created by the autotools utility `autoheader`.
   For the remaining ones, the project manager has to provide the template files.

 * The **`AC_COIN_FINALIZE`** macro takes care of actually writing the output.
   Internally, it uses the `AC_OUTPUT` macro, but since additional actions might have to be taken, you should use `AC_COIN_FINALIZE` instead of using `AC_OUTPUT` directly.
   `AC_COIN_FINALIZE` also writes the "configuration successful" message before the `configure` script finally stops.
