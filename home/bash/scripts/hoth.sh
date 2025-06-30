#!/usr/bin/env bash

set -euo pipefail

if ! grep -q "^Host hoth$" "$HOME/.ssh/config"; then
  echo "Could not find SSH configuration for host named Hoth"
  exit 1
fi

EXCLUDE_PATTERNS=('@*' 'docker' '.git' 'homes' 'NetBackup' 'web*')

exclusions() {
  printf -- "-name '%s' -o " "${EXCLUDE_PATTERNS[@]}" | sed 's/ -o $//'
}

upload() {
  # shellcheck disable=SC2029
  destination="$(ssh hoth "find /volume1 -type d \( $(exclusions) \) -prune -o -type d -print" | gum filter --limit 1 --header "Upload Destination")"
  target=("$@")

  if [[ -z "$destination" ]]; then
    echo "Error: No destination selected"
    exit 1
  fi

  if [[ ${#target[@]} -eq 0 ]]; then
    echo "Error: No target files specified"
    exit 1
  fi

  # Explicitly use port 22, since ssh_config has a different port set
  rsync -ahuvzP \
    --verbose \
    --exclude='*.tmp' \
    --exclude='.DS_Store' \
    -e "ssh -p 22" \
    "${target[@]}" "hoth:${destination}/"
}

download() {
  # shellcheck disable=SC2029
  targets="$(ssh hoth "find /volume1 \( $(exclusions) \) -prune -o \( -type d -o -type f \) ! -name '*.tmp' ! -name '.DS_Store' -print" | gum filter --no-limit --header "Choose Downloads")"

  if [[ -z "$targets" ]]; then
    echo "Error: No targets selected"
    exit 1
  fi

  # Convert newline-separated targets to array
  readarray -t target_array <<<"$targets"

  # Prepend "hoth:" to each target for rsync
  hoth_targets=()
  for target in "${target_array[@]}"; do
    hoth_targets+=("hoth:${target}")
  done

  rsync -ahuvzP \
    --verbose \
    -e "ssh -p 22" \
    "${hoth_targets[@]}" .
}

case "${1:-}" in
up)
  shift
  upload "$@"
  ;;
dl)
  shift
  download "$@"
  ;;
"")
  echo "Error: No subcommand provided. Use 'up' or 'dl'."
  exit 1
  ;;
*)
  echo "Error: Unknown subcommand '$1'. Use 'up' or 'dl'."
  exit 1
  ;;
esac
