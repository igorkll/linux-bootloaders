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

    local modules="part_msdos part_gpt fat ext2 normal configfile"

    if [ "$platform" = "efi" ]; then
        modules="${modules} efi_gop"

        if [ "$target" == "x86_64" ] || [ "$target" == "i386" ]; then
            modules="${modules} efi_uga"
        fi

        if [ "$target" == "x86_64" ]; then
            grub_output_file="grubx64.efi"
        elif [ "$target" == "i386" ]; then
            grub_output_file="grubia32.efi"
        elif [ "$target" == "arm64" ]; then
            grub_output_file="grubaa64.efi"
        elif [ "$target" == "arm" ]; then
            grub_output_file="grubarm.efi"
        fi
    else
        modules="${modules} biosdisk"

        grub_output_file="core.img"
    fi

    # ---- build

    local compiller_target="$target"
    if [ "$target" = "arm64" ]; then
        compiller_target="aarch64-linux-gnu"
    fi

    mkdir -p ".${build_path}"
    cd ".${build_path}"
    ../../../.temp/grub-2.14/configure HOST_CPPFLAGS="-I$(pwd)" TARGET_CPPFLAGS="-I$(pwd)" --with-platform=$platform --target=$compiller_target
    make -j$(nproc)
    grub-mkimage -O "${dir_name}" -o "${grub_output_file}" -p /boot/grub -d grub-core $modules
    cd ../../..

    # ---- export

    mkdir -p "${build_path}"
    cp -r ".${build_path}/grub-core/." "${build_path}/"
}

reset_grub_variant "official-2.14"
# build_grub_target "official-2.14" "pc" "i386"
#build_grub_target "official-2.14" "efi" "x86_64"
#build_grub_target "official-2.14" "efi" "i386"
build_grub_target "official-2.14" "efi" "arm64"
build_grub_target "official-2.14" "efi" "arm"

# -------------- cleanup

rm -rf .temp
rm -rf .build
