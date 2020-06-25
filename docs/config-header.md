# Configuration Header Files

Recall the [introduction on configuration header files](./autotools-intro#configuration-header-files).
The `AC_CONFIG_HEADER` macro in `configure.ac` allows to setup a list of configuration header files that convey information about the configuration run to the source code of the package in the form of `#define` statements.
Since the define statements in different projects may define the same symbols (e.g., `PACKAGE_NAME` or `HAVE_ZLIB`), it is undesirable to install a full configuration header file and to require them for building against the package.
On the other hand, sometimes it is necessary to convey some information about a package configuration via the header file to users of that package.


## Private and public header files

Therefore, in COIN-OR, **the convention is to use two header files**, a _private_ header file which has the defines for all symbols that are needed to build the package, and a _public_ header file which has the defines only for symbols that may be required by a user of the package.
**The _private_ header file uses the name `config.h` and must not be installed**.
**The _public_ header file uses the name `config_`_prjct_`.h` when it is uninstalled and will usually get installed with the name _Prjct_`Config.h`**.
It is important that the public header **defines only symbols with unique names**, so conflicts from including several header files are avoided.


## Header files for non-autotools setups

To complicate things further, some COIN-OR developers want to make it possible to compile COIN-OR code in environments which do not support autotools (_e.g._, MS Developer Studio).
In these systems, the `config.h` and `config_`_prjct_`.h` are substituted by header files **`config_default.h` and `config_`_prjct_`_default.h` that define a set of _default_ symbols**.
A user may then have to adjust these files for her system.


## Bringing them all together

The logic which of the four header files to include in which situation is implemented in a fifth header file _Prjct_`Config.h`.
None of the `config*.h` files should ever be included (directly) in any source code (internal or external to the project), but the file _Prjct_`Config.h` should be include instead.
In an autotools build of the project itself, the file `config.h` will be included (through inclusion in _Prjct_`Config.h`).
When someone builds against the library exported by a project after it has been installed, then _Prjct_`Config.h` will be a copy of the public header `config_`_prjct_`.h` and will be included instead.
Further, in a non-autotools based setup, _Prjct_`Config.h` will include either `config_default.h` or `config_`_prjct_`_default.h` (as appropriate for internal versus external building).
The distinction is made by two defines that may be specified as arguments to the compiler command line to distinguish between building the project itself or building another code against this project.
In an autotools setup with configuration header files, the symbol `HAVE_CONFIG_H` is always defined.
Further, the symbol _Prjct_`_BUILD` is defined whenever a file belonging to project _Prjct_ is built.

## Making Symbols visible in Shared Libraries / DLLs

A shared library or DLL does not need to make all symbols (functions, data) visible to users of a library.
On Unix systems, by default all symbols are visible, so that no extra effort is required when building a shared library.
Compilers on Windows typically **do not make any symbol visible in a DLL**, though, so that functions or data that should be visible to a user of a DLL need to be declared as such explictly.
Additionally, when compiling source that uses a DLL, it is required to declare when a function will be imported from a DLL.

Since the syntax used to declare a symbol as visible is compiler dependent and may depend on whether source (usually a header file) is compiled for building a DLL or using a DLL, the configuration headers are used to decide the attribute that is used to mark symbols that are visible in a shared library.
Essentially, for a library XYZ, **the configuration header provides a symbols `XYZLIB_EXPORT`**, which is defined to be
* `__declspec(dllexport)` if Windows DLLs are build and library XYZ is build, or
* `__declspec(dllimport)` if Windows DLLs are build but library XYZ is not build (assuming that library XYZ is used as DLL), or
* `__attribute__((__visibility__("default")))` if a GCC-compatible compiler is used and library XYZ is build,
* empty, otherwise.

Using `__attribute__((__visibility__("default")))` ensures that symbols that use this attribute are visible in a shared library also if the default symbol visibility has been changed, e.g., by using the compiler flag `-fvisibility=hidden`.

That `XYZLIB_EXPORT` has the right value in the various situations is achieved as follows:
* `configure`, in particular macro `COIN_FINALIZE_FLAGS` (see also [the page about configure.ac](./configure)), ensures that `XYZLIB_EXPORT` is defined to be `__declspec(dllimport)` in **the private header file `config.h`** if and only if shared libraries are build on Windows.
  Otherwise, `XYZLIB_EXPORT` is defined to be empty.
* `configure`, in particular macro `COIN_FINALIZE_FLAGS`, also ensures that `XYZLIB_BUILD` is defined when source for library XYZ is compiled (by adding `-DXYZLIB_BUILD` to `XYZLIB_CFLAGS`).
* Symbol `XYZLIB_EXPORT` is also **made available in the public header `config_`_prjct_`.h`**
* _Prjct_`Config.h` redefines `XYZLIB_EXPORT` to be `__declspec(dllexport)` if library XYZ is build (`XYZLIB_BUILD` is defined) and `DLL_EXPORT` is defined.
  The latter is a define that is already added by autotools when building a shared library on Windows.
* _Prjct_`Config.h` redefines `XYZLIB_EXPORT` to be `__attribute__((__visibility__("default")))` if library XYZ is build (`XYZLIB_BUILD` is defined), `DLL_EXPORT` is not defined, but a GCC-compatible compiler is used.
* `config_default.h` and `config_`_prjct_`_default.h` are setup to define `XYZLIB_EXPORT` to be `__declspec(dllimport)`, `__declspec(dllexport)`, or nothing, depending on whether one builds on Windows, `XYZLIB_BUILD` is defined, and `DLL_EXPORT` is defined.

Finally, to declare that a symbol should be visible in (or imported from) a shared library, `XYZLIB_EXPORT` needs to be added to the symbols declaration.
In C++, all symbols that belong to the same class can be made visible by specifying `XYZLIB_EXPORT` between the keyword `class` and the class name.

## Projects with several Libraries

The above mechanisms get further complicated if a project builds several libraries, and some of those may use other of the same project, e.g., Osi.
However, the logic stays essentially the same as described in the previous section, but with _prjct_ replaced by _library_.
One may also use separate `*Config.h` or `config_*` files for each library.

## Example

As an example, before installation, the `CoinUtilsConfig.h` contains
```
#ifndef __COINUTILSCONFIG_H__
#define __COINUTILSCONFIG_H__

#ifdef HAVE_CONFIG_H

#ifdef COINUTILSLIB_BUILD
#include "config.h"

/* overwrite COINUTILSLIB_EXPORT from config.h when building CoinUtils
 * we want it to be __declspec(dllexport) when building a DLL on Windows
 * we want it to be __attribute__((__visibility__("default"))) when building with GCC,
 *   so user can compile with -fvisibility=hidden
 */
#ifdef DLL_EXPORT
 #undef COINUTILSLIB_EXPORT
 #define COINUTILSLIB_EXPORT __declspec(dllexport)
#elif defined(__GNUC__) && __GNUC__ >= 4
 #undef COINUTILSLIB_EXPORT
 #define COINUTILSLIB_EXPORT __attribute__((__visibility__("default")))
#endif

#else
#include "config_coinutils.h"
#endif

#else  /* HAVE_CONFIG_H */

#ifdef COINUTILSLIB_BUILD
#include "config_default.h"
#else
#include "config_coinutils_default.h"
#endif

#endif  /* HAVE_CONFIG_H */

#endif /*__COINUTILSCONFIG_H__*/
```
The files `config.h` and `config_coinutils.h` are created by the autotools scripts at the end of configure from template files `config.h.in` and `config_coinutils.h.in`, because CoinUtils' `configure.ac` file contains the statement
```
AC_CONFIG_HEADER([src/config.h src/config_coinutils.h])
```
Further, the template file `config.h.in` is generated automatically by autoheader when the project manager calls the autotools.
Therefore, only the public header file **config_coinutils.h** needed to be setup, which can be done by copying interesting lines from the private header file.
In case of CoinUtils, the public header is
```
#ifndef __CONFIG_COINUTILS_H__
#define __CONFIG_COINUTILS_H__

/* Library Visibility Attribute */
#undef COINUTILSLIB_EXPORT

/* Define to 1 if CoinUtils uses C++11 */
#undef COINUTILS_CPLUSPLUS11

/* Define to 1 if stdint.h is available for CoinUtils */
#undef COINUTILS_HAS_STDINT_H

/* Define to 1 if stdint.h is available for CoinUtils */
#undef COINUTILS_HAS_CSTDINT

/* Define to 1 if CoinUtils was build with Glpk support enabled */
#undef COINUTILS_HAS_GLPK

/* Define to be the name of C-function for Inf check */
#undef COINUTILS_C_FINITE

/* Define to be the name of C-function for NaN check */
#undef COINUTILS_C_ISNAN

/* Version number of project */
#undef COINUTILS_VERSION

/* Major Version number of project */
#undef COINUTILS_VERSION_MAJOR

/* Minor Version number of project */
#undef COINUTILS_VERSION_MINOR

/* Release Version number of project */
#undef COINUTILS_VERSION_RELEASE

/* Define to 64bit integer type */
#undef COINUTILS_INT64_T

/* Define to integer type capturing pointer */
#undef COINUTILS_INTPTR_T

/* Define to 64bit unsigned integer type */
#undef COINUTILS_UINT64_T

/* Define to type of CoinBigIndex */
#undef COINUTILS_BIGINDEX_T

/* Define to 1 if CoinBigIndex is int */
#undef COINUTILS_BIGINDEX_IS_INT

#endif
```
After a user run configure, the `#undef` statements are replaced by corresponding `#define` statements, depending on the outcome of tests performed by configure.

For a non-autotools based setup, the files `config_default.h` and `config_coinutils_default.h` are provided.
The public header `config_coinutils_default.h` is currently
```
/* Version number of project */
#define COINUTILS_VERSION "master"

/* Major Version number of project */
#define COINUTILS_VERSION_MAJOR 9999

/* Minor Version number of project */
#define COINUTILS_VERSION_MINOR 9999

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
#include <BaseTsd.h>
#define COINUTILS_INT64_T INT64
#define COINUTILS_UINT64_T UINT64
/* Define to integer type capturing pointer */
#define COINUTILS_INTPTR_T LONG_PTR
#else
#define COINUTILS_INT64_T long long
#define COINUTILS_UINT64_T unsigned long long
#define COINUTILS_INTPTR_T intptr_t
#endif

#define COINUTILS_BIGINDEX_T int
#define COINUTILS_BIGINDEX_IS_INT 1

/* Define to 1 if CoinUtils uses C++11 */
#define COINUTILS_CPLUSPLUS11 1

/* Define to 1 if cstdint is available for CoinUtils */
#define COINUTILS_HAS_CSTDINT 1

/* Define to 1 if stdint.h is available for CoinUtils */
#define COINUTILS_HAS_STDINT_H 1

#ifndef COINUTILSLIB_EXPORT
#if defined(_WIN32) && defined(DLL_EXPORT)
#define COINUTILSLIB_EXPORT __declspec(dllimport)
#else
#define COINUTILSLIB_EXPORT
#endif
#endif
```
and the private header file `config_default.h` is
```
/* include the COIN-OR-wide system specific configure header */
#include "configall_system.h"

/* this needs to come before the include of config_coinutils_default.h */
#ifndef COINUTILSLIB_EXPORT
#if defined(_WIN32) && defined(DLL_EXPORT)
#define COINUTILSLIB_EXPORT __declspec(dllexport)
#else
#define COINUTILSLIB_EXPORT
#endif
#endif

/* include the public project specific macros */
#include "config_coinutils_default.h"

/***************************************************************************/
/*             HERE DEFINE THE PROJECT SPECIFIC MACROS                     */
/*    These are only in effect in a setting that doesn't use configure     */
/***************************************************************************/

/* Define to the debug sanity check level (0 is no test) */
#define COINUTILS_CHECKLEVEL 0

/* Define to the debug verbosity level (0 is no output) */
#define COINUTILS_VERBOSITY 0

#ifdef _MSC_VER
/* Define to be the name of C-function for Inf check */
#define COINUTILS_C_FINITE _finite

/* Define to be the name of C-function for NaN check */
#define COINUTILS_C_ISNAN _isnan
#endif

/* Define to 1 if bzlib is available */
/* #define COIN_HAS_BZLIB */

/* Define to 1 if zlib is available */
/* #define COIN_HAS_ZLIB */
```
Since both files need to be setup by the user, here the private header includes the public header to avoid redundancy.
Further, a header `configall_system.h` is included that tries to provide commonly used defines.

Note that the file **config_coinutils.h** is installed as **CoinUtilsConfig.h** for use by users building against the CoinUtils library.
This functionality is implemented by the following lines in `src/Makefile.am`:
```
install-exec-local:
        $(install_sh_DATA) config_coinutils.h $(DESTDIR)$(includecoindir)/CoinUtilsConfig.h

uninstall-local:
        rm -f $(DESTDIR)$(includecoindir)/CoinUtilsConfig.h
```
