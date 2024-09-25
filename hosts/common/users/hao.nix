{
  config,
  configLib,
  lib,
  ...
}:

let
  inherit (lib)
    lists
    mkDefault
    mkOption
    types
    ;
  cfg = config.users.hao;
  baseGroups = [
    "wheel"
    "networkmanager"
  ];
in
{
  options = {
    users.hao = {
      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra groups to add user hao to";
      };
    };
  };

  config = {
    # Don't forget to `passwd`!
    users.users = {
      hao = {
        isNormalUser = true;
        home = "/home/hao";
        description = "Howard Huang";
        extraGroups = lists.unique (baseGroups ++ cfg.extraGroups);
      };
    };

    home-manager.users.hao =
      { pkgs, ... }:
      {
        nixpkgs.config.allowUnfree = true;

        home.packages = with pkgs; [
          atac
          bandwhich
          csvlens
          curlie
          erdtree
          fd
          ferdium
          fx
          grex
          htop
          hwatch
          hyperfine
          ijq
          jq
          lnav
          miller
          obsidian
          ov
          pastel
          pgcli
          pick
          plex-media-player
          portal
          pre-commit
          prettyping
          procs
          pueue
          ripgrep
          rsync
          slack
          termscp
          thunderbird
          tokei
          unzip
          urlscan
          vim
          w3m
          wget
          wl-clipboard
          xsv
          yank
          zathura
          zeal
        ];

        home.sessionVariables = {
          EDITOR = mkDefault "vim";
        };

        # User directories
        xdg.userDirs = {
          enable = true;
          createDirectories = true;
        };

        imports = [ (configLib.fromRoot "home") ];

        # The state version is required and should stay at the version you
        # originally installed.
        home.stateVersion = "24.05";
      };

    style = {
      cursor.size = 36;
      font.style.sansSerif = "General Sans";
      font.size = {
        desktop = 18;
        popup = 18;
      };
      wallpaper = "unicat.png";
    };

  };
}
