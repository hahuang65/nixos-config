#!/usr/bin/env bash

# Prevent file overwrite on STDOUT redirection
# Use `>|` to force redirection to existing file
set -o noclobber
