{ lib, ... }:

let
  inherit (lib) mkDefault;
in {
  imports = [
    ./1password.nix
  ];
  
  _1password.enable = mkDefault false;
}
