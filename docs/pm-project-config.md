


# The Project Directory configure.ac File

The purpose of the configuration script in a project's main directory (`Clp` and `CoinUtils` in the [example](./user-directories)) is to test everything required for the compilation of the project's source code, and to set up all Makefiles.

The beginning and the end of the file follow the [basic structure](./pm-structure-config.md) of `configure.ac` files.  The body for a project main directory `configure.ac` contains the following parts:

 * Initialization of tools and checks for programs, such as a compiler.
 * Checks for other COIN-OR components.
 * Checks for third party libraries (such as GNU's zlib or a third party LP solver).
 * Generation of links to files required for unit tests or example programs in case of a VPATH configuration.
 * Other project specific tests and settings (such as the byte size of a type, the existence of header files, _etc._).

In the following we describe the individual parts of the `configure.ac` file body in more detail and present examples.


## Initialization of Tools and Compilers

This part usually looks like this:

```
#############################################################################
#                         Standard build tool stuff                         #
#############################################################################

# Get the system type
AC_CANONICAL_BUILD

# Initialize the project directory
AC_COIN_PROJECTDIR_INIT(Prjct)

# Check if user wants to produce debugging code
AC_COIN_DEBUG_COMPILE(Prjct)

# Get the name of the C compiler and appropriate compiler options
AC_COIN_PROG_CC

# Get the name of the C++ compiler and appropriate compiler options
AC_COIN_PROG_CXX

# Initialize automake and libtool
AC_COIN_INIT_AUTO_TOOLS
```

 * The *AC_CANONICAL_BUILD* makes the `configure` script check the host type, on which the script is run.

 * *AC_COIN_PROJECTDIR_INIT* is a COIN-OR specific macro that should be included at this place. It initializes a few things such as preprocessor defines for the projects version number in `config_`_prjct_`.h`.

 * The macro *AC_COIN_DEBUG_COMPILE* makes the `--enable-debug` flag available for `configure`.  It also sets the Automake conditional `COIN_DEBUG` accordingly, as well as the `COIN_DEBUG` for the configuration header file.
 Further, if the argument _prjct_ is given, the flags `--enable-debug-`_prjct_, `--with-`_prjct_`-verbosity`, and `--with-`_prjct_`-checklevel` are made available for `configure` which allow a finer project-specific control of check, debug, and verbosity levels.

 * The macros *AC_COIN_PROG_CC* and *AC_COIN_PROG_CXX* determine the name of the C and C++ compiler, and choose the default compiler options.  One only needs to specify those compilers that are required to compile the source code in the project. If the source code contains Fortran files, one should use *AC_COIN_PROG_F77*.

 * Finally, the *AC_COIN_INIT_AUTO_TOOLS* sets up everything that is required to have Automake and Libtool work correctly.


## Check for other COIN-OR Components

This part looks like this:
```
#############################################################################
#                             COIN-OR components                            #
#############################################################################

AC_COIN_CHECK_PACKAGE(CoinDepend, [cgl osi >= 0.104 coinutils >= 2.7], [CbcLib CbcGeneric])
if test $coin_has_coindepend != yes ; then
  AC_MSG_ERROR([One or more required packages CoinUtils, Osi, and Cgl are not available.])
fi

# Clp and OsiClp are inseparable here.
AC_COIN_CHECK_PACKAGE(Clp, [osi-clp], [CbcLib CbcGeneric])
if test $coin_has_clp != yes ; then
  AC_MSG_ERROR("Required package Clp unavailable.")
fi

# The rest are not required for linking against Cbc
AC_COIN_CHECK_PACKAGE(OsiTests, [osi-unittests])
AC_COIN_CHECK_PACKAGE(Sample,   [coindatasample])
AC_COIN_CHECK_PACKAGE(Netlib,   [coindatanetlib])
AC_COIN_CHECK_PACKAGE(Miplib3,  [coindatamiplib3])
```

Here, for each group of COIN-OR projects that is required to compile the libraries and programs in this project (including unit tests and example programs), we list their names as arguments of an invocation of *AC_COIN_CHECK_PACKAGE*.  This example is taken from Cbc.

The arguments have the following meaning:

1. The first argument is the *name of the "package"*. A package can consist of multiple COIN-OR projects. 
1. The second argument specifies the *names of the pkg-config files associated with the projects that make up the package*, with the optional ability to specify specific required versions. In this example, "package" `CoinDepend` is defined to consist of CoinUtils, Osi, and Cgl. The configuration will bail out if any component of the package is not present. This mechanism is meant for cases in which a project is not useful by itself, but only in combination with others.
1. The third argument can be used to specify particular libraries or binaries to which the dependency applies, in this case `CbcLib` and `CbcGeneric`.

  The *compiler and linker flags for the package are then accumulated* in corresponding variables that can be used in Makefiles. In the example, variables `CBCLIB_CFLAGS`, `CBCLIB_LIBS`, `CBCGENERIC_CFLAGS`, and `CBCGENERIC_LIBS` are setup that contain the compiler linker flags for using both packages CoinDepend and Clp.

  The possibility to give specify several libraries or binaries in the third argument is for cases where the project exports both a library and a binary executable and these have different dependencies. In this case, different command lines are built up for each of them separately.


The final `configure` script will search for the project, if it was not specified in the `COIN_SKIP_PROJECTS` variable.

First, it checks whether the *user has specified compiler or linker flags or a data directory* via the `--with-`_package_`-lib`/`-incdir`/`-datadir` options.

Then, if pkg-config is available, it is used to check for the existence of the specified project, i.e., the *second argument it passed as it to pkg-config*. Thereby, the search path for pkg-config is enlarged with the build directories of other projects as they have been found by the configure in the projects base directory.

If pkg-config is not available, a *_fallback mechanism*_ is used to search for the specified projects in the  paths setup by the configure in the projects base directory. The fallback ignores specified version number requirements and does not find projects that have already been installed in the system.

If the package is found, a `#define` will be set in the configuration header files with the name `COIN_HAS_PACKAGE` (where `PACKAGE` is replaced by the name of the package in all capital letters, e.g., `COIN_HAS_COINDEPEND` in the example above).  Also, an Automake conditional with the same name will be set to true.

Next to the `_CFLAGS` and `_LIBS` variables, also variables *`X_DATA`, `X_PCLIBS`, `X_PCREQUIRES`* are setup.

The `X_DATA` variable contains the *directory where a package's data can be found*. E.g., if netlib is available, then `NETLIB_DATA` point to the directory where the netlib `.mps` files can be found.

The `X_PCLIBS` and `X_PCREQUIRES` variables are *used to setup the projects `.pc` file*. The `X_PCREQUIRES` variable contains the names of dependencies which provide `.pc` files, while the `X_PCLIBS` contains the linker flags for further dependencies.
E.g., if in the above example, `CoinDepend` was found via pkg-config, then `CBCLIB_PCREQUIRES` and `CBCLIB_PCREQUIRES`, would contain `cgl osi >= 0.104 coinutils >= 2.7` (and possibly also `osi-clp` from the check for the Clp package). The `CBCLIB_PCLIBS` variable would not contain flags for linking against `CoinDepend` in this case.
If, however, the user specified flags on how to link against `CoinDepend` via the `--with-coindepend-lib` configure option, then these flags would be stored in the `CBCLIB_PCLIBS` variable, and the `CBCLIB_PCREQUIRES` variable would be empty.

Finally, if _pkg-config is *not* available_, then additionally the variables *`X_CFLAGS_INSTALLED`, `X_LIBS_INSTALLED`, and `X_DATA_INSTALLED`* are setup. These variables contain the compiler and linker flags and the data directory of the installed package. They can be used to create Makefiles for examples.
If pkg-config is available, then pkg-config should be used in the examples Makefiles to retrieve this data from the installed `.pc` files.


## Checks for some specific System Libraries


### Check for the Math Library

Many projects require the *math library*, specified by `-lm` on Linux systems.
A simple check is available via the *AC_COIN_CHECK_LIBM* macro.
The first argument takes a list of libraries and binaries that have the math library as dependency.
If the math library is available, then their `X_LIBS`, `X_PCLIBS`, and `X_LIBS_INSTALLED` variables will be augmented by the corresponding linker flags.

`Note` that CoinUtils already checks for the math library and thus every project using CoinUtils automatically has the math library in its dependencies and thus does not need to check for it separately.


### Checks for BLAS and LAPACK

For Blas and Lapack, customized macros `AC_COIN_CHECK_PACKAGE_BLAS` and `AC_COIN_CHECK_PACKAGE_LAPACK` have been setup.

For backward compatibility, these macros check additionally the configure options `-with-blas` and `-with-lapack`.
Also they check for installed versions of blas and lapack on the system, e.g., `-lblas` and `-llapack` are tried on Linux systems, the `VecLib` framework is check on MacOS, the Sun Performance Library is checked on Solaris machines, and `MKL` is checked if Intel compilers are used.
If a system library has not been specified, the `AC_COIN_CHECK_PACKAGE` macro is invoked to search for `ThirdParty/Blas` or `ThirdParty/Lapack` or for installed versions of these projects.

The first argument of these macros take the same role as the third argument of the `COIN_CHECK_PACKAGE` macro.


### Checks for GNU libraries

For a few third-party packages released under the GNU Public License (GPL), we have defined special COIN-OR macros.
These packages will be used only if the user specifies the `--enable-gnu-packages` flag when running `configure`.
So far, the defined macros are

 * *AC_COIN_CHECK_GNU_ZLIB*: Check for the zlib compression library.
 * *AC_COIN_CHECK_GNU_BZLIB*: Check for the bzlib compression library.
 * *AC_COIN_CHECK_GNU_READLINE*: Check for the readline library.

Each macro checks for the availability of the package if requested by the user with `--enable-gnu-packages`.  If the package is available, it `#define`s the appropriate preprocessor symbol (_e.g._, `COIN_HAS_ZLIB`) in the configuration header file, defines an Automake conditional with the same name, and adds the flags required for linking to the `X_LIBS`, `X_PCLIBS`, and `X_LIBS_INSTALLED` output variables, where X iterates over all words given in the first argument of the macro.


## Check for User Libraries

We provide a generic macro for testing the availability of other third-party libraries, called *AC_COIN_CHECK_USER_LIBRARY*.
A typical invocation looks like this:

```
AC_COIN_CHECK_USER_LIBRARY([Cplex],[CPX],[cplex.h],[CPXgetstat])
```

The arguments have the following meaning:

 1. _Name of the library package_.  This is the name as it will appear in the `configure` output.
 1. _Abbreviation of the library package_.  This should all be in capital letters.  Using `AC_COIN_CHECK_USER_LIBRARY` makes `configure` options available to the user to specify the link commands for the library and to specify the directory in which the library header files can be found.  The names of the option flags use the abbreviation given as this second argument.  Continuing with the example, a `--with-cpx-lib` flag will be defined to be used by the user to specify the link commands, and a `--with-cpx-incdir` flag will be defined to specify the directory with the header files.
 1. _Name of a header file_.  This is the name of a header file that should be present in the include directory provided by the user via `-with-cpx-incdir`.  If this file is not found, the `configure` script will terminate with an error message.  If this argument is omitted, the test will not be performed.
 1. _Name of a C function in the library_.  This should be the name of a C function that should be defined in the library.  If the user uses the `--with-cpx-lib` flag, a test is performed to confirm that this function is indeed available.  If it is not available, the `configure` script will fail with an error message.  If this argument is omitted or the user specified the configure option `--disable-cpx-libcheck`, the test will not be performed.
 1. _Linker flags required for library check_. This argument can be used to specify additional linker flags that are required for checking whether the C function given in the third argument is available. E.g., if it is known that the library requires the `BLAS` library at linking time, then `$BLAS_LIBS` should be specified here.
 1. _List of targets for which the user library is a dependency_. This argument can be used to specify a list of libraries or binaries which will have the user library as dependency (if available). For each such target X, the variables `X_LIBS`, `X_PCLIBS`, and `X_LIBS_INSTALLED` are augmented with the linker flags specified by `--with-`_userlibrary_`-lib`.

A user will have to specify both the `--with-cpx-incdir` and `--with-cpx-lib` flags, or none.  After successful completion of the tests, the link commands will be stored in the variable `CPXLIB` and the header files include directory in `CPXINCDIR`. Also, the preprocessor symbol `COIN_HAS_CPX` for the configuration header file and an Automake conditional with the same name are defined.


## Generation of Links for Data Files

Some unit test programs and example programs require input data files.  In a VPATH configuration (_i.e._, the directory where compilation takes place is different from the directory containing the source files) it is important to make sure that links to those data files exist so that the programs can be run in the compilation directory.

To this purpose, the *AC_COIN_VPATH_LINK* macro should be used for each such file.  An example of this section of the `configure.ac` file from the Volume project is

```
##############################################################################
#                   VPATH links for example input files                      #
##############################################################################

# In case this is a VPATH configuration we need to make sure that the
# input files for the examples are available in the VPATH directory.

AC_COIN_VPATH_LINK(examples/VolUfl/ufl.par)
AC_COIN_VPATH_LINK(examples/VolUfl/data.gz)
AC_COIN_VPATH_LINK(examples/Volume-LP/data.mps.gz)
AC_COIN_VPATH_LINK(examples/Volume-LP/lp.par)
```


## Project Specific Tests

If you need to perform other tests, you might need to use further autoconf macros and/or write some `/bin/sh` code.  For this, please consult the [autoconf documentation](http://www.gnu.org/software/autoconf/manual/autoconf-2.59/).

If you have questions or run into problems, or would like some help to write a specific test, please submit a ticket at the BuildTools Trac pages, using the "New Ticket" at the top of this page.
