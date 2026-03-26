#!/usr/bin/env bash

_setup_editor() {
  if [ -n "$VIM" ]; then
    # Emacs mode in vim/nvim because vi-mode in vim/nvim terminal has issues.
    # Otherwise, .inputrc sets vi-mode.
    set -o emacs
  fi

  if exists nvim; then
    export EDITOR="nvim"
    export VISUAL="nvim"
    alias vim=nvim
  else
    export EDITOR="vim"
    export VISUAL="vim"
  fi
}

_setup_editor
unset -f _setup_editor
