#!/usr/bin/env bash

set -euo pipefail

query=$(echo "" | tofi --require-match=false --prompt "nix search: ")

if [[ -n "$query" ]]; then
  nix shell nixpkgs#nix-search nixpkgs#jq nixpkgs#wl-clipboard --command nix-search --json "$query" |
    jq -r '.[] | (.name + " | " + .description)' |
    sort | uniq |
    tofi --num-results 10 --prompt "results: " |
    awk -F' | ' '{print $1}' |
    wl-copy
fi
