{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    bash = {
      enable = mkEnableOption "bash";
    };
  };
  
  config = mkIf config.bash.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;

      historyFileSize = 100000;
      historySize = 500000;
      historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];
      historyIgnore = [
        "clear"
        "history"
        "[bf]g"
        "exit"
        "date"
        "* --help"
      ];

      profileExtra = ''
        shopt -s histappend # Only append to history, never clobber
        shopt -s cmdhist # Save multiline commands as a single command
        if [[ $- == *i* ]]; then
          # Completes history expansion
          # e.g. typing `!!<space>` will replace it with the last command
          bind Space:magic-space
        fi

        # Makes git auto completion faster favouring for local completions
        __git_files() {
          _wanted files expl 'local files' _files
        }

        if [ ! -z "$VIM" ]; then
          # Emacs mode in vim/nvim because vi-mode in vim/nvim terminal has issues.
          # Otherwise, .inputrc sets vi-mode.
          set -o emacs
        fi

        if hash prettyping 2>/dev/null; then
          alias ping="prettyping --nolegend"
        fi

        if hash htop 2>/dev/null; then
          alias top="htop"
        fi

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

        if hash hwatch 2>/dev/null; then
          alias watch="hwatch"
        fi

        if hash ov 2>/dev/null; then
          alias less="ov"
        fi

        if hash dog 2>/dev/null; then
          alias dig="dog"
        fi

        if hash curlie 2>/dev/null; then
          alias curl="curlie"
        fi

        bind "set completion-ignore-case"
        bind "set completion-map-case"
        bind "set show-all-if-ambiguous"

        set -o ignoreeof
        set -o noclobber # Use `>|` to force redirection to existing file
      '';

      sessionVariables = {
        CLICOLOR = 1;
        GREP_COLOR = "mt=1;32";

        PS1 = "\\[\\e[34m\\]\$(git prompt 2>/dev/null)\\[\\e[39m\\]$ ";

        PROMPT_COMMAND = "history -a"; # Append to history immediately instead of session end
        HISTTIMEFORMAT = "%F %T - "; # Add timestamps to history
      };

      shellAliases = {
        ll = "ls -l";
        ".." = "cd .. ";
        grep = "grep --color=auto";
        hs = "history | grep --color=auto";
        ls = "ls --color=auto";
        mv = "mv --interactive --verbose";
        cp = "cp --interactive --verbose --recursive";
        mkdir = "mkdir --verbose --parents";
      };
    };
  };
}
