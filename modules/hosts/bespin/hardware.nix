{ self, ... }: {
  flake.nixosModules.bespin-hardware = { ... }: {
    # Replace with output of `nixos-generate-config --show-hardware-config`
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

    hardware.cpu.intel.updateMicrocode = true;
  };
}
