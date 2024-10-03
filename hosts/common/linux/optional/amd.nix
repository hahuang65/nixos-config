{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    amdGPU = {
      enable = mkEnableOption "amdGPU";
    };
  };

  config = mkIf config.amdGPU.enable {
    boot.initrd.kernelModules = [ "amdgpu" ];

    # Enable OpenGL
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    hardware.opengl.extraPackages = with pkgs; [ amdvlk ];

    # For 32 bit applications 
    hardware.opengl.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };
}
