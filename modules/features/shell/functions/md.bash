#!/usr/bin/env bash

# Run as a function to make sure functions/_*.bash are loaded first
_setup_md() {
  if exists glow || exists gh; then
    function md {
      local mode="tui"

      if [[ "${1:-}" = "--browser" ]]; then
        mode="browser"
        shift
      fi

      local file="${1:?md: usage: md [--browser] <file>}"
      if [[ ! -f "$file" ]]; then
        echo "md: file not found: $file" >&2
        return 1
      fi

      if [[ "$mode" = "browser" ]]; then
        if ! exists gh; then
          echo "md: gh is not installed" >&2
          return 1
        fi
        if ! gh extension list 2>/dev/null | grep -q 'yusukebe/gh-markdown-preview'; then
          echo "md: gh-markdown-preview extension is not installed" >&2
          echo "  Install with: gh extension install yusukebe/gh-markdown-preview" >&2
          return 1
        fi
        gh markdown-preview "$file"
      else
        if ! exists glow; then
          echo "md: glow is not installed" >&2
          return 1
        fi
        local width=$COLUMNS
        if (( width > 150 )); then
          width=120
        fi
        glow -w "$width" -p "$file"
      fi
    }
  fi
}

_setup_md
unset -f _setup_md
