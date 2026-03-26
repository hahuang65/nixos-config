#!/usr/bin/env bash

# Only proceed in interactive shells
if [[ $- == *i* && ${ENABLE_BLESH} == "1" ]]; then
  # Check if ble.sh is already installed
  if [ -f ~/.local/share/blesh/ble.sh ]; then
    # Clear positional parameters to avoid passing script name to ble.sh
    set --
    source ~/.local/share/blesh/ble.sh
    # bleopt keymap_vi_mode_show:=
    bleopt color_scheme=catppuccin_mocha
  else
    echo "ble.sh not found, downloading and installing..."

    temp_dir=$(mktemp -d)
    cd "$temp_dir" || exit

    curl -L https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf -
    bash ble-nightly/ble.sh --install ~/.local/share

    cd - >/dev/null || exit
    rm -rf "$temp_dir"

    echo "ble.sh installation completed."
  fi
fi
