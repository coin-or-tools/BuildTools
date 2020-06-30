
 The purpose of the configuration script in a project's main directory (`Clp` and `CoinUtils` in the [example](./user-directories)) is to test everything required for the compilation of the project's source code, and to set up all Makefiles.

The beginning and the end of the file follow the [basic structure](./pm-structure-config) of `configure.ac` files.  The body for a project main directory `configure.ac` contains the following parts:

 * Initialization of tools and checks for programs, such as a compiler.
 * Checks for other COIN components.
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

# If this project depends on external projects, the Externals file in
# the source root directory contains definition of where to find those
# externals.  The following macro ensures that those externals are
# retrieved by svn if they are not there yet.
AC_COIN_PROJECTDIR_INIT

# Check if user wants to produce debugging code
AC_COIN_DEBUG_COMPILE

# Get the name of the C compiler and appropriate compiler options
AC_COIN_PROG_CC

# Get the name of the C++ compiler and appropriate compiler options
AC_COIN_PROG_CXX

# Initialize automake and libtool
AC_COIN_INIT_AUTO_TOOLS
```

 * The *AC_CANONICAL_BUILD* makes the `configure` script check the host type, on which the script is run.

 * *AC_COIN_PROJECTDIR_INIT* is a COIN specific macro that initializes a few things and should be included at this place.

 * The macro *AC_COIN_DEBUG_COMPILE* makes the `--enable-debug` flag available for `configure`.  It also sets the Automake conditional `COIN_DEBUG` accordingly, as well as the `COIN_DEBUG` for the configuration header file.

 * The macros *AC_COIN_PROG_CC* and *AC_COIN_PROG_CXX* determine the name of the C and C++ compiler, and choose the default compiler options.  One only needs to specify those compilers that are required to compile the source code in the project. If the source code contains Fortran files, one should use *AC_COIN_PROG_F77*.

 * Finally, the *AC_COIN_INIT_AUTO_TOOLS* sets up everything that is required to have Automake and Libtool work correctly.


## Check for Other COIN Components

This part looks like this:

```
#############################################################################
#                              COIN components                              #
#############################################################################

AC_COIN_HAS_PROJECT(Cbc)
AC_COIN_HAS_PROJECT(Cgl)
AC_COIN_HAS_PROJECT(Clp)
AC_COIN_HAS_PROJECT(CoinUtils)
AC_COIN_HAS_PROJECT(DyLP)
AC_COIN_HAS_PROJECT(Osi)
AC_COIN_HAS_PROJECT(Sym)
AC_COIN_HAS_PROJECT(Vol)
```

Here, for each COIN project that is required to compile the libraries and programs in this project (including unit tests and example programs), we list its name as the argument of an invocation of *AC_COIN_HAS_PROJECT*.  This example is taken from Cbc; as you see, the project itself should also be listed.

The final `configure` script will search for the project; first, it will check if itself is this package (by comparing with the name that is given to `AC_INIT` at the beginning of the `configure.ac` file), and otherwise looks for a parallel subdirectory with the project's name.

If the project is found, a `#define` will be set in the configuration header files with the name `COIN_HAS_PRJCT` (where `PRJCT` is replaced by the name of the project in all capital letters, e.g., `COIN_HAS_CLP` in the example above).  Also, an Automake conditional with the same name will be set to true.

The projects can be listed in any order.


## Checks For Third-Party Components

For a few third-party packages released under the GNU Public License (GPL), we have defined special COIN macros.
These packages will be used only if the user specifies the `--enable-gnu-packages` flag when running `configure`.
So far, the defined macros are

 * *AC_COIN_CHECK_GNU_ZLIB*: Check for the zlib compression library.
 * *AC_COIN_CHECK_GNU_BZLIB*: Check for the bzlib compression library.
 * *AC_COIN_CHECK_GNU_READLINE*: Check for the readline library.

Each macro checks for the availability of the package if requested by the user with `--enable-gnu-packages`.  If the package is available, it adds the flags required for linking to the `ADDLIBS` output variable, `#define`s the appropriate preprocessor symbol (_e.g._, `COIN_HAS_ZLIB`) in the configuration header file, and defines an Automake conditional with the same name.

We also provide a generic macro for testing the availability of other third-party libraries, called *AC_COIN_HAS_USER_LIBRARY*.
A typical invocation looks like this:

```
AC_COIN_HAS_USER_LIBRARY([Cplex],[CPX],[cplex.h],[CPXgetstat])
```

The arguments have the following meaning:

 1. _Name of the library package_.  This is the name as it will appear in the `configure` output.
 1. _Abbreviation of the library package_.  This should all be in capital letters.  Using `AC_COIN_HAS_USER_LIBRARY` makes `configure` options available to the user to specify the link commands for the library and to specify the directory in which the library header files can be found.  The names of the option flags use the abbreviation given as this second argument.  Continuing with the example, a `--with-cpx-lib` flag will be defined to be used by the user to specify the link commands, and a `--with-cpx-incdir` flag will be defined to specify the directory with the header files.
 1. _Name of a header file_.  This is the name of a header file that should be present in the include directory provided by the user via `-with-cpx-incdir`.  If this file is not found, the `configure` script will terminate with an error message.  If this argument is omitted, the test will not be performed.
 1. _Name of a C function in the library_.  This should be the name of a C function that should be defined in the library.  If the user uses the `--with-cpx-lib` flag, a test is performed to confirm that this function is indeed available.  If it is not available, the `configure` script will fail with an error message.  If this argument is omitted, the test will not be performed.

A user will have to specify both the `--with-cpx-incdir` and `--with-cpx-lib` flags, or none.  After successful completion of the tests, the link commands will be added to the automake output variable `ADDLIBS`.  Also, the preprocessor symbol `COIN_HAS_CPX` for the configuration header file and an Automake conditional with the same name are defined.


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
