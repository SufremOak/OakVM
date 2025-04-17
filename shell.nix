{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    buildInputs = with pkgs; [
      nasm
      gcc
    ];

    shellHook = ''
      echo "Development environment loaded!"
      export PS1="\[\033[1;32m\][dev]\[\033[0m\] $PS1"
    '';
  }
