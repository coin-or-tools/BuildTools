# script to download and install the autoools versions that we currently use with COIN-OR/BuildTools
# original script by Pierre Bonami

PREFIX=$HOME/local2

# so that we can configure automake with the new (then installed) autoconf
export PATH=$PREFIX/bin:$PATH

# cleanup from previous (maybe failed) build
rm -rf autoconf-2.68* automake-1.11.3* libtool-2.4.2*

wget ftp://ftp.gnu.org/gnu/autoconf/autoconf-2.68.tar.gz
tar xvzf autoconf-2.68.tar.gz
cd autoconf-2.68
./configure --prefix=$PREFIX
make install
cd ..

wget ftp://ftp.gnu.org/gnu/automake/automake-1.11.3.tar.gz
tar xvzf automake-1.11.3.tar.gz
cd automake-1.11.3
./configure --prefix=$PREFIX
make install
cd ..

wget ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.2.tar.gz
tar xvzf libtool-2.4.2.tar.gz
cd libtool-2.4.2
./configure --prefix=$PREFIX
make install
cd ..

rm -rf autoconf-2.68* automake-1.11.3* libtool-2.4.2*
