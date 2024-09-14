default:
    @just --list --justfile {{justfile()}}

alias b := build
alias l := live

# Opens the index.html file in your browser.
open: build
    xdg-open result/index.html

# Produces the output in a symlinked folder named `result/`.
build:
    nix build .

# Use elm-live to get hot reloading.
live:
    livedev

# Check everything, same as CI does.
check:
    nix flake check

# Regenerates the pinned dependency hashes for the sandboxed Nix builds.
update-elm:
    update-elm-nix-deps

update-nix:
    nix flake update

update: update-elm update-nix
