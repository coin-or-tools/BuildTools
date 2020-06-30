
# Understanding the Directory Structure


## Nomenclature

Here and in the other BuildTools wiki pages we distinguish between a *COIN-OR package* and a *COIN-OR project*:


 * *COIN-OR Project*:  With this we mean the files grouped together as one project in COIN-OR (e.g., source code, Makefiles).  In order to actually compile and link libraries and executables associated with the project, it might be necessary to have files that are not contained in the project, e.g.,  files from other COIN-OR projects (such as CoinUtils).  CAUTION (Wake Up!): The term "project" defined here does not have the same meaning as the term in "Project Manager."  For example, the Clp Project Manager is John Forrest, but an instance of a Clp Project is in Clp's releases/1.3.3 directory. There is only one John Forrest, Clp Project Manager, but there are _many_ COIN-OR Projects associated with Clp, i.e., one for each release, stable, and trunk version. (Context-dependent definitions are a tad confusing to the uninitiated. Two distinct terms would be clearer. Feel free to make suggestions.)


 * *COIN-OR Package*:  For every COIN-OR project, there is an associated COIN-OR package. A COIN-OR package includes the COIN-OR project along with all the COIN-OR projects it depends on. (Third-party code that is not available on COIN-OR but that is also required to compile the program or library, is not part of the COIN-OR package and has to be downloaded separately.) 

For example, to compile the `Clp` library and solver executable, one needs of course the files from the `Clp` COIN-OR project.  However, as a dependency, we also require the files from the `CoinUtils` COIN-OR project, as well as a few data files from the `Data/Sample` COIN-OR project to run the test and example programs.  Therefore:  The `Clp` COIN-OR Package includes the files from the COIN-OR Projects `Clp`, `CoinUtils`, and `Data/Sample`.


## Directory Structure For A COIN-OR Package

The directory structure might differ for individual packages in COIN-OR.  However, we recommend to project managers to follow the layout below.  As example we use the `Clp` package, which requires the `CoinUtils` project and some data files (to run the unit test and example programs) as dependencies.  We assume here that the package base directory has been called `Coin-Clp` by the user.

If you download the source code for a package (here `Clp`), you will find the following structure.

```
Coin-Clp --- BuildTools
 |            |--- headers
 |            |--- compile_f2c
 |            ---- share
 |
 |---------- Data
 |            ---- Sample
 |
 |---------- ThirdParty
 |            |--- Blas
 |            |--- Lapack
 |
 |---------- CoinUtils
 |            |--- doxydoc
 |            |--- inc
 |            |--- MSVisualStudio
 |            |--- src
 |            |--- test
 |
 |---------- Osi
 |            |--- doxydoc
 |            |--- examples
 |            |--- inc
 |            |--- MSVisualStudio
 |            |--- src
 |            ---- test
 |
 |---------- Clp
 |            |--- doc
 |            |--- doxydoc
 |            |--- examples
 |            |--- inc
 |            |--- MSVisualStudio
 |            |     |--- v6
 |            |     |--- v7
 |            |     |--- v8
 |            |     |--- v9
 |            |     ---- v9alt
 |            |--- src
 |            |     ---- OsiClp
 |            ---- test
 |
 ----------- doxydoc
```

In the *base directory of the package* (`Coin-Clp`, or `Clp-x.y.z`, depending on how you obtained the code and called this directory) resides the main configuration script and Makefile.  A user should only issue commands in this directory.  The scripts and Makefiles automatically recurse into the correct subdirectories.

The *BuildTools* directory contains files and scripts that pertain to the COIN-OR build system; most files here are only necessary for project maintainers.  In its subdirectory `headers` are versions of the configuration header files with system dependent information (such as availability of certain system header files).  On a UNIX-like system, where the configuration script automatically generates the configuration header files for the system it is run on, the files in this directory are not used.  However, if one uses other environments to build the COIN-OR binaries (such as the MS Developer Studio), those header files are required.
The `compile_f2c` subdirectory has some scripts and instructions on how to use the `f2c` Fortran-to-C translator within COIN-OR for the MS Visual C++ compiler.  Finally, the `share` directory contains a sample `config.site` file that also explains most of the options for `configure`.

Some projects require data files, in order to run the unit test program or the provided examples.  Those files reside in subdirectories of the *Data* directory.

The *ThirdParty* subdirectory (not present for all COIN-OR packages) contains further subdirectories, in which additional third party code can/has to be copied.  For more information check the packages documentation and read the `INSTALL` files in the subdirectories.

Also, for packages containing C/C++ code, you may find *doxydoc* subdirectories.  These contain configuration scripts for the `doxygen` utility, which generates HTML documentation of the source code.  Once you have the package configured, you can create this documentation with `make doxydoc` (assuming that you have `doxygen` installed).  The final documentation will be in `doxydoc/html`.

For each COIN-OR project that is required to build the desired packages, you will find a *project subdirectory* in the base directory.  In the main subdirectory for each project (above `CoinUtils`, `Clp`, and `Osi`) resides the configuration script for this project, as well as the main Makefile.  However, you should not run those configuration scripts from these subdirectories; use the configuration scripts from the base directory instead.  In the main directory for each project you find also package-specific information such as a README and AUTHORS file.

If the project manager of a COIN-OR project follows our suggested directory structure, you will find the *following subdirectories in the project's main subdirectory* (e.g., in `Clp` or `CoinUtils` above):

 * *src*: Here resides the source code for the package, possibly divided into further subdirectories, together with the Makefile to compile the code (which is automatically called from the main Makefile).  Note, if you are a user for a COIN-OR library, you should not include the header files from this directory, but instead "install" the package properly and get the headers from the installed `include` directory.

 * *inc*: If the project is using a configuration header file, which is automatically generated when you run the configuration script, it is put here.  Again, if you are a user for a COIN-OR library, do not include this file from here, but from the installed `include` directory.

 * *test*: We ask project maintainers to provide some test program(s) to be able to verify a successful compilation, so that a user can test that everything is working fine, before (s)he installs the libraries and other files.  The code and possibly some data files for this unit test are located here.

 * *MSVisualStudio*: If present, the subdirectories contain project files for the MS Developer Studio.  The `v6`, `v7`, `v8`, `v9`, and `v9alt` subdirectories pertain to versions 6, 7, 8, 9, and 9 of the Developer Studio. The [MSVisualStudio project wiki](https://projects.coin-or.org/MSVisualStudio) gives information on how to use these project files.

 * *doc*: If documentation is provided for this COIN-OR project, it should be found here.

 * *doxydoc*: If the project contains C/C++ code, the `doxygen` configuation file is used to generate HTML documentation of the source code. The documentation generated here is used by the package's `doxygen` to generate a documentation for the whole package.

 * *examples*: A package might contain some source code examples, for example to demonstrate how a user of a library can hook up his/her own code to the library.  The source files, an example Makefile, and further information for this can be found here.


After you compiled the code successfully on a UNIX-type system, you can *install* the package (and automatically all its dependencies), using `make install` (see the [Compilation and Installation page](http://projects.coin-or.org/BuildTools/wiki/user-compile)).  By default, the files are installed in newly created subdirectories *bin*, *lib*, and *include* in the package's base directory (`Coin-Clp` above).  If you want to install the files at a different location (such as `/usr/local`), you need to specify the `--prefix` configure script option.