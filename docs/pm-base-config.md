
 The purpose of the configuration script in a package's base directory (`Coin-Clp` in the [example](./user-directories)) is to test what COIN project subdirectories are present and should be compiled, and then to initiate the configuration in those subdirectories.

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

AC_COIN_MAIN_SUBDIRS(CoinUtils)
AC_COIN_MAIN_SUBDIRS(Data/Netlib)
AC_COIN_MAIN_SUBDIRS(Data/Sample)
AC_COIN_MAIN_SUBDIRS(Data/miplib3)
AC_COIN_MAIN_SUBDIRS(Clp)
AC_COIN_MAIN_SUBDIRS(Vol)
AC_COIN_MAIN_SUBDIRS(Osi)
AC_COIN_MAIN_SUBDIRS(Cgl)
AC_COIN_MAIN_SUBDIRS(Cbc)

.
.
.
```

 * The *AC_COIN_CREATE_LIBTOOL* macro executes a number of tests, and then creates the [libtool script](./pm-autotools-intro#Libtool).  If this script exists in the base directory, it can be used in the subdirectories, and doesn't have to be recreated there.  Using this macro here speeds up the configuration time considerably.

 * The *AC_COIN_MAIN_SUBDIRS* macros tell us the names of subdirectories with COIN projects that should be compiled for this package.  In each subdirectory should also be a `configure.ac` file.  The final configure and Makefiles will recurse into those directories _in the specified order_, i.e., if there are interdependencies, e.g., between libraries, *make sure that you list the project subdirectories in the right order.*  If during the run of `configure` by the user a subdirectory is not found, the configuration and make for that subdirectory is skipped.

 Note that, in the above example, we also specify subdirectories for `Data`; those subdirectories contain data files required for running the unit tests or example programs.