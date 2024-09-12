#!/usr/bin/env bash

set -h

if hash bat 2>/dev/null; then
  alias cat="bat"

  if hash batman 2>/dev/null; then
    alias man="batman"
  else
    export MANPAGER="sh -c 'col -bx | bat --language man --plain --pager=\"less --raw-control-chars\"'"
    export MANROFFOPT="-c"
  fi

  if hash batgrep 2>/dev/null; then
    alias rg="batgrep"
  fi
fi

if hash curlie 2>/dev/null; then
  alias curl="curlie"
fi

if hash delta 2>/dev/null; then
  function diff {
    command diff -u "$@" | delta
  }
fi

if hash dog 2>/dev/null; then
  alias dig="dog"
fi

if hash htop 2>/dev/null; then
  alias top="htop"
fi

if hash hwatch 2>/dev/null; then
  alias watch="hwatch"
fi

if hash ov 2>/dev/null; then
  alias less="ov"
fi

if hash prettyping 2>/dev/null; then
  alias ping="prettyping --nolegend"
fi

set +h
