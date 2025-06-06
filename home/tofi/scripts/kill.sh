#!/usr/bin/env bash

ps -u "$USER" -o pid=,comm=,%cpu=,%mem= |
  sort -rn -k 3,4 |
  tofi --num-results 10 --prompt-text "kill: " |
  awk '{print $1}' |
  xargs -r kill
