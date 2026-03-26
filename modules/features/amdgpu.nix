{ self, inputs, ... }: {
  flake.nixosModules.amdgpu = { pkgs, ... }: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
