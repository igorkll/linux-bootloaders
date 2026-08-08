#!/bin/bash

rm -rf build
mkdir build

rm -rf .temp
mkdir .temp
cd .temp

wget https://ftp.gnu.org/gnu/grub/grub-2.14.tar.xz
tar -xvf grub-2.14.tar.xz
cd grub-2.14


