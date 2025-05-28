#!/usr/bin/env bash

script="tofi-$(
  find "$HOME/.nix-profile/bin" -maxdepth 1 -executable -name 'tofi-*' -exec basename {} \; |
    grep -v "tofi-run" |
    grep -v "tofi-drun" |
    grep -v "tofi-srun" |
    sed 's/tofi-//' |
    tofi --prompt-text "Script: "
)"

if command -v "$script"; then
  eval "$script"
fi
