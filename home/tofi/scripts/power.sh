#!/usr/bin/env bash

case "$(printf "reboot\nshutdown" | tofi --num-results 2)" in
reboot) systemctl reboot -i ;;
shutdown) shutdown now ;;
*) exit 1 ;;
esac
