
# Introduction of Automake Concepts

The language of the Automake `Makefile.am` input files is essentially that of a usual Makefile:
One can have comments (everything in a line following a "`#`"), set Makefile variables, and write rules.

Some of the Makefile variables in a `Makefile.am` file have a special meaning.
For example, the `SUBDIRS` variable can be set to the list of directories, into which the generated Makefile should recurse.

The things that should be built, are listed in variable names that have a **primary**, and possibly a **prefix**.
Typical examples are
```
bin_PROGRAMS = super_solver
super_solver_SOURCES = super_solver.cpp super_solver.hpp

lib_LTLIBRARIES = libgreatlib.la
libgreatlib_la_SOURCES = greatlib1.cpp greatlib1.hpp greatlib2.cpp greatlib2.hpp
libgreatlib_la_LDFLAGS = $(LT_LDFLAGS)

include_HEADERS = ../inc/config_supersolver.h greatlib1.hpp
```

The primaries in this example are the parts of the Makefile variables that are capitalized, and the prefixes are the strings before the primaries.

These are the primaries that are important for a COIN-OR project:

 * **PROGRAMS**:  This primary is used to specify programs that are to be compiled.
   The prefix **bin_** indicates that the program should be installed into the `bin` directory by a `make install`.
   If the prefix **noinst_** is used, it indicates that the program should not be installed (_e.g._, the unit test program).

 * **LTLIBRARIES**:  This primary is used to tell Automake the name(s) of libraries that should be built.
   (Since we are using Libtool in COIN-OR, we don't use the `LIBRARIES` primary.)
   The extension should be libtool's `.la` (not `.a` or `.so`).
   The prefix again indicates where the library (or libraries, if both static libraries and shared objects are compiled) are to be installed.
   Usually, this is **lib_** to have them installed in the `lib` directory, or **noinst_**, if they should not be installed.

 * **SOURCES**: This primary is used to list all the source files that should be compiled in order to generate a program or a library.
   Using the extension of a source file, Automake will figure out how the file should be compiled and automatically generate the required rules.   
   The prefix for `SOURCES` is the name of the program or library, including extension, where any dash ("`-`") and any period ("`.`") is replaced by an underscore ("`_`").

 * **HEADERS**: This is usually used with the **include_** prefix, and one lists here all the header files that should be installed in the `include` directory.
   A user may not need all the header files in the source code directory in order to build her/his application, and it is good practice to install only the header files that the user might need.

 * There are a number of additional primaries, such as **LDFLAGS** in the above example.
   With this specific primary, one lists additional flags that should be used when the library is "linked" (a Libtool term).
   The prefix specifies for which program or library this applies.


Automake provides the following features:

 * All **Autoconf output variables** are automatically available as Makefile variables.
   In the above example, `LT_LDFLAGS` is actually an output variable defined in the custom `AC_COIN_PROG_LIBTOOL` autoconf macros, and as you can see, it is used here as a Makefile variable.

 * **Variables can be appened to**, using a "`+=`" assignment.
   In general, only a few `make` programs understand this in a Makefile.
   Therefore, `automake` will convert a statement like
 
        SUBDIRS += ForgottenSubdirectory

    into something that all `make` programs understand.
    Note that a "`+=`" can be used only if the Makefile variable has already been assigned with a "`=`" earlier in the Makefile (an empty assignment suffices).

 * Lines in the final Makefile can be activated depending on the outcome of a test in the `configure` script, using **Automake conditionals**.
   An Automake conditional must have been defined in the `configure.ac` file, using the **`AM_CONDITIONAL`** macro.
   An invocation of this macro in the `configure.ac` file looks like this:

        AM_CONDITIONAL([COIN_IS_GREAT], [test x$is_open_source = xyes])

    The name of the Automake conditional that is defined by that line is "`COIN_IS_GREAT`", and it attains the value "true", if the shell command specified in the second argument returns true.
    In this example, the conditional is set to "true" if the shell variable `is_open_source` in the final `configure` script has the value "yes" at this point.
    
    To use an Automake conditional in a `Makefile.am` file, one uses **if**, **else** (optionally), and **endif**, as demonstrated in the following example:

        if COIN_IS_GREAT
        tellme:
                echo "We agree that coin is great"
        else
        tellme:
                echo "Something must have gone wrong in the configure test"
        endif
 
     If the conditional `COIN_IS_GREAT` is true, then the `tellme` target will output the first line, otherwise the second.
     (In the final Makefile, the inactive lines are simply commented out.)

 * The `Makefile.am` file can **include other input files**.  For example, with
 
        include BuildTools/Makemain.inc
 
    the file `BuildTools/Makemain.inc` is included (with the path relative to the location of the file that has the above line in it) when `automake` processes the input file.
    It does not translate to an "`include`" in the generated Makefile, since this is not supported by all `make` programs.

 * If the compiler supports it, the generated Makefiles will automatically generate rules to derive **dependency rules for C or C++ header files**.

Some more important Automake Makefile variables are the following:

 * **AM_CPPFLAGS**:  This can be used to specify additional preprocessor flags for the compilation of C and C++ source code.
   You should use this variable to specify "`-I`" and "`-D`" flags.

 * **AM_CXXFLAGS**:  This variable is provided to add additional C++ compiler flags (which are not already determined by `configure`).
   Similarly, **AM_CFLAGS** and **AM_F77FLAGS** can be used to add C and Fortran compiler flags.

 * **SUBDIRS** can be set to the subdirectories into which the final Makefile should recurse for the Automake default targets (such as `all`, `install`, `clean`, _etc_.).

 * **srcdir** is an Autoconf output variable that is set to the directory with the source code corresponding to the `Makefile` that is run.
   In the case of a VPATH compilation, the current directory and the source code directory are two different directories.

 * **DISTCLEANFILES** can be set to all files (including wildcards) that should be deleted by a **make distclean** and are not deleted by default.
   For example, if a test program generates output files, those should be listed here.
