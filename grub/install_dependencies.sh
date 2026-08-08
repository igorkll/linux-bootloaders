#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

apt install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

apt install -y \
    build-essential \
    bison \
    flex \
    libfreetype-dev \
    libfuse-dev \
    libdevmapper-dev \
    pkg-config \
    python3 \
    autoconf \
    automake \
    libtool \
    unifont
