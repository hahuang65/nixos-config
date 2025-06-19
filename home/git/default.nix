{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  customDir = "${config.xdg.configHome}/git";
  a5Config = "${customDir}/a5.config";
  aliases = "${customDir}/aliases";
  gitmessage = "${customDir}/message";
  secret = "${customDir}/.secret.config";
in
{
  options = {
    git = {
      enable = mkEnableOption "git";
    };
  };

  config = mkIf config.git.enable {
    home.packages = with pkgs; [
      delta
      gh
    ];

    sops.secrets."git/github/token" = { };

    programs.bash.sessionVariables = {
      GITHUB_TOKEN = "$(cat ${config.sops.secrets."git/github/token".path})";
    };

    programs.git = {
      enable = true;

      delta = {
        enable = true;

        options = {
          features = "colorscheme";
          navigate = true;
          side-by-side = true;

          colorscheme = {
            commit-style = "raw";
            commit-decorations-style = "blue ol";
            file-style = "omit";
            hunk-header-style = "file line-number";
            hunk-header-decoration-style = "blue box";
            hunk-header-file-style = "red";
            hunk-header-line-number-style = "red";
            minus-style = "bold red";
            minus-non-emph-style = "red";
            minus-emph-style = "bold black red";
            minus-empty-line-marker-style = "normal red";
            zero-style = "normal";
            plus-style = "bold green";
            plus-non-emph-style = "green";
            plus-emph-style = "bold black green";
            plus-empty-line-marker-style = "normal green";
            whitespace-error-style = "reverse purple";
            true-color = "always";
            line-numbers-zero-style = "dim normal";
            line-numbers-minus-style = "red";
            line-numbers-plus-style = "green";
            line-numbers-left-style = "blue";
            line-numbers-right-style = "blue";
          };

          interactive = {
            features = "colorscheme";
            keep-plus-minus-markers = false;
          };
        };
      };

      extraConfig = {
        url = {
          "git@github.com:hahuang65/" = {
            pushInsteadOf = "https://github.com/";
            insteadOf = "gh:";
          };
          "git@github.com:summit-partners/" = {
            pushInsteadOf = "https://github.com/";
            insteadOf = "a5:";
          };
          "git@github.com:bitsmithy/" = {
            pushInsteadOf = "https://github.com/";
            insteadOf = "bs:";
          };
          "git@git.sr.ht:~hwrd/" = {
            pushInsteadOf = "https://git.sr.ht/";
            insteadOf = "srht:";
          };
        };
        init = {
          defaultBranch = "main";
        };
        branch = {
          sort = "-committerdate";
        };
        color = {
          ui = "auto";
        };
        commit = {
          template = gitmessage;
          verbose = true;
        };
        core = {
          fsmonitor = true;
          untrackedCache = true;
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          colorMovedWS = "allow-indentation-change";
          context = "10";
          mnemonicPrefix = true;
          renames = true;
          submodule = "log";
        };
        fetch = {
          all = true;
          prune = true;
          prunetags = true;
        };
        filter = {
          lfs = {
            clean = "git-lfs clean %f";
            smudge = "git-lfs smudge %f";
            required = true;
          };
        };
        help = {
          autocorrect = "prompt";
        };
        log = {
          date = "iso";
        };
        merge = {
          conflictstyle = "zdiff3";
        };
        pager = {
          blame = "delta";
          diff = "delta";
          reflog = "delta";
          show = "delta";
        };
        pull = {
          rebase = true;
        };
        push = {
          autoSetupRemote = true;
          default = "current";
          followtags = true;
        };
        rebase = {
          autostash = true;
          autosquash = true;
          missingCommitsCheck = "error";
          updateRefs = true;
        };
        rerere = {
          autoupdate = true;
          enabled = true;
        };
        status = {
          submoduleSummary = true;
        };
        tag = {
          sort = "version:refname";
        };
      };

      ignores = [
        "**.orig"
        "*.pyc"
        ".direnv/"
        ".DS_Store"
        "._*"
        ".bundle"
        ".dccache"
        ".powrc"
        ".go/"
        "Thumbs.db"
        "coverage.data"
        "coverage/"
        "db/*.sqlite3"
        "log/*"
        "public/assets/"
        "spec/tmp/*"
        "tags"
        "tags.lock"
        "tags.temp"
        "tmp/*"
        "vendor/bundle"
        "vendor/plugins"
      ];

      includes = [
        { path = secret; }
        { path = aliases; }
        {
          path = a5Config;
          condition = "hasconfig:remote.*.url:git@github.com:summit-partners/**";
        }
      ];
    };

    home.file = {
      "${aliases}".source = ./aliases;
      "${gitmessage}".source = ./message;
      "${a5Config}".source = ./a5.config;
      "${config.xdg.configHome}/gh/config.yml".text = ''
        # The current version of the config schema
        version: 1
        # What protocol to use when performing git operations. Supported values: ssh, https
        git_protocol: ssh
        # When to interactively prompt. This is a global config that cannot be overridden by hostname. Supported values: enabled, disabled
        prompt: enabled
      '';
    };

    sops.secrets."git/secrets/${config.home.username}" = {
      path = "${secret}";
    };
  };
}
