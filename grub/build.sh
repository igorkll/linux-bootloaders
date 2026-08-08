#!/bin/bash
set -e

# -------------- download grub
rm -rf .temp
mkdir .temp
cd .temp

wget https://ftp.gnu.org/gnu/grub/grub-2.14.tar.xz
tar -xvf grub-2.14.tar.xz

cd ..

# -------------- build official grub

rm -rf build
mkdir build

reset_grub_variant() {
    local variant_name="build/$1"

    rm -rf "$variant_name"
    mkdir "$variant_name"
}

build_grub_target() {
    local variant_name="$1"
    local platform="$2"
    local target="$3"

    local build_path="build/${variant_name}/${target}-${platform}"

    mkdir -p "${build_path}"
    cd "${build_path}"
    ../../../.temp/grub-2.14/configure --with-platform=$platform --target=$target
    make -j$(nproc)
}

reset_grub_variant "official-2.14"
build_grub_target "official-2.14" "efi" "x86_64"

