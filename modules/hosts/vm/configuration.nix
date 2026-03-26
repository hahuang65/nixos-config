{ self, inputs, ... }: {
  flake.nixosModules.vm-configuration = { pkgs, lib, config, ... }: {
    imports = [
      self.nixosModules.vm-hardware
      self.nixosModules.desktop
    ];

    networking.hostName = "vm";
    system.stateVersion = "25.05";

    virtualisation.vmVariant = {
      virtualisation = {
        memorySize = 4096;
        cores = 4;
        graphics = true;
        qemu.options = [
          "-device virtio-vga"
          "-display gtk"
        ];
      };

      # Disable ly for VM, use auto-login instead
      services.displayManager.ly.enable = lib.mkForce false;
      services.getty.autologinUser = "hao";
    };
  };
}
