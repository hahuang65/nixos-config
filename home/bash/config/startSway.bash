#!/usr/bin/env bash

if [ -z "$DISPLAY" ] && [ "$(tty)" == "/dev/tty1" ]; then
  if command -v sway >/dev/null 2>&1; then
    exec sway --unsupported-gpu
  else
    echo "No configured WM/DMs installed"
  fi
fi
