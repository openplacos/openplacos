#!/bin/sh

mkdir build
cd build
cmake ..
make
cp -f *.hex ../../binaries/
cd ..
rm -rf build
