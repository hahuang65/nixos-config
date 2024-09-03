{ configLib, ... }:
{
<<<<<<< HEAD
  imports = [
    ./1password.nix
    ./pipewire.nix
    ./printing.nix
    ./sway.nix
    ./touchpad.nix
  ];
=======
  imports = (configLib.scanPaths ./.)
>>>>>>> 44ffca9 (WIP)
}
