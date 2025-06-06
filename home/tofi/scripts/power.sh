#!/usr/bin/env bash

case "$(printf "lock\nreboot\nshutdown" | tofi --prompt-text 'power: ')" in
lock) swaylock --daemonize --indicator --screenshots --clock --effect-greyscale --effect-pixelate 5 ;; # FIXME: Can I deduplicate this with what's in sway/default.nix?
reboot) systemctl reboot -i ;;
shutdown) shutdown now ;;
*) exit 1 ;;
esac
