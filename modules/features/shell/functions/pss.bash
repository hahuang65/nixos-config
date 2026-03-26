#!/usr/bin/env bash

# Finds all processes with the given name
function pss() {
  if exists procs; then
    procs --tree "$1"
  else
    pgrep -i "$1" | xargs ps -p
  fi
}
