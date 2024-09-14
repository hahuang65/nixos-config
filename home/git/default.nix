{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  customDir = "${config.xdg.configHome}/git";
  a5Config = "${customDir}/a5.config";
  aliases = "${customDir}/aliases";
  gitmessage = "${customDir}/message";
  secret = "${customDir}/.secret.config";
in {
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
          "git@github.com:" = {
            pushInsteadOf = "https://github.com/";
            insteadOf = "gh:";
          };
          "git@git.sr.ht:" = {
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
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          colorMovedWS = "allow-indentation-change";
          context = "10";
          submodule = "log";
        };
        fetch = {
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
        };
        rerere = {
          enabled = true;
        };
        status = {
          submoduleSummary = true;
        };
        tag = {
          sort = "taggerdate";
        };
      };

      ignores = [
        ".DS_Store"
        "._*"
        "Thumbs.db"
        "tags"
        "tags.lock"
        "tags.temp"
        ".bundle"
        "vendor/bundle"
        "vendor/plugins"
        "log/*"
        "tmp/*"
        "db/*.sqlite3"
        "public/assets/"
        "coverage/"
        "coverage.data"
        "spec/tmp/*"
        "**.orig"
        ".powrc"
        "*.pyc"
      ];

      includes = [
        { path = secret; }
        { path = aliases; }
        {
          path = a5Config;
          condition = "gitdir:**/a5/**";
        }
      ];
    };
    
    home.file = {
      "${aliases}".source = ./aliases;
      "${gitmessage}".source = ./message;
      "${a5Config}".source = ./a5.config;
    };
  };
}
