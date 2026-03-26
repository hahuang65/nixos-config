#!/usr/bin/env bash

if [[ $OSTYPE == darwin* ]]; then
  # A5 paths
  export PATH="$HOME/Projects/a5/toolbox:$PATH"

  # Homebrew paths
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/sbin:/opt/homebrew/bin:$PATH"

  # Use 1Password's ssh agent
  export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
fi
