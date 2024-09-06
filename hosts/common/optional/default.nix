{ configLib, ... }:
{
  imports = [
    ./1password.nix
    ./pipewire.nix
    ./printing.nix
    ./sway.nix
    ./touchpad.nix
  ];
}
