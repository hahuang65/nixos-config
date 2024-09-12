{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  conditionalAliases = "conditional_aliases.bash";
  marksFunc = "marks.bash";
  pskFunc = "psk.bash";
  pssFunc = "pss.bash";
in {
  options = {
    bash = {
      enable = mkEnableOption "bash";
    };
  };
  
  config = mkIf config.bash.enable {
    xdg.configFile."bash/${conditionalAliases}".source = ./src/conditionalAliases.bash;
    xdg.configFile."bash/${marksFunc}".source = ./src/marks.bash;
    xdg.configFile."bash/${pskFunc}".source = ./src/psk.bash;
    xdg.configFile."bash/${pssFunc}".source = ./src/pss.bash;

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
        bind "set completion-ignore-case"
        bind "set completion-map-case"
        bind "set show-all-if-ambiguous"

        set -o ignoreeof
        set -o noclobber # Use `>|` to force redirection to existing file

        shopt -s histappend # Only append to history, never clobber
        shopt -s cmdhist # Save multiline commands as a single command
        if [[ $- == *i* ]]; then
          # Completes history expansion
          # e.g. typing `!!<space>` will replace it with the last command
          bind Space:magic-space
        fi

        if [ ! -z "$VIM" ]; then
          # Emacs mode in vim/nvim because vi-mode in vim/nvim terminal has issues.
          # Otherwise, .inputrc sets vi-mode.
          set -o emacs
        fi

        # Makes git auto completion faster favouring for local completions
        __git_files() {
          _wanted files expl 'local files' _files
        }
        
        source ~/.config/bash/${conditionalAliases}
        source ~/.config/bash/${marksFunc}
        source ~/.config/bash/${pskFunc}
        source ~/.config/bash/${pssFunc}
      '';

      sessionVariables = {
        CLICOLOR = 1;
        GREP_COLOR = "mt=1;32";

        PS1 = "\\[\\e[34m\\]\$(git prompt 2>/dev/null)\\[\\e[39m\\]$ ";

        PROMPT_COMMAND = "history -a"; # Append to history immediately instead of session end
        HISTTIMEFORMAT = "%F %T - "; # Add timestamps to history
      };

      shellAliases = {
        ".." = "cd .. ";
        cp = "cp --interactive --verbose --recursive";
        grep = "grep --color=auto";
        hs = "history | grep --color=auto";
        ll = "ls -l";
        ls = "ls --color=auto";
        mkdir = "mkdir --verbose --parents";
        mv = "mv --interactive --verbose";
        open = "xdg-open";
      };
    };
  };
}
