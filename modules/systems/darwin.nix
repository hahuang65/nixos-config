{ self, inputs, ... }: {
  flake.darwinModules.darwin = { pkgs, lib, ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowBroken = false;
    nixpkgs.config.problems.handlers."nss_wrapper".broken = "warn";
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "1password"
      "1password-cli"
      "claude-code"
      "obsidian"
      "slack"
    ];

    system.primaryUser = "hhhuang";
    system.stateVersion = 6;
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
