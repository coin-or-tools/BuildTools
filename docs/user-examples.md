
 Again, this information only pertains to UNIX-like systems, where you use `configure` and `make`.  If you want to use the MS Developer Studio, please check [here](http://projects.coin-or.org/MSVisualStudio) for more information.

Assume that you have [downloaded](./user-download) the COIN-OR package `Pkg` in the directory `Coin-Pkg`.
You have run [configure](./user-configure), [make, and make install](./user-compile) in the directory `Coin-Pkg/build`.
Assume that you used `Coin-Pkg/build` as the install directory (i.e. the default), obtaining libraries in `Coin-Pkg/build/lib` and include files in `Coin-Pkg/build/include/coin`.

For most COIN-OR packages, the main directory contains an `examples` subdirectory.
Assuming that this is the case for the package `Pkg`, the directory `Coin-Pkg/build/Pkg/examples` contains a `Makefile` that has been adapted to your system. 
If you want to hook up your own code to this COIN-OR library, it might be a good idea to start by looking at the example Makefile.

`Note:`  You should use only the libraries and header files that have been installed in `Coin-Pkg/build/lib` and `Coin-Pkg/build/include/coin`, not those in any other directory.  Picking up libraries and headers from the source directories has a good chance of creating problems.

In order to modify `examples/Makefile` to compile your own code, you usually only have to change the first part, which might look like this:

```
##########################################################################
#    You can modify this example makefile to fit for your own program.   #
#    Usually, you only need to change the five CHANGEME entries below.   #
##########################################################################

# CHANGEME: This should be the name of your executable
EXE = my_prog

# CHANGEME: Here is the name of all object files corresponding to the source
#           code that you wrote in order to define the problem statement
OBJS =  my_prog.o \
        additional_source1.o \
        additional_source2.o

# CHANGEME: Additional libraries
ADDLIBS = -L$(HOME)/MyLibrariesDir -ladditional_lib

# CHANGEME: Additional flags for compilation (e.g., include flags)
ADDINCFLAGS = -I$(HOME)/MyCoolPrograms/include

# CHANGEME: Directory to the sources for the (example) problem definition
# files
SRCDIR = .
VPATH = .
```

The modifications are pretty straightforward:

 * *EXE* should be set to the *name of the executable* you want to compile with this Makefile.

 * *OBJS* should be set to the list of *all object files* that correspond to the source files you want to compile.

 * *ADDLIBS* should list *additonal compiler link flags* to link with (non-COIN-OR) libraries required to link your final program.

 * *ADDINCFLAGS* should be set to compiler flags that tell it where to look for *additional (non-COIN-OR) header files* required to compile your code - if required.

 * *SRCDIR* and *VPATH* should be set to the *directory where your source code is*.  (This allows you to compile your code with the Makefile in a different directory from the source code directory.)

The lower part of the Makefiles looks somewhat like this:

```
##########################################################################
#  Usually, you don't have to change anything below.  Note that if you   #
#  change certain compiler options, you might have to recompile the      #
#  COIN package.                                                         #
##########################################################################

COIN_HAS_PKGCONFIG = TRUE
COIN_CXX_IS_CL = #TRUE

# C++ Compiler command
CXX = g++

# C++ Compiler options
CXXFLAGS = -O3 -pipe -DNDEBUG -pedantic-errors -Wimplicit -Wparentheses -Wreturn-type -Wcast-qual -Wall -Wpointer-arith -Wwrite-strings -Wconversion -Wno-unknown-pragmas  

# additional C++ Compiler options for linking
CXXLINKFLAGS =  -Wl,--rpath -Wl,/home/me/Coin-Pkg/lib

# C Compiler command
CC = gcc

# C Compiler options
CFLAGS = -O3 -pipe -DNDEBUG -pedantic-errors -Wimplicit -Wparentheses -Wsequence-point -Wreturn-type -Wcast-qual -Wall -Wno-unknown-pragmas  

# Include directories (we use the CYGPATH_W variables to allow compilation with Windows compilers)
ifeq ($(COIN_HAS_PKGCONFIG), TRUE)
  INCL = `PKG_CONFIG_PATH=/home/me/Coin-Pkg/lib/pkgconfig:/usr/bin/pkg-config --cflags pkg`
else
  INCL = [...]
endif
INCL += $(ADDINCFLAGS)

# Linker flags
ifeq ($(COIN_HAS_PKGCONFIG), TRUE)
  LIBS = `PKG_CONFIG_PATH=/home/me/Coin-Pkg/lib/pkgconfig:/usr/bin/pkg-config --libs pkg`
else
  ifeq ($(COIN_CXX_IS_CL), TRUE)
    LIBS = -link -libpath:`$(CYGPATH_W) /home/me/Coin-Pkg/lib` libPkg.lib  [...]
  else
    LIBS = -L/home/me/Coin-Pkg/lib -lPkg  [...]
  endif
endif

# The following is necessary under cygwin, if native compilers are used
CYGPATH_W = echo

all: $(EXE)

.SUFFIXES: .cpp .c .o .obj

$(EXE): $(OBJS)
        bla=;\
        for file in $(OBJS); do bla="$$bla `$(CYGPATH_W) $$file`"; done; \
        $(CXX) $(CXXLINKFLAGS) $(CXXFLAGS) -o $`@` $$bla $(LIBS) $(ADDLIBS)

clean:
        rm -rf $(EXE) $(OBJS)

.cpp.o:
        $(CXX) $(CXXFLAGS) $(INCL) -c -o $`@` `test -f '$<' || echo '$(SRCDIR)/'`$<


.cpp.obj:
        $(CXX) $(CXXFLAGS) $(INCL) -c -o $`@` `if test -f '$<'; then $(CYGPATH_W) '$<'; else $(CYGPATH_W) '$(SRCDIR)/$<'; fi`

.c.o:
        $(CC) $(CFLAGS) $(INCL) -c -o $`@` `test -f '$<' || echo '$(SRCDIR)/'`$<


.c.obj:
        $(CC) $(CFLAGS) $(INCL) -c -o $`@` `if test -f '$<'; then $(CYGPATH_W) '$<'; else $(CYGPATH_W) '$(SRCDIR)/$<'; fi`
```
The variables *COIN_HAS_PKGCONFIG* and *COIN_CXX_IS_CL* are setup by configure and should *not be changed* by the user.

The *compiler name* variables *CXX*, *CC* and *F77* will already be adapted to your system, as well as the corresponding variables *CXXFLAGS*, *CFLAGS*, *FFLAGS* for the *compiler flags*.  Those are the same that have been used to compile the COIN-OR library, and it is probably not a bad idea to choose the same (or compatible) options.

The *COININCDIR* and *COINLIBDIR* is adapted to the *directories where the COIN header files and libraries have been installed*.

If you compiled the COIN-OR library as a shared object, the *CXXLINKFLAGS* is set to the compiler link flag that hardcodes *the search path to the installed shared libraries* into the executables (if that is supported on your system).  Alternatively, you can set the `LD_LIBRARY_PATH` or similarly names environment variable to point to the directory with the COIN-OR shared object.

The *INCL* variable is set to the *compiler flags that are required to find the header files of the COIN-OR library*. If `pkg-config` is available, then it is used to read the compiler flags from the pkg.pc file.
If `pkg-config` is not available, then the configure script sets up a list of compiler flags to locate the installed header files of a project and all it's dependencies. Since in this example pkg-config is available, the corresponding flags are not setup by configure. Otherwise they would replace the `[...]`.

The *LIBS* variable is set to the *compiler link flags that are required to link with the COIN-OR library*. If `pkg-config` is available, then it is used to read the linker flags from the pkg.pc file.
If `pkg-config` is not available, then the configure script sets up a list of linker flags that correspond to all dependent libraries. Since in this example pkg-config is available, the corresponding flags are not setup by configure. Otherwise they would replace the `[...]`.

The *generic compilation rules* (e.g., `.c.o`) might look somewhat complicated.  But with this, the Makefile can also be used by people who work with the MS compilers (e.g., `cl`) under Cygwin, since those compilers don't understand the UNIX-type directory paths.  In such a case, the *CYGPATH_W* will have been set to "`cygpath -w`" by `configure`, otherwise it is just "`echo`".