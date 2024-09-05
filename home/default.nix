{ lib, ... }:

let
  inherit (lib) mkDefault;
in {
  imports = [
    ./bash
    ./bat
    ./direnv
    ./firefox
    ./foot
    ./fuzzel
    ./keychain
    ./sway
  ];
  
  bash.enable = mkDefault true;
  bat.enable = mkDefault true;
  direnv.enable = mkDefault true;
  firefox.enable = mkDefault true;
  foot.enable = mkDefault true;
  fuzzel.enable = mkDefault true;

  keychain = {
    enable = mkDefault true;
    keys = mkDefault [ "id_ed25519" ];
  };

  sway.enable = mkDefault true;
}
