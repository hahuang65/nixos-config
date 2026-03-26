#!/usr/bin/env bash

if exists mise; then
  if [[ $OSTYPE == darwin* ]]; then
    export MISE_ASDF_COMPAT=1
  fi

  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi
