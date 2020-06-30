


# Configuration Header Files

Recall the [introduction on configuration header files](./pm-autotools-intro#ConfigurationHeaderFiles).
The `AC_CONFIG_HEADER` macro in `configure.ac` allows to setup a list of configuration header files that convey information about the configuration run to the source code of the package in the form of `#define` statements.
Since the define statements in different projects may define the same symbols (e.g., `PACKAGE_NAME` or `HAVE_ZLIB`), it is undesirable to install a full configuration header file and to require them for building against the package. On the other hand, sometimes it is necessary to convey some information about a package configuration via the header file to users of that package.


## Private and public header files

Therefore, in COIN-OR, *the convention is to use two header files*, a _private_ header file which has the defines for all symbols that are needed to build the package, and a _public_ header file which has the defines only for symbols that may be required by a user of the package. *The _private_ header file uses the name `config.h` and must not be installed*. *The _public_ header file uses the name `config_`_prjct_`.h` when it is uninstalled and will usually get installed with the name _Prjct_`Config.h`*. It is important that the public header *defines only symbols with unique names*, so conflicts from including several header files are avoided.


## Header files for non-autotools setups

To complicate things further, COIN-OR wants to make it possible to compile COIN-OR code in environments which do not support autotools (_e.g._, MS Developer Studio). In these systems, the `config.h` and `config_`_prjct_`.h` are substituted by header files *`config_default.h` and `config_`_prjct_`_default.h` that define a set of _default_ symbols*. A user may then have to adjust these files for her system.


## Bringing them all together

The logic which of the four header files to include in which situation is implemented in a fifth header file _Prjct_`Config.h`. None of the `config*.h` files should ever be included (directly) in any source code (internal or external to the project), but the file _Prjct_`Config.h` should be include instead.
In an autotools build of the project itself, the file `config.h` will be included (through inclusion in _Prjct_`Config.h`). When someone builds against the library exported by a project after it has been installed, then _Prjct_`Config.h` will be a copy of the public header `config_`_prjct_`.h` and will be included instead. Further, in a non-autotools based setup, _Prjct_`Config.h` will include either `config_default.h` or `config_`_prjct_`_default.h` (as appropriate for internal versus external building).
The distinction is made by two defines that may be specified as arguments to the compiler command line to distinguish between building the project itself or building another code against this project.
In an autotools setup with configuration header files, the symbol `HAVE_CONFIG_H` is always defined. Further, the symbol _Prjct_`_BUILD` is defined whenever a file belonging to project _Prjct_ is built.


## Example

As an example, before installation, the `CoinUtilsConfig.h` contains
```
#ifndef __COINUTILSCONFIG_H__
#define __COINUTILSCONFIG_H__

#ifdef HAVE_CONFIG_H
#ifdef COINUTILS_BUILD
#include "config.h"
#else
#include "config_coinutils.h"
#endif

#else /* HAVE_CONFIG_H */

#ifdef COINUTILS_BUILD
#include "config_default.h"
#else
#include "config_coinutils_default.h"
#endif

#endif /* HAVE_CONFIG_H */

#endif /*__COINUTILSCONFIG_H__*/
```
The files `config.h` and `config_coinutils.h` are created by the autotools scripts at the end of configure from template files `config.h.in` and `config_coinutils.h.in`, because CoinUtils' `configure.ac` file contains the statement
```
AC_CONFIG_HEADER([src/config.h src/config_coinutils.h])
```
Further, the template file `config.h.in` is generated automatically by autoheader when the project manager calls the autotools. Therefore, only the public header file *config_coinutils.h* needed to be setup, which can be done by copying interesting lines from the private header file. In case of CoinUtils, the public header is
```
/* src/config_coinutils.h.in.  */

#ifndef __CONFIG_COINUTILS_H__
#define __CONFIG_COINUTILS_H__

/* Version number of project */
#undef COINUTILS_VERSION

/* Major Version number of project */
#undef COINUTILS_VERSION_MAJOR

/* Minor Version number of project */
#undef COINUTILS_VERSION_MINOR

/* Release Version number of project */
#undef COINUTILS_VERSION_RELEASE

/* Define to 64bit integer type */
#undef COIN_INT64_T

/* Define to integer type capturing pointer */
#undef COIN_INTPTR_T

/* Define to 64bit unsigned integer type */
#undef COIN_UINT64_T

#endif
```
After a user run configure, the `#undef` statements are replaced by corresponding `#define` statements, depending on the outcome of tests performed by configure.

For a non-autotools based setup, the files `config_default.h` and `config_coinutils_default.h` are provided. The public header `config_coinutils_default.h` is currently
```
/* Version number of project */
#define COINUTILS_VERSION      "trunk"

/* Major Version number of project */
#define COINUTILS_VERSION_MAJOR   9999

/* Minor Version number of project */
#define COINUTILS_VERSION_MINOR   9999

/* Release Version number of project */
#define COINUTILS_VERSION_RELEASE 9999

/*
  Define to 64bit integer types. Note that MS does not provide __uint64.

  Microsoft defines types in BaseTsd.h, part of the Windows SDK. Given
  that this file only gets used in the Visual Studio environment, it
  seems to me we'll be better off simply including it and using the
  types MS defines. But since I have no idea of history here, I'll leave
  all of this inside the guard for MSC_VER >= 1200. If you're reading this
  and have been developing in MSVS long enough to know, fix it.  -- lh, 100915 --
*/
#if _MSC_VER >= 1200
# include <BaseTsd.h>
# define COIN_INT64_T INT64
# define COIN_UINT64_T UINT64
  /* Define to integer type capturing pointer */
# define COIN_INTPTR_T ULONG_PTR
#else
# define COIN_INT64_T long long
# define COIN_UINT64_T unsigned long long
# define COIN_INTPTR_T int*
#endif
```
and the private header file `config_default.h` is
```
/* include the COIN-OR-wide system specific configure header */
#include "configall_system.h"

/* include the public project specific macros */
#include "config_coinutils_default.h"

/***************************************************************************/
/*             HERE DEFINE THE PROJECT SPECIFIC MACROS                     */
/*    These are only in effect in a setting that doesn't use configure     */
/***************************************************************************/

/* Define to the debug sanity check level (0 is no test) */
#define COIN_COINUTILS_CHECKLEVEL 0

/* Define to the debug verbosity level (0 is no output) */
#define COIN_COINUTILS_VERBOSITY 0

/* Define to 1 if bzlib is available */
/* #define COIN_HAS_BZLIB */

/* Define to 1 if zlib is available */
/* #define COIN_HAS_ZLIB */

#ifdef _MSC_VER
/* Define to be the name of C-function for Inf check */
#define COIN_C_FINITE _finite

/* Define to be the name of C-function for NaN check */
#define COIN_C_ISNAN _isnan
#endif
```
Since both files need to be setup by the user, here the private header includes the public header to avoid redundancy. Further, a header `configall_system.h` is included that tries to provide commonly used defines.

Note that the file *config_coinutils.h* is installed as *CoinUtilsConfig.h* for use by users building against the CoinUtils library. This functionality is implemented by the following lines in `src/Makefile.am`:
```
install-exec-local:
        $(install_sh_DATA) config_coinutils.h $(DESTDIR)$(includecoindir)/CoinUtilsConfig.h

uninstall-local:
        rm -f $(DESTDIR)$(includecoindir)/CoinUtilsConfig.h
```
