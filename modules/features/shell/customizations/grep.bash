#!/usr/bin/env bash

if [[ $OSTYPE == linux-gnu* ]]; then
  export GREP_COLOR='mt=1;32'
elif [[ $OSTYPE == darwin* ]]; then
  export GREP_COLOR='1;32'
fi

alias grep='grep --color=auto'
