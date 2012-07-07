#!/bin/sh

mkdir build
cd build
cmake ..
make $1
make $1-upload
cd ..
rm -rf build
