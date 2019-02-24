
 There are a number of different ways to build COIN-OR projects even under Windows.


## Use Precompiled Binaries

We have recently put a good deal of effort into providing binary versions of executables and libraries for Windows. We now have installers that work in the way that Windows users are used to. These are available at the binary download page for the [COIN-OR Optimization Suite](http://www.coin-or.org/download/binary/CoinAll). This suite provides a coherent set of the latest releases of all the COIN-OR projects that use the common build system and are known to work together. If you do not want to install the COIN-OR Optimization Suite for some reason, you can check whether binaries are available for specific individual projects at the [COIN-OR binaries download page](http://www.coin-or.org/download/binary). However, because of the large number of projects we distribute, regularly update binaries for other projects are probably not available. 


## Using MS Visual Studio

If you are developing on Windows, you are very likely using Microsoft Visual Studio (MSVS). There are alternatives to using this IDE, which may make your life much easier (see below). However, we understand that there are many users who either have no choice or prefer the MSVC++ IDE on Windows. Therefore, we provide solution files for building under MSVC++ for most projects. The [COIN-OR Visual Studio wiki](https://projects.coin-or.org/MSVisualStudio) describes the organization and use of these files and for which projects they are available.


## Building under Cygwin and/or MSys/MinGW

[CYGWIN](http://www.cygwin.com) is a port of many of the tools available on Unix-based systems to Windows. CYGWIN provides a Unix shell and standard set of Linux tools, thus allowing one to work as if in a Unix-based system within a Windows environment. This makes it possible to use the COIN-OR build system, which in turn makes it much easier to build with certain options than Visual Studio. CYGWIN is, however, a rather heavy-weight installation. A lighter-weight alternative is the MSys shell th is provided by the [MinGW](http://www.mingw.org) project. MSys provides a shell and a minimal set of standard Unix tools, which can be used to deploy the COIN-OR build system in the same way as on a Unix-based platform. Note that with Msys, one also needs to install the MinGW compiler suite if the Microsoft compilers are not available. 

Note that there are now two version of CYGWIN available---a full 64-bit version and the legacy 32-bit version. In general, the 32-bit version seems to be a bit more stable and is all that most people need. You may consider the 64-bt version if you plan to solver very large-scale instances that require a lot of memory or processing power. 


### Building with GNU compilers

With CYGWIN, one has the option to install the GNU compiler collection, including `gcc`, `g++`, and `gfortran`. It is recommended to install the MinGW versions of these compilers, which build binaries that do not depend on the CYGWIN DLL. Note that building with these compilers is technically considered "cross-compiling" and requires an addition configure option. Once the GNU compilers are installed, building proceeds exactly as in the [Unix](https://projects.coin-or.org/BuildTools/wiki/downloadUnix). First, download the code as explained [here](https://projects.coin-or.org/BuildTools/wiki/downloadUnix) and then the usual incactation should work.

```
configure
make
make install 
```

You will have to add the option `--host=i686-pc-mingw32` to use the 32-bit MinGW compilers or the option `--host=x86_64-w64-mingw32` to use the 64-bit MinGW compilers. It is recommended to use the compilers matching the version of CYGWIN you have.

Under MSys, the same incantation should work, but using the MinGW compilers is not cross-compiling there.


### Building MinGW DLLs

It is now possible to build DLLs using the MinGW compilers. To do that is add the options 

```
--enable-shared --enable-static --enable-dependency-linking lt_cv_deplibs_check_method=pass_all
```

along with the appropriate flag for cross-compiling. Both DLLs and statoc libraries will be produced.


### Building with the MSVC++ compilers

It is possible to use MSVC++ compilers to build COIN-OR codes using the auto tools from within CYGWIN or MSys. This will utilize the power of the build system while still producing MSVC++-compatible binaries in a fully automated way without having to invoke the MSVC++ IDE, which can be difficult. Note that setting up the *`$PATH` variable* under Cygwin in a way that it finds the MS or Intel compilers is important (see discussion [here](https://projects.coin-or.org/BuildTools/wiki/current-issues#Configuration)). Adding the Intel compiler suite allows the compilation of Fortran codes. Alternatively, the BuildTools include a script *`compile_f2c`* that *emulates a Fortran compiler* by translating Fortran77 code into C code via `f2c` and compiles this code via a C compiler.
This does not work for Fortran90. See the [INSTALL file](../tree/master/stable/0.7/compile_f2c/INSTALL) on instructions on how to install `compile_f2c`.

To build with MSVC++ compilers, make sure that you have run the proper batch scripts to set up the environment (`vcvarsall.bat` and or `ifortvars.bat`) and that these environment variables have been peroperly inherited into your CYGWIN or MSys shell. Then follow the instructions for Unix-based systems [here](https://projects.coin-or.org/BuildTools/wiki/downloadUnix), but when configuring, add the option

```
configure --enable-msvc=MD
```

The argument to `--enable-msvc` specifies the run-time library flag to be used (see discussion [here](http://msdn.microsoft.com/en-us/library/2kzt1wy3.aspx)). The flag `\MD` is the default for COIN and is the right one for building Python extensions, among other things. 

