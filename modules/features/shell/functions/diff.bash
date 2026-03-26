#!/usr/bin/env bash

# Run as a function to make sure functions/_*.bash are loaded first
_setup_diff() {
  if exists delta; then
    function diff {
      command diff -u "$@" | delta
    }
  elif hash diff-so-fancy 2>/dev/null; then
    function diff {
      command diff -u "$@" | diff-so-fancy | less --tabs=4 -RFX
    }
  fi
}

_setup_diff
unset -f _setup_diff
