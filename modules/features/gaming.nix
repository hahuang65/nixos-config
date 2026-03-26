{ self, inputs, ... }: {
  flake.nixosModules.gaming = { pkgs, ... }: {
    programs.steam.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      wowup-cf
    ];
  };
}
