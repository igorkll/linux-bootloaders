#!/bin/bash
set -e

BASE_GRUB="grub-2.14"

# -------------- download grub

rm -rf .temp
mkdir .temp
cd .temp

wget "https://ftp.gnu.org/gnu/grub/${BASE_GRUB}.tar.xz"
tar -xvf "${BASE_GRUB}.tar.xz"

clone_grub() {
    mkdir -p "$2"
    cp -a "$1/." "$2/"
}

clone_grub "$BASE_GRUB" "no-welcome-$BASE_GRUB"

cp ../patches/disable_welcome_main.c "no-welcome-$BASE_GRUB/grub-core/kern/main.c"

cd ..

# -------------- build official grub

rm -rf .build
mkdir .build

rm -rf build
mkdir build

reset_grub_variant() {
    local variant_name=".build/$1"

    rm -rf "$variant_name"
    mkdir "$variant_name"
}

build_grub_target() {
    local base_grub_name="$1"
    local variant_name="$2"
    local platform="$3"
    local target="$4"

    local dir_name="${target}-${platform}"
    local build_path="build/${variant_name}/${dir_name}"

    # ---- build

    local extra_args=""

    local compiller_target="$target"
    if [ "$target" = "arm64" ]; then
        compiller_target="aarch64-linux-gnu"
    elif [ "$target" = "arm" ]; then
        compiller_target="arm-linux-gnu"
        extra_args="CC=arm-linux-gnueabi-gcc CFLAGS=\"-march=armv7-a\" --host=arm-linux-gnueabi"
    fi

    mkdir -p ".${build_path}"
    cd ".${build_path}"
    ../../../.temp/$base_grub_name/configure HOST_CPPFLAGS="-I$(pwd)" TARGET_CPPFLAGS="-I$(pwd)" --with-platform=$platform --target=$compiller_target $extra_args
    make -j$(nproc)
    cd ../../..

    # ---- export

    mkdir -p "${build_path}"
    cp -r ".${build_path}/grub-core/." "${build_path}/"
}

reset_grub_variant "official-2.14"
build_grub_target "grub-2.14" "official-2.14" "pc" "i386"
build_grub_target "grub-2.14" "official-2.14" "efi" "x86_64"
build_grub_target "grub-2.14" "official-2.14" "efi" "i386"
build_grub_target "grub-2.14" "official-2.14" "efi" "arm64"
# build_grub_target "grub-2.14" "official-2.14" "efi" "arm"

reset_grub_variant "no-welcome-2.14"
build_grub_target "no-welcome-grub-2.14" "no-welcome-2.14" "pc" "i386"
build_grub_target "no-welcome-grub-2.14" "no-welcome-2.14" "efi" "x86_64"
build_grub_target "no-welcome-grub-2.14" "no-welcome-2.14" "efi" "i386"
build_grub_target "no-welcome-grub-2.14" "no-welcome-2.14" "efi" "arm64"
# build_grub_target "no-welcome-grub-2.14" "no-welcome-2.14" "efi" "arm"

# -------------- cleanup

rm -rf .temp
rm -rf .build
