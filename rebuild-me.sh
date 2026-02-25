#!/usr/bin/env fish
echo "1408" | sudo -S nixos-rebuild switch --flake .#meowrch --impure $argv
