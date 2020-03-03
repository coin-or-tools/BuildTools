#!/bin/sh
# script to download and install the autoools versions that we currently use with COIN-OR/BuildTools
# original script by Pierre Bonami

PREFIX=$HOME/local2

acver=2.69
aaver=2019.01.06
amver=1.16.1
ltver=2.4.6

# exit immediately if something fails
set -e

# so that we can configure automake with the new (then installed) autoconf
export PATH=$PREFIX/bin:"$PATH"

# cleanup from previous (maybe failed) build
rm -rf autoconf-$acver* autoconf-archive-$aaver* automake-$amver* libtool-$ltver*

wget http://ftp.gnu.org/gnu/autoconf/autoconf-$acver.tar.gz
tar xvzf autoconf-$acver.tar.gz
cd autoconf-$acver
./configure --prefix=$PREFIX
make install
cd ..

wget http://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-$aaver.tar.xz
tar xvJf autoconf-archive-$aaver.tar.xz
cd autoconf-archive-$aaver
./configure --prefix=$PREFIX
make install
cd ..

wget http://ftp.gnu.org/gnu/automake/automake-$amver.tar.gz
tar xvzf automake-$amver.tar.gz
cd automake-$amver
./configure --prefix=$PREFIX
make install
cd ..

wget http://ftp.gnu.org/gnu/libtool/libtool-$ltver.tar.gz
tar xvzf libtool-$ltver.tar.gz
cd libtool-$ltver
./configure --prefix=$PREFIX
make install
cd ..

rm -rf autoconf-$acver*  autoconf-archive-$aaver* automake-$amver* libtool-$ltver*
