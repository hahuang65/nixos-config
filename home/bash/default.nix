{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  configDir = "${config.xdg.configHome}/bash";
in
{
  options = {
    bash = {
      enable = mkEnableOption "bash";
    };
  };

  config = mkIf config.bash.enable {
    home.packages = [
      (import ./scripts/psk.nix { inherit pkgs; })
      (import ./scripts/pss.nix { inherit pkgs; })
    ];

    home.file = {
      "${configDir}" = {
        source = ./config;
        recursive = true;
      };
    };

    sops.secrets = {
      "anthropic/apikey" = { };
      "git/github/token" = { };
    };

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

      bashrcExtra = ''
        export CLICOLOR=1;
        export GREP_COLOR="mt=1;32";
        export HISTTIMEFORMAT="%F %T - "; # Add timestamps to history
        export PROMPT_COMMAND="history -a"; # Append to history immediately instead of session end
        export PS1="\\[\\e[34m\\]\$(git prompt 2>/dev/null)\\[\\e[39m\\]$ ";

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

        for f in ${configDir}/*.bash; do source "$f"; done
      '';

      shellAliases = {
        ".." = "cd .. ";
        cp = "cp --interactive --verbose --recursive";
        grep = "grep --color=auto";
        hs = "history | grep --color=auto";
        ls = "ls --color=auto";
        mkdir = "mkdir --verbose --parents";
        mv = "mv --interactive --verbose";
        open = "xdg-open";
        v = "vim";
      };

      sessionVariables = {
        ANTHROPIC_API_KEY = "$(cat ${config.sops.secrets."anthropic/apikey".path})";
        GITHUB_TOKEN = "$(cat ${config.sops.secrets."git/github/token".path})";
      };
    };
  };
}
