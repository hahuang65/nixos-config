{ self, inputs, ... }: {
  flake.darwinModules.darwin = { pkgs, ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    system.defaults = {
      dock.autohide = true;
      finder.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleShowAllExtensions = true;
    };

    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      age
      sops
      ssh-to-age
    ];
  };
}
