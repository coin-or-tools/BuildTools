
 AC_COIN_THIRDPARTY_SUBDIRS([ASL],[ThirdParty/ASL],[solvers/asl.h] 

and in your Package Base Directory Externals file add 

ThirdParty/ASL https://projects.coin-or.org/svn/BuildTools/ThirdParty/ASL/trunk

When you checkout your project, the necessary makefiles and scripts for obtaining the AMPL ASL code will be put into the directory ASL which is directly under the ThirdParty directory. You can then run a script in this directory to download the necessary AMPL code.  If you do this and the configure script determines that the ASL files are there, and you can do useful things such as

if COIN_HAS_ASL

libOSModelInterfaces_la_SOURCES += OSnl2osil.cpp OSnl2osil.h 

endif

The COIN_HAS_ASL is set to true if the necessary ASL code is in the ThirdParty directory. Also, it sets the following variables

ASLLIB = /Users/kmartin/Documents/files/code/cpp/Coin-OS/ThirdParty/ASL/amplsolver.a -ldl

ASL_CPPFLAGS = -I/Users/kmartin/Documents/files/code/cpp/Coin-OS/ThirdParty/ASL -I/Users/kmartin/Documents/files/code/cpp/Coin-OS/ThirdParty/ASL/solvers

These variables are very useful if you are writing code that uses ASL include files and the ALS library. For example, in a src code Makefile.am you may wish to have something such as

if COIN_HAS_ASL

  AM_CPPFLAGS += $(ASL_CPPFLAGS)

endif

You can also have third-party software which you have to download on your own. In your configure.ac file in the Project Main Subdirectory put in


AC_COIN_HAS_USER_LIBRARY([Lindo],[LINDO],[lindo.h],[LScreateEnv])

You now need to tell the configure script where to look for the LINDO include files and libraries. Here is how to do that:

configure --with-lindo-lib="-L/Users/kmartin/Documents/files/code/lindo/macosx/lib -llindo -lmosek" --with-lindo-incdir=/Users/kmartin/Documents/files/code/lindo/macosx/include

For Mac OS X you must use the -L library directory option, you cannot give the absolute path to the library. This results in a Makefile with the following variables defined:

LINDOINCDIR = /Users/kmartin/Documents/files/code/lindo/macosx/include

LINDOLIB = -L/Users/kmartin/Documents/files/code/lindo/macosx/lib -llindo -lmosek

very useful for including third-party include files and libraries where necessary. For example,

if COIN_HAS_LINDO

  AM_CPPFLAGS += -I`$(CYGPATH_W) $(LINDOINCDIR)`  

endif
