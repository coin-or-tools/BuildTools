#!/bin/sh
#
# This file is distributed under the Eclipse Public License 2.0.
# See LICENSE for details.
#
# script to download and install the autoools versions that we currently use with COIN-OR/BuildTools
# original script by Pierre Bonami

acver=2.71
aaver=2022.09.03
amver=1.16.5
ltver=2.4.7

# exit immediately if something fails
set -e

if test -n "$COIN_AUTOTOOLS_DIR" ; then
  echo "Installation into $COIN_AUTOTOOLS_DIR"
  mkdir -p "$COIN_AUTOTOOLS_DIR"
  PREFIX="--prefix $COIN_AUTOTOOLS_DIR"
  # so that we can configure automake with the new (then installed) autoconf
  export PATH=$COIN_AUTOTOOLS_DIR/bin:"$PATH"
fi

# cleanup from previous (maybe failed) build
rm -rf autoconf-$acver* autoconf-archive-$aaver* automake-$amver* libtool-$ltver*

curl -O https://ftp.gnu.org/gnu/autoconf/autoconf-$acver.tar.gz
tar xvzf autoconf-$acver.tar.gz
cd autoconf-$acver
./configure $PREFIX
make install
cd ..
rm -rf autoconf-$acver*

curl -O https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-$aaver.tar.xz
tar xvJf autoconf-archive-$aaver.tar.xz
cd autoconf-archive-$aaver
./configure $PREFIX
make install
cd ..
rm -rf autoconf-archive-$aaver*

# apply patch to AX_JNI_INCLUDE_DIR to support macOS >= 11.0.0
# taken from https://stackoverflow.com/questions/163747/autoconf-test-for-jni-include-dir
if test -e $COIN_AUTOTOOLS_DIR/share/aclocal/ax_jni_include_dir.m4 ; then
  patch $COIN_AUTOTOOLS_DIR/share/aclocal/ax_jni_include_dir.m4 ax_jni_include_dir.fix
fi

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
