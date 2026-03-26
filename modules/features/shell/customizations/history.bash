#!/usr/bin/env bash

if [[ $- == *i* ]]; then
  # Completes history expansion
  # e.g. typing `!!<space>` will replace it with the last command
  bind Space:magic-space
fi

# Don't clobber history, just append to it
shopt -s histappend

# Immediately append to history instead of waiting on session end
PROMPT_COMMAND="history -a;history -n;${PROMPT_COMMAND}"

# Save multi-line commands as a single command
shopt -s cmdhist

# Larger history size
HISTSIZE=500000
HISTFILESIZE=100000

# Ignore duplicates in history
HISTCONTROL=ignoreboth:erasedups

# Have timestamps for history
export HISTTIMEFORMAT='%F %T - '

# Don't record some commands in history
export HISTIGNORE="clear:history:[bf]g:exit:date:* --help"
