
 This page describes the configuration procedure on UNIX-like systems (including Linux, Solaris, Cygwin, or MSys), where the user can run the `configure` shell script.  Some more Windows-specific notes can be found [here](./user-windows). If you are using Microsoft Visual Studio, you are referred to the [Visual Studio wiki](http://projects.coin-or.org/MSVisualStudio). 

If you have problems, have a look at the [troubleshooting page.](./user-troubleshooting)


## Running the `configure` script

Assume that you have downloaded the package `Pkg` 
in the directory `Coin-Pkg`. (If you downloaded and unpacked a tarball, this directory might have a name like `Pkg-x.y.z`, where `x.y.z` is the point release number.)

Before you can compile the source code using `make`, Makefiles have to be created with the correct compiler names and options, as well as other system-dependent information.  To this purpose, the `configure` shell script in the package's base directory (_e.g._, `Coin-Pkg/configure`) and the `configure` scripts in the included projects' main directories (_e.g._, `Coin-Pkg/Clp/configure`, `Coin-Pkg/CoinUtils/configure`) perform a number of tests and create the final Makefiles.  In addition, a `configure` script usually creates a header file (_e.g_, `Coin-Pkg/Clp/inc/config_clp.h`) for each included project, which contains `#define`s to help the source code adapt to different platforms.

*Note:* You must run the base directory `configure` script (_e.g._, `Coin-Pkg/configure`), not one in the directory of an included project (_e.g._, `Coin-Pkg/Clp/configure`); the latter doesn't work. The base directory `configure` script will recursively run the `configure` scripts in the included project directories.

You can run the configuration scripts in the directories containing the source files.  However, we recommend a "VPATH configuration" ([see below](./user-configure#VpathCompilation)), which compiles the code in a separate directory tree. Briefly, you create a new directory for the compiled code, change into this directory, and then run the configuration script *from the base directory*.  The new directory can be anywhere; the following set of commands assumes that you are in the package's base directory (`Coin-Pkg`):
```
mkdir build
cd build
../configure
```

The `configure` script picks settings for compilers and compiler options.  You can change some aspects of the configuration by providing arguments to the configuration script, as described
[below](./user-configure#GivingOptions).

If the configuration is successful, the `configure` script usually prints a message indicating this.  *If the configuration fails*, the output on the screen, or the more detailed output in one of the `config.log` files, might help to find the cause - see the [Troubleshooting page](./user-troubleshooting).  If you are not able to fix the problem and want to contact the maintainers, you should submit a bug ticket at the corresponding Trac page and attach to the ticket the `config.log` file that has the detailed error message in it.

*Note:*  If you rerun `configure` after a successful configuration run, you should do a *make distclean* if you changed the options for `configure`; see also the `make` target description at the [Compiling and installing the package](./user-compile) page.

== Giving Options to the `configure` Script ==#GivingOptions

There are *two types of arguments* that can be given to the `configure` script.  The first type have the form of *regular command line options*, such as `--enable-debug` or `-C`.  The second type work through *variables*, and those can be provided either on the command line or can be set as environment variables.

An alternative to providing configuration options through the command line is the [config.site file](./user-configure#ConfigDotSiteFile).

For most COIN-OR packages, several configuration scripts are run recursively by the base directory `configure` script.  You need to *specify the options for all included projects* (e.g., `Clp`, or `CoinUtils`) when you run the base `configure` script so that it can pass them to the `configure` scripts for the included projects.

You can see a *list of all available options* by running

```
./configure --help=recursive
```

Also, the file [BuildTools/share/config.site](https://projects.coin-or.org/BuildTools/browser/stable/0.7/share/config.site?format=raw) in each COIN-OR package has a list of some available options.


### Command Line Arguments for `configure`

Command line arguments are given to `configure` in the usual manner for command line arguments.  Some common arguments are described here, but *there might be additional options that you can find on the home pages for the individual COIN-OR projects*.

 * *-C*: Instructs `configure` to *use a cache file, `config.cache`*, to speed up configuration by remembering and reusing the results of tests already performed. The contents of `config.cache` will be consulted by the project scripts when they are called from the base `configure` script. *The contents of config.cache will also be consulted each time `configure` is run again with the `-C` option.*  If you are running `configure` with options that differ from previous runs, it is a good idea to *delete the config.cache file*, so that changes in your local setup are correctly considered.

 * *--prefix*: By default, the binaries and header files are installed (by `make install`) into `bin`, `lib`, and `include` subdirectories of the directory where the main configuration script was run. If you would like `make install` * to install the files in a different location* (such as `$HOME`), you need to use this option, _e.g._, `--prefix=$HOME`.

 * *--enable-debug*: This causes `configure` to select the *debug compiler options*.  It also defines the preprocessor macro `COIN_DEBUG`, which in some source code is use to *activate additional (time-consuming) consistency tests*.

 * *--enable-static*: By default, the COIN-OR libraries are compiled as shared libraries or DLLs on platforms that support this.  If you want *static libraries to be generated as well*, you need to specify this option.

 * *--disable-shared*: If you want *only static libraries* to be compiled and no shared objects or DLLs, you should specify this option.

 * *--enable-gnu-packages*: Some of the COIN-OR projects can make use of GNU packages (such as zlib, bzlib, or readline).  Since they are usually provided under the GPL license, which has rather strong conditions, the configuration scripts do not check for the availability of those packages by default.  If you want to *check for the availability of GNU packages so that they are linked into your code if available*, you need to specify this option. (Depending on your system configuration, it may be necessary to add to CPPFLAGS the path to the relevant include files, and to LDFLAGS the path to the relevant libraries, so that the packages' header and library files can be found).

 * Further options of the form *--enable-...* and *--with-...* might be understood by the configuration scripts *for specific COIN-OR projects*.  For example, if you want to tell the Open Solver Interface (OSI) that you want to compile the CPLEX solver interface, you need to specify the `--with-cplex-lib` and `--with-cplex-incdir` options, with the appropriate values.  If such a value consists of more than one word, you need to enclose it in quotation marks, for example:

    `--with-cplex-lib="-L/usr/share/cplex122/lib/x86-64_sles10_4.1/static_pic -lcplex"`

 assuming that the cplex library (usually named libcplex.a) is located in `/usr/share/cplex122/lib/x86-64_sles10_4.1/static_pic`. Note that on some systems the threading library must be added for cplex to work. In this case, the string is:

    `--with-cplex-lib="-L/usr/share/cplex122/lib/x86-64_sles10_4.1/static_pic -lcplex -lpthread"`

 For the include string:

    `--with-cplex-incdir="/usr/share/cplex122/include/ilcplex"`

 assuming that the header file cplex.h is located in the directory `/usr/share/cplex122/include/ilcplex`.


 A typical call for the configuration script would then looks like

    ```
./configure --with-cplex-lib="-L/usr/share/cplex122/lib/x86-64_sles10_4.1/static_pic -lcplex" \
            --with-cplex-incdir="/usr/share/cplex122/include/ilcplex" \
            --enable-static -C
```


### Variable Arguments for `configure`

Other options, usually related to compilation configuration (such as compiler names and options) can be set as variables.  The values for those variables can be either *provided as environment variables* (_e.g._, set in your shell startup script), *or on the command line*.  Values set on the command line overwrite values set in the environment.  If you want to set the value of a variable (such as `CXX`) in the comamnd line for `configure`, you simply list the variable, followed _immediately_ by an `=` and the value, possibly enclosed in quotation marks (such as CXX="cl").

Commonly used variable arguments are

 * *CC*:  Name of the *C compiler*.  If this is not given, the `configure` script tries a list of compiler names.  You only need to specify this if you are not happy with the default selection.  If you want to compile the code in a non-default bit mode (say, 64-bit on AIX), you should specify the corresponding flag here (_e.g._, `CC='xlc -q64'`), and not in `CFLAGS`.

 * *CFLAGS*:  *C compiler flags*.  If this is not given, the `configure` script chooses a default set of compiler flags, depending on the compiler, operating system, and whether the `--enable-debug` flag is given.

 * *ADD_CFLAGS*: *Additional C compiler flags*.  If you only want to add flags to the compiler flags automatically determined by the `configure` script (as `CFLAGS`), you can set those additional flags with this variable.

 * *CXX*:  Name of the *C++ compiler*.  If this is not given, the `configure` script tries a list of compiler names.  You only need to specify this if you are not happy with the default selection.  If you want to compile the code in a non-default bit mode (say, 64-bit on AIX), you should specify the corresponding flag here (_e.g._, `CXX='xlC -q64'`), and not in `CXXFLAGS`.  This only applies to packages that require the C++ compiler.

 * *CXXFLAGS*:  *C++ compiler flags*.  If this is not given, the `configure` script chooses a default set of compiler flags, depending on the compiler, operating system, and whether the `--enable-debug` flag is given.  This only applies to packages that require the C++ compiler.

 * *ADD_CXXFLAGS*: *Additional C++ compiler flags*.  If you only want to add flags to the compiler flags automatically determined by the `configure` script (as `CXXFLAGS`), you can set those additional flags with this variable.

 * *F77*:  Name of the *Fortran compiler*.  If this is not given, the `configure` script tries a list of compiler names.  You only need to specify this if you are not happy with the default selection.  If you want to compile the code in a non-default bit mode (say, 64-bit on AIX), you should specify the corresponding flag here (_e.g._, `F77='xlf -q64'`), and not in `FFLAGS`.  This only applies to packages that require the Fortran compiler.

 * *FFLAGS*:  *Fortran compiler flags*.  If this is not given, the `configure` script chooses a default set of compiler flags, depending on the compiler, operating system, and whether the `--enable-debug` flag is given.  This only applies to packages that require the Fortran compiler.

 * *ADD_FFLAGS*: *Additional Fortran compiler flags*.  If you only want to add flags to the compiler flags automatically determined by the `configure` script (as `FFLAGS`), you can set those additional flags with this variable.

 * *CDEFS* and *CXXDEFS*:  If you want to have the C or C++ compiler use *additional -D preprocessor macro defintions*, you should list them in these variables (_e.g._, `CDEFS="-DPARANOIA"`).

 * *MAKE*: Program for handling makefiles. The default selection usually works fine. Only on some systems it may be necessary to specify a different `make` program (_e.g._, `MAKE="gmake"`).

 * *AR*:  *Program for handling archives*.  The default selection usually works fine.  Only on some systems (such as AIX), it is necessary to specify additional flags when compiling in 64-bit mode (_e.g._, `AR="ar -X64"`).

 * *NM*:  *Program for listing symbols* in object files.  The default selection usually works fine.  On some systems (such as AIX), it is necessary to specify additional flags when compiling in 64-bit mode (_e.g._, `NM="nm -X64"`).

 * *COIN_SKIP_PROJECTS*:  This variable is used to *specify a list of included projects that should not be compiled*.  For example, if you obtained the Clp package, but do not want to compile the included `Osi` project, you would specify *COIN_SKIP_PROJECTS="Osi"*.  This will skip the compilation of the Osi project and consequently will not create the OsiClp library.

A complete invocation of the configure script could look like:

```
./configure CXX="xlC -q64" CC="xlc -q64" F77="xlf -q64" AR="ar -X64" \
            NM="nm -X64" --enable-gnu-packages -C
```

Invoking the configuration script in Cygwin when using the Microsoft Visual Studio Version 6 compiler typically will look like:

```
./configure -C CXX='cl -GX -GR'
```

== Specifying Options in a `config.site` File ==#ConfigDotSiteFile

Setting all configuration arguments in the command line for `configure` can be somewhat inconvenient.  You can alternatively *specify your choices in a file* that is automatically read when `configure` is run.

The name of this file is `config.site`.  The `configure` script looks for it in the *share subdirectory of the installation directory* (_i.e._, the directory you specify with the `--prefix` argument), or by default in the `share` subdirectory of the directory where you run `configure`.  You can specify a different location and name by setting the environment variable *CONFIG_SITE* to the full path to your `config.site` file, including the file name itself.

The `config.site` file is a *shell script* for `bin/sh` and needs to conform to `sh` syntax.  It is used to set values of shell variables that are used by the `configure` script.  In the case of *variable arguments* (such as `CC`), the name that should be used in `config.site` is identical to the name that is used on the command line.  For arguments of the form `--enable-...`, the corresponding `config.site` variable name is *enable_...* (_i.e._, replace all dashes with underscores). To enable the feature, set the variable to `yes`; to disable it, set the variable to `no`.  For arguments of the form `--with-...`, use the variable name *with_...* (again with all dashes replaced by underscores) and set the variable to the appropriate value.  If no value is required, set it to `yes` to mimic `--with-...`, `no` to mimic `--without...`.

*Note: Since the `config.site` file is a shell script, you must not have any whitespace before or after the "`=`" symbol in a variable assignment! *

An *example [config.site](https://projects.coin-or.org/BuildTools/browser/stable/0.7/share/config.site?format=raw) file* can be found in the `BuildTools/share` directory.

== Performing a VPATH Compilation ==#VpathCompilation

It is possible to *compile the code in a different place than where the source code is* using the VPATH feature of `make`.  This can, for example, be handy if you want to have several compiled versions around (_e.g._, for different operating systems when you are working on a shared files system, or a production and a debug version).

To do a VPATH compilation, you simply run the `configure` script in the directory where you want to place the compiled files.  _E.g._, if the base directory of the COIN-OR package is `$HOME/Coin-Pkg` and you want to place the compiled the code in `$HOME/Obj/debug/Coin-Pkg`, you type

```
cd $HOME/Obj/debug/Coin-Pkg
$HOME/Coin-Pkg/configure --enable-debug -C
```

(Of course, you use the options for `configure` that you want to use, not necessarily the ones above.)  After you run `configure`, you will find the same directory structure under `$HOME/Obj/debug/Coin-Pkg` as in `$HOME/Coin-Pkg` (at least those directories that have source code in `$HOME/Coin-Pkg`), together with the Makefiles.  To compile the code, you now type the `make` command in `$HOME/Obj/debug/Coin-Pkg`.  Note that if you don't specify a specific installation location with the `--prefix` flag when running `configure`, the installed files will go into `bin`, `lib`, and `include` subdirectories of `$HOME/Obj/debug/Coin-Pkg`.

*Note:* A VPATH compilation is not possible if you have already run `configure` in the source code directory (`$HOME/Coin-Pkg` in the example above).  You will need to do a `make distclean` in the source code directory first.
