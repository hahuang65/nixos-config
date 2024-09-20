{ configLib, lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  news.display = "silent";

  imports = (configLib.scanPaths ./.);

  bash.enable = mkDefault true;
  bat.enable = mkDefault true;
  bluetooth.enable = mkDefault false;
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
  mise.enable = mkDefault true;
  neovim.enable = mkDefault true;
  readline.enable = mkDefault true;
  senpai.enable = mkDefault true;
  sway.enable = mkDefault true;
  thunderbird.enable = mkDefault true;
  wezterm.enable = mkDefault true;

  stylix = {
    targets = {
      neovim.enable = false;
      waybar.enable = false;
    };
  };
}
