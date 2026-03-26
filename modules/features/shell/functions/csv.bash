#!/usr/bin/env bash

# Run as a function to make sure functions/_*.bash are loaded first
_setup_csv() {
  if exists duckdb; then
    function csv {
      UI_MODE=""

      if [[ "${1:-}" = "--ui" ]]; then
        UI_MODE="-ui"
        shift
      fi

      local file="$1"
      if [[ ! -f "$file" ]]; then
        echo "csv: file not found: $file" >&2
        return 1
      fi

      duckdb ${UI_MODE} -cmd "CREATE VIEW csv AS FROM '$file';"
    }
  fi
}

_setup_csv
unset -f _setup_csv
