#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

sudo apt-get install -y \
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
