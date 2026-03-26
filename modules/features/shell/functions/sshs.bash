#!/usr/bin/env bash

# Finds matching SSH hosts in the config file.
function sshs() {
  cat ~/.ssh/config | grep -i -A 1 "$1" | grep -v grep
}
