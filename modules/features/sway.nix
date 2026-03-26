{ self, inputs, ... }: {
  flake.nixosModules.sway = { pkgs, ... }: {
    programs.sway = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      waybar
      fuzzel
      mako
    ];
  };
}
