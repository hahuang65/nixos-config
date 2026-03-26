{ self, ... }: {
  flake.nixosModules.vm-hardware = { ... }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
  };
}
