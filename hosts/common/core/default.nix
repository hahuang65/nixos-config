{ configLib, pkgs, ... }:
{
  imports = (configLib.scanPaths ./.);

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gnumake
    just
    nix-bundle
    openssh
    vim
    wget
  ];
}
