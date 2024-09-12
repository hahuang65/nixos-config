{ ... }:
{
  imports = [
    ./bootloader.nix
    ./font.nix
    ./host.nix
    ./just.nix
    ./locale.nix
    ./networking.nix
    ./shell.nix
  ];

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
