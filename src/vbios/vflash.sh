#!/usr/bin/env bash

show_help() {
    echo "Usage: $0 [command]"
    echo "Commands:"
    echo "  flash    Flash the BIOS to a .oak binaryScript module"
    echo "  status   Check the status of the BIOS"
    echo "  reset    Reset the BIOS"
    echo "  build    Build the BIOS"
}

case $1 in
    (flash)
    echo "Flashing..."
    echo "
        #oak _start
            ==> self value 0x121F0000
            ==> set => module startup _start(self)
            module.startup(self)
            when self.state:
                asm(elf_i386) <==> SameStartup()

            #oak _loop on (if self.state === (xor <==> nor))
        #oak _end
    " > vbios.oak
    echo "0x121F0000:"
    cat vbios.oak
        ;;
    (status)
        echo "Status: OK"
        ;;
    (reset)
        echo "Resetting..."
        rm -rf vbios.oak oaki31sk.o oaki31sk.bin
        ;;
    (build)
        echo "Starting..."
        if [ command -v nasm ] && [ command -v ld ]
        then
            echo "Building..."
            nasm -f elf32 -o vflash.o vflash.asm
            ld -m elf_i386 -o vflash vflash.o
            rm vflash.o
            nasm -f elf32 -o oaki31sk.o boot.s
            ld -m elf_i386 -o oaki31sk.bin oaki31sk.o
            if [ $? -eq 0 ]
            then
                echo "Build successful"
            else
                echo "Build failed"
            fi
        else
            echo "Error: nasm or ld not found"
        fi
        ;;
    (*)
        echo "No command provided, or non-existent command"
        show_help
        exit 1

        ;;
esac
