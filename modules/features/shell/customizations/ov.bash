#!/usr/bin/env bash

_setup_ov() {
  if exists ov; then
    export PSQL_PAGER='ov -F -C -d "|" -H1 --column-rainbow --align'
    export MANPAGER="ov --section-delimiter '^[^\s]' --section-header"
    export BAT_PAGER="ov -F -H3"
    export TAILSPIN_PAGER="ov -f [FILE]"

    alias csv="ov -H1 -C -d',' -c --column-rainbow "
  fi
}

_setup_ov
unset -f _setup_ov
