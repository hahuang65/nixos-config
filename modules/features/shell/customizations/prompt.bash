#!/usr/bin/env bash

_setup_prompt() {
  if exists starship; then
    eval "$(starship init bash)"
  else
    # Colors
    blue="\[\e[0;34m\]"
    green="\[\e[1;32m\]"
    red="\[\e[1;31m\]"
    reset="\[\e[m\]"

    prompt_command() {
      local status="$?"
      local status_color=""
      if [ $status != 0 ]; then
        status_color=$red
      else
        status_color=$green
      fi
      PS1="${blue}$(git prompt 2>/dev/null)${reset}${status_color}\$${reset} "
      export PS1
    }

    if [[ ! ";${PROMPT_COMMAND};" == *";prompt_command;"* ]]; then
      export PROMPT_COMMAND="prompt_command;${PROMPT_COMMAND}"
    fi
  fi
}

_setup_prompt
unset -f _setup_prompt
