# Working with the GNU Autotools

Most of the COIN-OR projects use GNU autoconf, automake, and libtool (collectively, the **GNU autotools**) to automatically configure the source code and the compilation process for a user's computing environment.
The goal is to spare users the chore of editing source and configuration files by hand, and to make the code and compilation as portable as possible.

Because the autotools support many operating systems, compilers, and other environment characteristics, they might seem somewhat complicated at first glance.
However, we have tried to hide most of the details that are required to successfully use these tools by encapsulating the difficult issues and provide a COIN-OR project manager friendly layer on top of the autotools.


## Introduction

In COIN-OR, we make use of the four GNU packages [autoconf](http://www.gnu.org/software/autoconf/), [autoconf-archive](http://www.gnu.org/software/autoconf-archive/), [automake](http://www.gnu.org/software/automake/), and [libtool](http://www.gnu.org/software/libtool/).

A good description of those tools and how they play together can be found in the [Autobook](http://sources.redhat.com/autobook/), but the versions of the tools discussed there are not the most recent ones.
The documentation for each tool can be found here for [autoconf](http://www.gnu.org/software/autoconf/manual/autoconf-2.59/), [automake](http://www.gnu.org/software/automake/manual/automake.html), and [libtool](http://www.gnu.org/software/libtool/manual.html).

[Here you can find a short description of the autotools and how they are used in COIN-OR.](./autotools-intro)

As a project manager, you will need to write the input files for the autotools: the `configure.ac` and `Makefile.am` files.
Once they are written, you need to run the autotools programs to generate the `configure` script and `Makefile.in` template files.
All this is described in the following sections.

The autotools will allow you to do much, much more. The goal here is simply to get you started.


## The `configure.ac` Files

The `configure` script is generated by `autoconf` based on the `configure.ac` input file.
`configure.ac` usually contains autotools macro invocations and shell (`sh`) commands.
To make the use of autotools easier for COIN-OR developers and to promote consistency across COIN-OR projects, the [BuildTools project](https://github.com/coin-or-tools/BuildTools) defines many new macros that provide many standard features.
(You can examine the definitions in the `.m4` files.)

Even if you've used `autoconf` before, you should read about [the configure.ac files](./configure), since we are using a number of custom defined `autoconf` macros.


## The Makefile.am Files

`Makefiles` are generated by the `configure` script from `Makefile.in` template files.
`Makefile.in` files are generated by `automake` from `Makefile.am` input files.
`Makefile.am` files contain information on what targets are to be built (_e.g._, programs or libraries), what source files are required for each target, where libraries and include files should be installed, _etc._
One can also write regular Makefile rules that will be copied verbatim into the final Makefile.
Just remember that if you want to keep portability, you're writing for the 'lowest common denominator' implementation of `make`.

In a typical COIN-OR project there are a number of different types of `Makefile.am`, depending on the purpose of the corresponding directory.
Before looking at the descriptions below, please read the [introduction to automake concepts](./automake-intro).

 * **Project main directory Makefile.am file**:  Each project's main directory contains the `Makefile` that takes care of project-specific activities, such as defining how `make test` is run.
   It also knows the source code directories into which `make` should recurse in order to build everything that the project must provide.
   [Details of the main Makefile.am for a project can be found here](./project-make).

 * **Source code directory Makefile.am files**: This is where the actual build happens.
   Here one specifies what is to be built, what source files are required, where (and whether) the compiled files are to be installed, _etc._
   [Details of the Makefile.am files for the source code directories can be found here](./source-make).

 * **Unit Test Makefile.am files**:  These also specify how to compile a program and are thus similar to a source directory `Makefile.am` file, but they are usually simpler.
   [Details of the Makefile.am files for the test code directories can be found here](./test-make).

 * **Example Makefile.in files**:  COIN-OR projects that generate a library should provide some example code (typically a simple main program) that demonstrates how the library can be used.
   It is assumed that most users of COIN-OR software will lack the skills or the environment to run the autotools; it follows, therefore, that providing a `Makefile.am` file for an example is pointless.
   It's also true that the Makefiles generated by `automake` are complex and generally difficult to read by a human.
   For these reasons, project developers should provide a `Makefile.in` file which the `configure` script can process to generate a `Makefile`.
   It is recommended that the project provides a `Makefile.in` that produces a simple Makefile for the user that is configured for the user's system and can be easily modified for the user's own application.
   If you want to provide such a Makefile for your example program, have a look at existing COIN-OR projects for examples and adapt them to your needs.

## Using the Correct Version of the Autotools

We ask that every user of COIN-OR BuildTools uses the same distribution of the same version of the autotools.
This is necessary in order to ensure that the custom defined COIN-OR additions work.
Also, this way we guarantee that each developer generates the same output files, which avoids the mess that would occur if this were not the case.
Specifically, the precompiled versions of autotools included in packaged distributions often contain small modifications to the m4 macros that are supplied with autoconf, automake, and libtool.
These differences make their way into generated Makefiles and configure scripts.
Allowing these differences to creep into the repository will result in chaos.
For this reason, we ask that you download the original source packages for the autotools from GNU and build and install them by hand on your system.

**We recommend that you install the self-compiled tools in a local directory of your choice**.
To do so, the environment variable `COIN_AUTOTOOLS_DIR` is used to specify the prefix under which to install the autotools, e.g.,
```
export COIN_AUTOTOOLS_DIR=$HOME/local
```
The script that runs the autotools (see next section) respects the value of this variable.

BuildTools provides the script [`install_autotools.sh`](https://github.com/coin-or-tools/BuildTools/blob/master/install_autotools.sh) that install the currently suggested versions of autoconf, autoconf-archive, automake, and libtool.
The script just does a sequence of `curl`, `configure`, `make`, `make install` calls in the right order.
If you do not want to use it, then see its header for the currently suggested autotools version numbers.

If `COIN_AUTOTOOLS_DIR` has been set, it is no longer required to add the path for the installed autotools executables to your `$PATH`.

<!--When you run `configure` in your local copy with the `--enable-maintainer-mode` flag (which you should do as a developer), it will test to see if the above conditions are met and will fail if they are not met. -->

## Running the Autotools

You can run the autotools on your package by changing into the package's main directory and running `/path/to/BuildTools/run_autotools`.
When run with no parameters, the script will examine the current directory for a `configure.ac` file, copy the required auxiliary files into the directory, create a temporary link to the BuildTools directory, and run the autotools.
You can also explicitly specify a set of directories as arguments or enable a recursion that looks for `configure.ac` in subdirectories.
Though it is probably not useful nowadays, the `run_autotools` script also observes the environment variable `COIN_SKIP_PROJECTS`.

If `COIN_AUTOTOOLS_DIR` has been set, then `run_autotools` prefixes `PATH` with `$COIN_AUTOTOOLS_DIR/bin`.
`run_autotools` also checks whether the expected versions of the autotools are used.

The run_autotools script essentially
* runs `aclocal` with a number of `-I` flags to make use of the right `.m4` macros files; this produces `aclocal.m4`,
* runs `autoheader` to produce `config.h.in`,
* runs `automake` to produce `Makefile.in`
* runs `autoconf` to produce `configure`,
* copies static autotools scripts that are redistributed (`install-sh`, `compile`, `config.guess`, ...) into the project directory,
* applies BuildTools specific patches for `libtool`, `compile`, etc., and
* refreshes static configuration header files (`configall_system.h`, `configall_system_msc.h`) in the project directory.

For the last step, the script checks for each file in `BuildTools/headers/` whether it can find a file of the same name in the project source tree and overwrites the latter.


### Maintainer Mode

**Warning**: The maintainer mode hasn't been tested for a while and may not work anymore as documented.

Once you have a working version of your project and you can run `make`, you should (re)run the `configure` script with the `--enable-maintainer-mode` parameter.
This will activate a number of makefile rules that simplify the maintenance of the configuration files.
When you now edit a `configure.ac` or `Makefile.am` file, the corresponding autotool program will be run at the next execution of `make`.
If necessary, the `configure` script will be rerun so that everything is kept up-to-date.

A few notes of caution when maintainer mode is enabled:

 * If changes to a `configure.ac` or `Makefile.am` input file introduce an error, the `make` for updating everything may fail.
   It may be necessary to rerun the autotools "by hand" after the error has been corrected, using the `BuildTools/run_autotools` script.

 * When you make a change in a `configure.ac` file, `make` will rerun the `configure` script, but _not_ recursively.
   If the change you made now requires recursion into a new directory, you will have to rerun the `configure` script by hand.
   To determine the options used in the most recent run of the `configure` script, look at the beginning of the `config.log` output file.
   Make sure that you don't use the `--no-create` or `--no-recursion` options when you rerun the script.


### Using autoreconf

As distributed, packages that use the COIN-OR BuildTools do not provide `acinclude.m4` and `aclocal.m4`.
Instead, these are generated by the `run_autotools` script.
(Have a look at the script to see how it's done; `aclocal` is responsible for `aclocal.m4`.)

Documentation to the contrary, `autoreconf` is not capable of correctly (re)generating `acinclude.m4` and `aclocal.m4`.
If you're writing configuration macros, you want to be using `run_autotools` to incorporate your changes into `acinclude.m4` and `aclocal.m4`.
If you're not writing configuration macros, you need to run `run_autotools` at least once to produce `acinclude.m4` and `aclocal.m4`, after which you can use `autoreconf`.


## Which Files should be in the Source Repository?

The short answer is "Everything that's input for the autotools, or is created when the `run_autotools` script is run." Assume that users will not have the ability to run the autotools.

More specifically, the following files should be included in the subversion repository:

 * Every `configure.ac` and `Makefile.am` file.

 * Every `configure` and `Makefile.in` file. These are generated by the autotools and cannot be recreated by the average user. **Do not** include `Makefile`s; these are generated when the user runs the `configure` script.

 * In the main directory of the project, include `ar-lib`, `compile`, `config.guess`, `config.sub`, `depcomp`, `install-sh`, `ltmain.sh`, and `missing`.
   These files will be copied into the directory automatically when you run `BuildTools/run_autotools`.
   For projects that do not need to compile C/C++/Fortran code and do not need to build libraries, files `compile` and `ar-lib` can be omitted, respectively. (These files are wrappers to use MS/Intel compilers and linker on Windows.)


## Working On Your Project

<!--If you are working on your project, you should run configure with the `--enable-maintainer-mode` flag.  This way, changes in your `configure.ac` and `Makefile.am` files will automatically trigger execution of the autotools programs.  If necessary, you can run the autotools "by hand" using the `BuildTools/run_autotools` script. -->

If you want to compile the package's code with debug information, you should use the `--enable-debug` parameter when you run the `configure` script.
This will add to the compile command the parameters necessary to produce code with debugging information.
If a debugger should be run, then it is also convenient to switch to static libraries and executables, which can be achieved by using the configure flag `--disable-shared`.
(This sidesteps a few less-than-obvious consequences of using `libtool`.
When shared libraries are built, the libraries remain hidden in the `.libs` subdirectories until `make install` is executed.
Programs which depend on these libraries will most likely not run because the shared libraries cannot be found.)