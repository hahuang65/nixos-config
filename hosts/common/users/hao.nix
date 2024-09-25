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

  name = "hao";
  cfg = config.users.${name};
  baseGroups = [
    "wheel"
    "networkmanager"
  ];
in
{
  options = {
    users.${name} = {
      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra groups to add user ${name} to";
      };
    };
  };

  config = {
    sops.secrets."user/hao".neededForUsers = true;
    users.mutableUsers = false;

    users.users = {
      ${name} = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."user/hao".path;
        home = "/home/${name}";
        extraGroups = lists.unique (baseGroups ++ cfg.extraGroups);
        openssh.authorizedKeys.keyFiles = [ config.sops.secrets."ssh/pubkeys/${name}".path ];
      };
    };

    home-manager.users.${name} =
      { pkgs, ... }:
      {
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
