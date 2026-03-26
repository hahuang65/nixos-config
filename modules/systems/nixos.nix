{ self, inputs, ... }: {
  flake.nixosModules.nixos = { pkgs, lib, ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "1password"
      "1password-cli"
      "claude-code"
      "ferdium"
      "obsidian"
      "plex-desktop"
      "plexamp"
      "slack"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "vivaldi"
    ];

    programs.nix-ld.enable = true;

    networking.networkmanager.enable = true;
    services.upower.enable = true;
    services.power-profiles-daemon.enable = lib.mkDefault true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = "matrix";
        bigclock = "en";
        vi_mode = true;
        vi_default_mode = "insert";
        blank_box = true;
        hide_key_hints = false;
        load = true;
        save = true;
        clear_password = false;
      };
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
