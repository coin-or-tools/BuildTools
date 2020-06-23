


# The Package Base Directory configure.ac File

The purpose of the configuration script in a package's base directory (`Coin-Clp` in the [example](./user-directories)) is to test what COIN-OR project subdirectories are present and should be compiled, and then to initiate the configuration in those subdirectories.

The beginning and the end of the file follow the [basic structure](./pm-structure-config) of `configure.ac` files.  The body for a base directory `configure.ac` file then looks like this:

```
.
.
.

##############################################################################
#              Create the libtool script for the subdirectories             #
#############################################################################

AC_COIN_CREATE_LIBTOOL

#############################################################################
#                  Check which subprojects are there                        #
#############################################################################

AC_COIN_MAIN_PACKAGEDIR(Blas,ThirdParty,daxpy.f)
AC_COIN_MAIN_PACKAGEDIR(Lapack,ThirdParty,LAPACK/SRC/dlarf.f)
AC_COIN_MAIN_PACKAGEDIR(Sample,Data)
AC_COIN_MAIN_PACKAGEDIR(Netlib,Data)
AC_COIN_MAIN_PACKAGEDIR(CoinUtils)
AC_COIN_MAIN_PACKAGEDIR(Osi)
AC_COIN_MAIN_PACKAGEDIR(Clp)

#############################################################################
#                  Check for doxygen                                        #
#############################################################################

AC_COIN_DOXYGEN(CoinUtils Osi)

.
.
.
```

 * The *AC_COIN_CREATE_LIBTOOL* macro executes a number of tests, and then creates the [libtool script](./pm-autotools-intro#Libtool).  If this script exists in the base directory, it can be used in the subdirectories, and doesn't have to be recreated there.  Using this macro here speeds up the configuration time considerably.

 * The *AC_COIN_MAIN_PACKAGEDIR* macros tell us (in the first argument) the names of COIN-OR projects that should be compiled for this package. The second argument specifies an optional subdirectory under which the project is found. The optional third argument specifies a source file that need to be present.
 The final configure script checks whether for each project a `configure.ac` file exists and, if the third argument is given, also the specified file is available.
 E.g., for the `Netlib` project it is checked whether `Data/Netlib/configure.ac` exists,
 while for the `Blas` project it is checked whether both `ThirdParty/Blas/configure.ac` and `ThirdParty/Blas/daxpy.f` exist.

 The final configure and Makefiles will recurse into those directories _in the specified order_, i.e., if there are interdependencies, e.g., between libraries, *make sure that you list the project subdirectories in the right order.*  If during the run of `configure` by the user a subdirectory is not found, the configuration and make for that subdirectory is skipped.

 Note that, in the above example, we also specify subdirectories for `ThirdParty` and `Data`. The `ThirdParty` subdirectories contain build systems for third-party codes that may be used by a COIN-OR project. Here, we want configure and make to recurse into a `ThirdParty` directory only if the user provided the corresponding source code. The `Data` subdirectories contain data files required for running the unit tests or example programs.

 * The *AC_COIN_DOXYGEN* macro is used to initialize variables that are used in the doxygen configuration file of the project base directory. See [here](./pm-doxygen) for more information on using Doxygen in COIN-OR.