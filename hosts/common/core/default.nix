<<<<<<< HEAD
{ ... }:
{
  imports = [
    ./bootloader.nix
    ./host.nix
    ./locale.nix
    ./networking.nix
    ./shell.nix
  ];
=======
{ configLib, ... }:
{
  imports = (configLib.scanPaths ./.)
>>>>>>> 44ffca9 (WIP)

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
