#!/bin/sh
# script to download and install the autoools versions that we currently use with COIN-OR/BuildTools
# original script by Pierre Bonami

acver=2.59
amver=1.9.6
ltver=1.5.22

# exit immediately if something fails
set -e

if test -n "$AUTOTOOLS_DIR" ; then
  echo "Installation into $AUTOTOOLS_DIR"
  mkdir -p "$AUTOTOOLS_DIR"
  PREFIX="--prefix $AUTOTOOLS_DIR"
  # so that we can configure automake with the new (then installed) autoconf
  export PATH=$AUTOTOOLS_DIR/bin:"$PATH"
fi

# cleanup from previous (maybe failed) build
rm -rf autoconf-$acver* automake-$amver* libtool-$ltver*

curl -O https://ftp.gnu.org/gnu/autoconf/autoconf-$acver.tar.gz
tar xvzf autoconf-$acver.tar.gz
cd autoconf-$acver
./configure $PREFIX
make install
cd ..
rm -rf autoconf-$acver*

curl -O https://ftp.gnu.org/gnu/automake/automake-$amver.tar.gz
tar xvzf automake-$amver.tar.gz
cd automake-$amver
./configure $PREFIX
make install
cd ..
rm -rf automake-$amver*

curl -O https://ftp.gnu.org/gnu/libtool/libtool-$ltver.tar.gz
tar xvzf libtool-$ltver.tar.gz
cd libtool-$ltver
./configure $PREFIX
make install
cd ..
rm -rf libtool-$ltver*
