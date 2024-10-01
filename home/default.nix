{ configLib, lib, ... }:
let
  inherit (lib) mkDefault mkIf;
  inherit (pkgs) stdenv;
in
{
  news.display = "silent";
  nixpkgs.config.allowUnfree = true;

  # User directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  imports = (configLib.scanPaths ./.);

  bash.enable = mkDefault true;
  bat.enable = mkDefault true;
  fonts.enable = mkDefault true;

  darkman = mkIf stdenv.isLinux { enable = mkDefault true; };

  direnv.enable = mkDefault true;
  ferdium.enable = mkDefault true;
  firefox.enable = mkDefault true;

  foot = mkIf stdenv.isLinux { enable = mkDefault true; };

  fuzzel = mkIf stdenv.isLinux { enable = mkDefault true; };

  fzf.enable = mkDefault true;
  git.enable = mkDefault true;

  gtkTheme = mkIf stdenv.isLinux { enable = mkDefault true; };

  keychain = {
    enable = mkDefault false;
    keys = mkDefault [ "id_ed25519" ];
  };

  mako = mkIf stdenv.isLinux { enable = mkDefault true; };

  mise.enable = mkDefault false;
  neovim.enable = mkDefault true;
  readline.enable = mkDefault true;
  senpai.enable = mkDefault false;
  spotify.enable = mkDefault true;

  sway = mkIf stdenv.isLinux { enable = mkDefault true; };

  thunderbird.enable = mkDefault true;
  wezterm.enable = mkDefault true;

  stylix = {
    targets = {
      # neovim.enable = false;
      waybar.enable = false;
    };
  };

  xdgConfig.enable = mkDefault true;

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
}
