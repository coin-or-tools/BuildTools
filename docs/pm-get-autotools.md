


# Using the Correct Version of the Autotools

We ask that every developer in COIN-OR uses the same distribution of the same version of the autotools.  This is necessary in order to ensure that the custom defined COIN-OR additions work.  Also, this way we guarantee that each developer generates the same output files, which avoids the mess that would occur if this were not the case. Specifically, the precompiled versions of autotools included in packaged distributions often contain small modifications to the m4 macros that are supplied with autoconf, automake, and libtool. These differences make their way into generated Makefiles and configure scripts. Allowing these differences to creep into the repository will result in chaos. For this reason, we ask that you download the original source packages for the autotools from GNU and build and install them by hand on your system.

*We recommend that you install the self-compiled tools in your $HOME directory*, _i.e._, in `$HOME/bin`, and other configuration files in `$HOME/share`.  After including `$HOME/bin` in your `PATH`, this can be done by:
```
mkdir tmp
cd tmp
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.59.tar.gz
tar xvzf autoconf-2.59.tar.gz
cd autoconf-2.59
./configure --prefix=$HOME
make install
cd ..
wget http://ftp.gnu.org/gnu/automake/automake-1.9.6.tar.gz
tar xvzf automake-1.9.6.tar.gz
cd automake-1.9.6
./configure --prefix=$HOME
make install
cd ..
wget http://ftp.gnu.org/gnu/libtool/libtool-1.5.22.tar.gz
tar xvzf libtool-1.5.22.tar.gz
cd libtool-1.5.22
./configure --prefix=$HOME
make install
cd ../..
rm -fr tmp
```
If you would prefer to place them in another directory, you will need to set the environment variable `AUTOTOOLS_DIR` to this directory in your shell's login or shell initialisation file (e.g., `~/.profile`, `~/.bashrc`, `~/.login`, or `~/.cshrc`).  *Do not specify a standard system directory* (_e.g._, `/usr/local`) unless you actually installed the autotools into that directory yourself from the GNU source code, otherwise you will encounter many conflicts!!!

The tools that you should install are:

 * *autoconf (version 2.59)*
 * *automake (version 1.9.6)*
 * *libtool (version 1.5.22)*

You need to install them in this order, and you should always specify the same argument to `--prefix`.

You can get the source code for each package from

 * [http://ftp.gnu.org/gnu/autoconf/](http://ftp.gnu.org/gnu/autoconf/)
 * [http://ftp.gnu.org/gnu/automake/](http://ftp.gnu.org/gnu/automake/)
 * [http://ftp.gnu.org/gnu/libtool/](http://ftp.gnu.org/gnu/libtool/)

Make sure you get the correct version for each tool, as indicated in the list above.

After they are installed, you also need to *ensure that your `$PATH` variable is set so that your self-installed versions of the tools are the ones that are actually used.*

When you run `configure` in your local copy with the `--enable-maintainer-mode` flag (which you should do as a developer), it will test to see if the above conditions are met and will fail if they are not met.