{ self, inputs, ... }: {
  flake.nixosModules.bluetooth = { pkgs, ... }: {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    environment.systemPackages = [ pkgs.blueberry ];
  };
}
