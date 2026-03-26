#!/usr/bin/env bash

if exists direnv; then
  _direnv_bin=$(command -v direnv)
  _direnv_hook() {
    local previous_exit_status=$?
    trap -- '' SIGINT
    eval "$("$_direnv_bin" export bash)"
    trap - SIGINT
    return $previous_exit_status
  }
  if [[ ";${PROMPT_COMMAND[*]:-};" != *";_direnv_hook;"* ]]; then
    if [[ "$(declare -p PROMPT_COMMAND 2>&1)" == "declare -a"* ]]; then
      PROMPT_COMMAND=(_direnv_hook "${PROMPT_COMMAND[@]}")
    else
      PROMPT_COMMAND="_direnv_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    fi
  fi
fi
