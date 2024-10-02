{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    lists
    mkDefault
    mkOption
    types
    ;

  name = "hhhuang";
  cfg = config.users.${name};
  baseGroups = [
    "wheel"
  ];
in
{
  options = {
  };

  config = {
    users.users = {
      ${name} = {
        home = "/Users/${name}";
      };
    };

    style.wallpaper = "unicat.png";

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
          portal
          pre-commit
          prettyping
          procs
          pueue
          ripgrep
          rsync
          slack
          termscp
          tokei
          unzip
          urlscan
          vim
          wget
          xsv
          yank
        ];

        home.sessionVariables = {
          EDITOR = mkDefault "vim";
        };

        imports = [ (configLib.fromRoot "home") ];

        ferdium.enable = false; # Unsupported on `aarch64-apple-darwin` and `aarch64-darwin`
        firefox.enable = false; # Unsupported on `aarch64-apple-darwin` (investigate why this isn't `aarch64-darwin`)
        neovim.enable = true;
        spotify.enable = false;
        thunderbird.enable = false; # Unsupported on `aarch64-apple-darwin` (investigate why this isn't `aarch64-darwin`)
      };
  };
}
