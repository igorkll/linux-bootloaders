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

rm -rf .build
mkdir .build

reset_grub_variant() {
    local variant_name=".build/$1"

    rm -rf "$variant_name"
    mkdir "$variant_name"
}

build_grub_target() {
    local variant_name="$1"
    local platform="$2"
    local target="$3"

    local dir_name="${target}-${platform}"
    local build_path="build/${variant_name}/${dir_name}"

    if [ "$platform" = "efi" ]; then
        grub_output_file="grubx64.efi"
    else
        grub_output_file="core.img"
    fi

    # ---- build

    mkdir -p ".${build_path}"
    cd ".${build_path}"
    ../../../.temp/grub-2.14/configure --with-platform=$platform --target=$target
    make -j$(nproc)
    grub-mkimage -O "${dir_name}" -o "${grub_output_file}" -p /boot/grub biosdisk part_msdos part_gpt fat ext2 normal efi_gop efi_uga configfile
    cd ../../..

    # ---- export

    mkdir -p "${build_path}"
    cp -r ".${build_path}/grub-core/." "${build_path}/"
}

reset_grub_variant "official-2.14"
build_grub_target "official-2.14" "pc" "x86_64"
build_grub_target "official-2.14" "efi" "x86_64"
build_grub_target "official-2.14" "pc" "i386"
build_grub_target "official-2.14" "efi" "i386"
build_grub_target "official-2.14" "pc" "arm64"
build_grub_target "official-2.14" "efi" "arm64"
build_grub_target "official-2.14" "pc" "arm"
build_grub_target "official-2.14" "efi" "arm"

# -------------- cleanup

rm -rf .temp
rm -rf .build
