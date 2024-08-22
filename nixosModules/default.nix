{ lib, ... }:

let
  inherit (lib) mkDefault;
in {
  imports = [
    ./1password.nix
    ./sway.nix
  ];
  
  _1password.enable = mkDefault false;
  sway.enable = mkDefault false;
}
