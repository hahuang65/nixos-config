{ lib, ... }:

let
  inherit (lib) mkDefault;
in {
  imports = [
    ./bash.nix
    ./foot.nix
    ./keychain.nix
    ./sway.nix
  ];
  
  bash.enable = mkDefault true;
  foot.enable = mkDefault true;

  keychain = {
    enable = mkDefault true;
    keys = mkDefault [ "id_ed25519" ];
  };

  sway.enable = mkDefault true;
}