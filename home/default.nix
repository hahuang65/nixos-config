{
  configLib,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkDefault;
in
{
  news.display = "silent";
  nixpkgs.config.allowUnfree = true;

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [ "wlr" ];
        };
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "zathura.desktop" ];
        "inode/directory" = [ "thunar.desktop" ];
      };
    };

    # User directories
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  imports = (configLib.scanPaths ./.);

  bash.enable = mkDefault true;
  bat.enable = mkDefault true;
  fonts.enable = mkDefault true;
  darkman.enable = mkDefault true;
  direnv.enable = mkDefault true;
  ferdium.enable = mkDefault true;
  firefox.enable = mkDefault true;
  foot.enable = mkDefault true;
  fuzzel.enable = mkDefault true;
  fzf.enable = mkDefault true;
  git.enable = mkDefault true;
  gtkTheme.enable = mkDefault true;

  keychain = {
    enable = mkDefault false;
    keys = mkDefault [ "id_ed25519" ];
  };

  mako.enable = mkDefault true;
  mise.enable = mkDefault false;
  neovim.enable = mkDefault true;
  readline.enable = mkDefault true;
  senpai.enable = mkDefault false;
  spotify.enable = mkDefault true;
  sway.enable = mkDefault true;
  thunderbird.enable = mkDefault true;
  wezterm.enable = mkDefault true;

  stylix = {
    targets = {
      neovim.enable = false;
      waybar.enable = false;
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
}
