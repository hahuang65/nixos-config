{ lib, ... }:

let
  inherit (lib) mkDefault;
in {
  imports = [
    ./bash
    ./bat
    ./customFonts
    ./direnv
    ./firefox
    ./foot
    ./fuzzel
    ./git
    ./keychain
    ./mako
    ./mise
    ./readline
    ./sway
    ./wezterm
  ];
  
  bash.enable = mkDefault true;
  bat.enable = mkDefault true;
  customFonts.enable = mkDefault true;
  direnv.enable = mkDefault true;
  firefox.enable = mkDefault true;
  foot.enable = mkDefault true;
  fuzzel.enable = mkDefault true;
  git.enable = mkDefault true;

  keychain = {
    enable = mkDefault false;
    keys = mkDefault [ "id_ed25519" ];
  };

  mako.enable = mkDefault true;
  mise.enable = mkDefault true;
  readline.enable = mkDefault true;
  sway.enable = mkDefault true;
  wezterm.enable = mkDefault true;
}
