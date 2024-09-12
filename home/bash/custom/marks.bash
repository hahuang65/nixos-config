#!/usr/bin/env bash

export MARKPATH=$HOME/.marks

function jump {
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

function mark {
  mkdir -p "$MARKPATH"
  ln -s "$(pwd)" "$MARKPATH/$1"
}

function unmark {
  rm -i "$MARKPATH/$1"
}

function marks {
  ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- && echo
}

alias j="jump"

_completemarks() {
  local curw=${COMP_WORDS[COMP_CWORD]}
  local wordlist=$(find "$MARKPATH" -type l -exec basename {} \;)
  COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
  return 0
}

set -h
if hash complete 2>/dev/null; then
  complete -F _completemarks jump unmark j
fi
set +h
