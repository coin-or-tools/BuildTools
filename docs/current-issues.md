
# Current Issues


## Configuration

 * [=#MinGWPath] *When building with the Visual Studio (cl) or Intel (ifort) compilers on Windows using either the Msys shell or under CYGWIN*, you may see failures that really leave you scratching your head. Before you tear your hair out, check your `PATH`. The problem may be conflicts in the naming of certain utilities provided by Windows and Msys/CYGWIN. They each have utilities called find, link, and sort, but the Windows versions are completely incompatible with the unix versions. It is important that the MSys/CYGWIN versions of find and sort are the ones that come first in your path. You can check this by typing `which find` and `which sort` on the command line and making sure they are the one in the MSys/CYGWIN `bin` directory. If not, make sure that the Msys/CYGWIN `bin` directories come before any Windows system directories in your `PATH`! The Windows path of the user who starts CYGWIN is inherited to the CYGWIN shell, so fixing the issue usually requires modifying your Windows path so that CYGWIN bin directory comes before the Windows system directories. Both the `configure` and `libtool` shell scripts can fail if this is not true. On the other hand, if you're trying to build with Windows `cl` or Intel `ifort`, then you want the Windows version of `link` to be first in your path, so make sure that the Visual Studio command directories precede the Msys/CYGWIN command directories, which in turn must still precede the Windows system directories. This happens naturally if you run the batch script provided by Visual Studio for setting the environment variables. 

 Note that on many version of CYGWIN, the default PATH is built using the script /etc/profile, which has the line
```
PATH="/usr/local/bin:/usr/bin:$PATH"
``` 
 which is exactly what you don't want because this puts the CYGWIN version of link ahead of the Windows version in the path! If you change it to
```
PATH="$PATH:/usr/local/bin:/usr/bin"
``` 
 life will be much better. 

 If you like, you can tell the Intel compilers where to find the right `link.exe` by editing the files icl.cfg and/or ifort.cfg in the Intel compiler installation. The line to add is of the form
```
  -Qlocation,link,"C:\Program Files\Microsoft Visual Studio .NET 2003\Vc7\Bin"
```

 * *"./configure: line 20: $'\r': command not found" error on Cygwin.*  If you see an error like this on Cygwin, it means that your setting for Cygwin is such that the native text style is "Windows" and not "Unix".  As a consequence, the `configure` and other shell scripts have Window-style line end characters, which cannot be digested properly by the shell.  As a work-around, you can run the "`dos2unix`" program to correct all failing shell scripts (e.g., by typing "`dos2unix configure`").  In the long run, we will change the subversion properties for those files to avoid this problem, but it might take some time until all files have been corrected.

 * In Windows, the *CPLEX library link check* in configure may fail because the CPLEX dll is not found
   (configure fails with the error: "Cannot find symbol CPXgetstat with CPX").
   Running configure with the option *`--disable-cplex-libcheck`* disables this check.

   Just remember to have the CPLEX dll in the path and the `ILOG_LICENSE_FILE` system variable pointing to the CPLEX license file when executing binaries.

 * *On Mac OS X*, the situation with compilers used to be a bit of a mess, but things have been cleaned up recently. OS X comes with the `clang` compiler, which works just fine for building COIN projects that don't require Fortran. If you require Fortran, the easiest and recommended solution is just to install [Homebrew](http://brew.sh) and then do `brew install gcc`. You will then have `gfortran`, which works fine alongside `clang`. Alternatively, you can use the homebrew version of `gcc` by configuring with `CC=gcc` `CXX=g++`.

 * On *MacOS X*, if you use the Intel 10 compilers and build static (or debug) libraries, it is wise to set F77 to `"ifort -shared-intel"` to avoid later problems when COIN-OR libraries are linked to each other.

 * It is doubtful one can even use *MacOS X 10.5* anymore, but this is being left for posterity. If you do use 10.5, you should use
   ```
     ADD_CXXFLAGS="-mmacosx-version-min=10.4" ADD_CFLAGS="-mmacosx-version-min=10.4" ADD_FFLAGS="-mmacosx-version-min=10.4"
   }}}
   This helps to get around a problem with the Ampl Solver Library (ASL) and in the recoginition of the FLIBS (in case gfortran is used). This flag avoids undefined references to something with an $UNIX2003 attached, see also http://developer.apple.com/releasenotes/Darwin/SymbolVariantsRelNotes/index.html 

 * Also on *MacOS X 10.5*, if you get failures when running the code due to lazy symbol binding, try to rebuild everything with `LDFLAGS="-flat_namespace"`. However, this solution might fail too.

 * On *MacOS X 10.6*, it is sufficient to add to the configure command
   {{{
     ADD_FFLAGS="-mmacosx-version-min=10.4"
   }}}
   *Do not* ADD_CXXFLAGS="-mmacosx-version-min=10.4" or you will have problems with try catch causing ABORT TRAP errors. If you are going to compile with ASL you should also try to build static libs by adding  
   {{{
      --enable-static --disable-shared
   }}}

 * On *MacOS X 10.9*, the default C++ standard library used by the Xcode compilers has changed to libc++ (LLVM/clang), rather than libstdc++ (GNU). This can cause strange link errors when linking C++ code into C or Fortran libraries or executables. The errors may be of the form "Undefined symbols for architecture x86_64" for many symbols that begin with `std::__1::`, which should be coming from libc++. BuildTools currently assumes the default C++ library is libstdc++ in most cases, [this patch](https://projects.coin-or.org/BuildTools/changeset/3045) will fix the issue but may take some time to be ready for release. There are two workarounds: either let BuildTools know that the C++ standard library is libc++ by configuring with `CXXLIBS=-lc++`, or tell the clang++ compiler to use libstdc++ as its standard library by configuring with `ADD_CXXFLAGS="-stdlib=libstdc++"`.

 * On *AIX `configure` runs considerably faster* if bash is installed and the environment variable `CONFIG_SHELL` points to it.
   For `ksh` or `bash` use
   {{{
     CONFIG_SHELL=/usr/bin/bash ; export CONFIG_SHELL
   }}}
   or if you use `tcsh` then
   {{{
     setenv CONFIG_SHELL "/usr/bin/bash"
   }}}
   before running configure.



## Compilation

 * If you get unresolved symbols like *dlopen* on *Ubuntu* even though *`-ldl` is present*, then try again after rerunning configure with the option *`LDFLAGS=-Wl,--no-as-needed`*.

 * *When building older versions of COIN on CYGWIN, GNU make version 3.81-1 delivered by the default setup program doesn't work* with the automatic header file dependencies generated by the compilers.  The error message you will see because of this bug will look something like this:
{{{
make[2]: Entering directory `/home/andreasw/COIN-svn/OBJgcc-debug/Clp/trunk/Clp/src'
.deps/ClpCholeskyBase.Plo:1: *** multiple target patterns.  Stop.
```
  This is no longer the case with the most recent versions of the BuildTools, so the suggested solution is just to upgrade to a more recent version. If for some reason, you need to build an older version, the easiest workaround for this problem is to add
```
--disable-dependency-tracking
```
  to your configure command.

 * *On AIX, with the xlC compiler* the CXX flag -qrtti has been needed.
```
./configure ADD_CXXFLAGS="-qrtti"
```
   Some projects (SYMPHONY) need an addtional flag for `ADD_CXXFLAGS` of `-qsourcetype=c++`. `configure` should be run with `ADD_CXXFLAGS="-qsourcetype=c++ -qrtti"`.  This is because the C++ source files in these projects have the suffix c (not cpp).
   

 * *On P-Series(ppc64) running Linux(Red Hat 4.1.1-52) with gcc(V 4.1.1 20070105) ThirdParty/ASL has compile time errors.* 
```
fpinit.c: In function 'fpinit_ASL':
fpinit.c:123: error: '_FPU_EXTENDED' undeclared (first use in this function)
fpinit.c:123: error: (Each undeclared identifier is reported only once
fpinit.c:123: error: for each function it appears in.)
fpinit.c:123: error: '_FPU_DOUBLE' undeclared (first use in this function)
```
   A suggested work around is to specify `ADD_CFLAGS="-DNO_fpu_control"` when running configure.
```
./configure -C ADD_CFLAGS="-DNO_fpu_control"
```

 * *In Microsoft Windows, using the MinGW gcc compiler version 4.2.1 under Msys*, you cannot successfully link with -lstdc++ because of a buggy .la file. To fix, replace the file MinGW/lib/gcc/mingw32/4.2.1-sjlj/libstdc++.la with this [fixed one](https://projects.coin-or.org/BuildTools/attachment/wiki/current-issues/libstdc%2B%2B.la?format=raw). This currently affects only the unit test of Ipopt (as far as I know). I have built successfully without this fix on version 4.7.3 of the GNU MINGW compilers that currently ships with CYGWIN, so the easiest solution is just to upgrade to something more recent. Many version of the MINGW compilers that are out there fail to build COIN for various reasons, however.

 * *When building in either the Msys or CYGWIN shells*, you may see failures that really leave you scratching your head. See the [#MinGWPath entry under configuration]. During build, the failure is due to `libtool` finding Windows `sort` instead of unix `sort`.

 * When compiling with *Intel compilers*, it can be advantageous to add the compiler flag `-mp1` (`ADD_CXXFLAGS=-mp1`). This disables some optimization, but improves floating point accuracy. In my case it helped to make (x == 0./0.) return false if x is not nan.

 * If compiling with *Intel 9.0 compilers* fails with the message `internal error: backend signals`, it can help to add the compiler flag -Qipo- (`ADD_CXXFLAGS=-Qipo-`). This disables some optimization, but allows compilation.

 * *GCC 3.3.5* seem to have some bug in its optimization routines regarding the omission of frame pointers. What seem to work is `OPT_CXXFLAGS="-O3 -fno-omit-frame-pointer -momit-leaf-frame-pointer -DNDEBUG"`

 * When compiling on gcc/g++ where the machine word size/pointer size is the same as long long only (e.g. MinGW gcc for 64 bit Windows), the compiler may abort with an *"ISO C++ 1998 does not support 'long long'" error* for some files. This seem to be because of the -pedantic-errors flag used with the compilation. To work around this, add  `-Wno-long-long` to your `ADD_CXXFLAGS`.  

 * If you see an error like `error: 'CLP_VERSION' was not declared in this scope`, check to see if your `CPLUS_INCLUDE_PATH` is set; if so check to see if there is a `coin` directory in that path and remove it. 


## Execution

 * *Ampl Solver Library crashes with GNU compiler 4.4.1*, it segfaults in la_replace, see Ipopt ticket https://projects.coin-or.org/Ipopt/ticket/118.  Solution is to use an older or newer compiler.
---

Attachments:
 * [libstdc++.la](current-issues/libstdc++.la)
