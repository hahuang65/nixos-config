{ configLib, ... }:
{
  imports = (configLib.scanPaths ./.) ++ [ ]; # Any other imports go in here

  # Enable Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
