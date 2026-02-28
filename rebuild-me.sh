#!/usr/bin/env fish
echo "1408" | sudo -S env NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure $argv
