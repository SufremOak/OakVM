{ pkgs ? import <nixpkgs> {} }:

with pkgs;
mkShell {
  buildInputs = [
    # Add packages here
    git
    curl
    wget
    wasmer
    rustup
    deno
    clang
    llvm
    bash
  ];

  shellHook = ''
    echo "Welcome to development shell"
    source ./.oakrc
  '';
}
