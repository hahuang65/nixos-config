#!/usr/bin/env bash

if [[ $OSTYPE == linux-gnu* ]]; then
  [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
elif [[ $OSTYPE == darwin* ]]; then
  if exists brew; then
    [[ $PS1 && -f "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
  fi
fi

# AWS completion
if exists aws_completer; then
  AWS_COMPLETER_PATH="$(command -v aws_completer)"
  complete -C "${AWS_COMPLETER_PATH}" aws
  complete -C "${AWS_COMPLETER_PATH}" awsl
  complete -C "${AWS_COMPLETER_PATH}" awslocal
fi

# Only if the shell is interactive
if [[ $- == *i* ]]; then
  # Case-insensitive completions
  bind "set completion-ignore-case on"

  # Treat - and _ as equivalent for completions
  bind "set completion-map-case on"

  # Show ambiguous matches with single tab instead of double
  bind "set show-all-if-ambiguous on"
fi

# Git 'change' alias completion
# Completes both local and remote branches (with origin/ prefix stripped)
# Also offers hh/* branches without the hh/ prefix for convenience
_git_change() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  # Get local branches
  local branches=$(git branch --format='%(refname:short)' 2>/dev/null)

  # Get remote branches, strip remote prefix (origin/, upstream/, etc.)
  local remote_branches=$(git branch -r --format='%(refname:short)' 2>/dev/null | sed 's|^[^/]*/||')

  # Combine and remove duplicates
  local all_branches=$(printf "%s\n%s\n" "$branches" "$remote_branches" | sort -u)

  # If the current word doesn't start with "hh/", also offer hh/* branches unprefixed
  local completions="$all_branches"
  if [[ "$cur" != hh/* ]]; then
    local hh_branches=$(echo "$all_branches" | grep "^hh/" | sed 's|^hh/||')
    completions=$(printf "%s\n%s\n" "$completions" "$hh_branches" | sort -u)
  fi

  # Generate completion
  COMPREPLY=($(compgen -W "$completions" -- "$cur"))
}

complete -o bashdefault -o default -o nospace -F _git_change git-change
