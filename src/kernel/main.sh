#!/usr/bin/env bash

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
WHITE='\e[37m'
RESET='\e[0m'

main() {
    nix-shell ./etc/configuration.nix -p bash
    echo "Welcome to OakVM!"
}

setup() {
    export PATH=$PATH:./bin
    export NEWHOME=./home
    export USER=OakVM

    export LOGNAME=$USER
    export SHELL=/bin/bash
    export TERM=xterm-256color
    export DISPLAY=:0
    export EDITOR=nano
}

check() {

    if [ ! command -v "chroot" ]; then
        echo "[error] chroot not found."
        exit 1
    fi

    if [ ! command -v "nix-shell" ]; then
        echo "[error] nix not found."
        exit 1
    fi

    if [ ! command -v "wasmer" ]; then
        echo "[error] wasmer not found."
        exit 1
    fi

    if [ ! -d "$NEWHOME" ]; then
        echo "Error: Home directory not found."
        exit 1
    fi
    if [ ! -d "$NEWHOME/.config" ]; then
        mkdir -p "$NEWHOME/.config"
    fi
    if [ ! -d "$NEWHOME/.config/oakvm" ]; then
        mkdir -p "$NEWHOME/.config/oakvm"
    fi
    if [ ! -d "$PATH"]; then
        echo "[error] /bin not found."
        exit 1
    fi
}

# setup
check

case "$1" in
    start)
        main
        ;;
    stop)
        echo "Stopping OakVM..."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
