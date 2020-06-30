
 This page is being set up.  Below just a first draft of the information (Lou's email message to the TLC mailing list)

```

 1) True MSVS, using the MSVS IDE.  No autotools or unix anywhere in the
    vicinity.  Now available (MSVS8) as a free download.  The usual source of
    MS cl, MS link, and other MS build tools.  No free Fortran compiler.

 2) Full cygwin, which tries to be linux running on top of Windows.  From the
    buildtools point of view, the important things are that the GCC compilers
    are available and cygwin.dll (or some such name) will be needed when code
    is run, hence binaries will not run in the native Windows environment.
    
    Config.guess will show *-cygwin* as the build type.
    
    Requires no command line help when configuring. Configure is run in a
    cygwin shell.

 3) Cygwin, but built with the -mno-cygwin flag.  Still uses GCC compilers,
    but avoids using anything that needs cygwin.dll.  The resulting binaries
    will run in the native Windows environment.
    
    Config.guess will show *-cygwin* as the build type.
    
    Specified with the --enable-doscompile=mingw command line flag when
    configuring.  Configure is run in a cygwin shell.

 4) Cygwin, but Coin configuration will assume Microsoft cl/link used for
    compilation and linking.  The resulting binaries will run in the native
    Windows environment.  No free Fortran compiler, but you can try Andreas'
    compile_f2c.

    Config.guess will show *-cygwin* as the build type.
    
    Specified with the --enable-doscompile=msvc command line flag when
    configuring.  Configure is run in a cygwin shell.  The user is responsible
    for making sure that PATH is properly set to include the relevant MSVS
    directories.

 5) MinGW, a sort of minimalist cygwin.  I know it exists, but I have yet to
    try configuring in this environment.  My impression is that you get GCC
    plus all the utilities needed for build and configuration.  Autotools?
    Extras?

    Config.guess will show *-mingw* as the build type.
    
    Should require no command line help? Configure is run in a mingw shell.

 6) Msys, a sort of minimalist MinGW.  Does not include GCC.  Coin
    configuration will assume MS cl/link.  Just enough unix support to allow
    configure scripts to run.  No autotools.  No free Fortran compiler, but
    you can try compile_f2c.  At install, will helpfully ask if you want to
    synchronise with an existing mingw (and cygwin?)  installation, which
    hopelessly confuses the issue of what's actually available.

    Config.guess will show *-mingw* as the build type.
    
    Now specified with the --enable-doscompile=mingw option.  Previously no
    option, but if we decide to support 5), may indeed by necessary.
    Configure is run in an msys shell.  The user is responsible for making
    sure that PATH is properly set to include the relevant MSVS directories.

```