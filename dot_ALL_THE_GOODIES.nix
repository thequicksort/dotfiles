# ALL THE GOODIES

{ pkgs ? import <nixpkgs> {}, python ? pkgs.python37}:
let goodies = [
    python
    python.pkgs.black
    python.pkgs.bpython
    python.pkgs.debugpy
    python.pkgs.flake8
    python.pkgs.isort
    python.pkgs.pytest

    # Nix
    pkgs.cachix
    pkgs.lorri

    # # File management
    pkgs.git
    pkgs.chezmoi

    # # Shell
    pkgs.bashInteractive  # Needed for Nix-Shell
    pkgs.locale  # Needed for zsh p10k
    pkgs.ncurses  # Needed for zsh p10k
    pkgs.zsh
    pkgs.zsh-syntax-highlighting
    pkgs.zsh-powerlevel10k
    pkgs.zsh-nix-shell
    pkgs.oh-my-zsh

    # # Rust
    pkgs.rust

    # Editors
    pkgs.emacs
    pkgs.vim
    # TODO: VSCode/VScodium with https://nixos.wiki/wiki/VSCodium
];
in
{
    packages = goodies;
    shell = pkgs.mkShell {
        shellHook = ''
            zsh
        '';
        inputsFrom = goodies;
    };
}