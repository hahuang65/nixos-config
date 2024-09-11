{ configLib, ... }:
{
  imports = [
    ./1password.nix
    ./pipewire.nix
    ./printing.nix
    ./sway.nix
    ./thunar.nix
    ./touchpad.nix
  ];
}
