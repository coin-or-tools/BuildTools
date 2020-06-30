
 These instructions only pertain to UNIX-like systems, where the `configure` scripts can be run.  If you want to use Microsoft Visual Studio to compile the code, please see the [Visual Studio wiki](http://projects.coin-or.org/MSVisualStudio).

If you have problems, have a look at the [troubleshooting page.](./user-troubleshooting)


## Compiling the Code

Assume that you have [downloaded the package](./user-download) `Pkg` 
in the directory `Coin-Pkg` and that you have [run the configure script](./user-configure) with appropriate options successfully in the directory `Coin-Pkg/build`.

You can now compile the source code, including all subprojects, by typing in `Coin-Pkg/build`
```
make
```
The COIN Makefiles should work with any UNIX `make`.   If you are using GNU make and want to use the parallel compilation feature, you can do this by specifying the `-j N` option to `make`, where `N` is the number of parallel compilations you want to start.  A good value for `N` is the number of available processors plus 1.

If the *compilation fails*, the screen output hopefully helps you to find out what is going wrong.  The output is quite verbose, and you see all command lines that are executed.  Since most of the COIN-OR Makefiles are generated with the GNU packages `automake` and `libtool` they are somewhat complicated and might look confusing.  Unless you know what you are doing, it not easy to change the Makefiles.  If you want to make modifications, you should modify the [Makefile.am files](./pm-autotools) and use the GNU autotools to generate the real Makefile.


## Testing the Compilation

Most of the COIN-OR projects provide a unit test (in the `test` subdirectory), which can be used to verify if the compiled code works correctly.  If you want to test the compilation for the main project only (e.g., `Clp`) you type in `Coin-Clp/build`

```
make test
```

If you want to run the tests for all subprojects (e.g. `CoinUtils` and `Clp`), type in `Coin-Clp`

```
make tests
```

This will run the available unit test for `Clp` and all other downloaded COIN-OR projects.

You don't need to type `make` before running `make test` or `make tests`.


## Installing the Executables, Libraries and Header Files

To install the final product of the compilation (the reason you are doing all this work) you type 

```
make install
```

Again, you don't need to type `make` first.  This will install the executable files in `$prefix/bin`, the libraries in `$prefix/lib`, the header files in `$prefix/include/coin`, documentation in `$prefix/share/coin/doc/Pkg`, and data files in `$prefix/share/coin/Data/Pkg`.  Here, `$prefix` stands for the installation directory, which by default is the directory in which you ran the `configure` script (which on this page we assumed to be `Coin-Pkg/build`).  The installation directory is otherwise the argument you specified with the `--prefix` argument for `configure`.

In the `share/coin/doc/Pkg` directory you may also see a *pkg_addlibs.txt* file (such as `clp_addlibs.txt`).  This contains a string with linker flags necessary to link against the library of the Pkg project (such as `-lz` if you are using the zlib GNU package), adapted to your system and configuration settings.  If you want to link with an installed COIN-OR library, you should either use pkg-config or specify the context of the corresponding `pkg_addlibs.txt` file in the link command.

Some COIN-OR projects come with examples that show how a generated library can be used.  In that case, in the `examples` subdirectory for the project, you will find a simple Makefile to compile the examples, adapted to your settings.  *If you want to link your own code with a COIN-OR library, it is probably best to start with this example Makefile*; read more [here](./user-examples).


## Further Makefile Targets

Additional targets that can be specified in a "make" command are

 * *clean*: This deletes all compiler generated files.

 * *distclean*: This deletes everything that has been created since running the `configure` script, except for installed files.

 * *uninstall*: This deletes all files that have been previously copied by a `make install`, but it doesn't touch any other compiler generated files.
