#!/bin/bash

# -------------- download grub

rm -rf .temp
mkdir .temp
cd .temp

wget https://ftp.gnu.org/gnu/grub/grub-2.14.tar.xz
tar -xvf grub-2.14.tar.xz

cd ..

# -------------- build official grub

reset_grub_variant() {
    local variant_name="$1"

    rm -rf "$variant_name"
    mkdir "$variant_name"
}

build_grub_target() {
    local variant_name="$1"

    cd "$variant_name"
}

reset_grub_variant "official-2.14"


.temp/grub-2.14/configure --with-platform=efi --target=x86_64
