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
      "widevine-cdm"
    ];

    # Locale and timezone
    time.timeZone = "America/Chicago";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Console keyboard
    console.keyMap = "us";

    # Security
    security.polkit.enable = true;
    security.rtkit.enable = true;

    # XDG portal for screen sharing, file dialogs, etc.
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

    # GNOME Keyring
    services.gnome.gnome-keyring.enable = true;

    networking.networkmanager.enable = true;
    services.upower.enable = true;
    services.power-profiles-daemon.enable = lib.mkDefault true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
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
