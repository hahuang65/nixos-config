{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  news.display = "silent";

  imports = [
    ./bash
    ./bat
    ./darkman
    ./direnv
    ./firefox
    ./fonts
    ./foot
    ./fuzzel
    ./fzf
    ./git
    ./keychain
    ./mako
    ./mise
    ./neovim
    ./readline
    ./styles
    ./sway
    ./wezterm
  ];

  bash.enable = mkDefault true;
  bat.enable = mkDefault true;
  fonts.enable = mkDefault true;
  darkman.enable = mkDefault true;
  direnv.enable = mkDefault true;
  firefox.enable = mkDefault true;
  foot.enable = mkDefault true;
  fuzzel.enable = mkDefault true;
  fzf.enable = mkDefault true;
  git.enable = mkDefault true;

  keychain = {
    enable = mkDefault false;
    keys = mkDefault [ "id_ed25519" ];
  };

  mako.enable = mkDefault true;
  mise.enable = mkDefault true;
  neovim.enable = mkDefault true;
  readline.enable = mkDefault true;

  style = {
    cursor.size = 36;
    font.style.sansSerif = "General Sans";
    font.size = {
      desktop = 18;
      popup = 18;
    };
    wallpaper = "unicat.png";
  };

  sway.enable = mkDefault true;
  wezterm.enable = mkDefault true;
}
