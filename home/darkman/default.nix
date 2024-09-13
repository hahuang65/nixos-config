{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    darkman = {
      enable = mkEnableOption "darkman";
    };
  };
  
  config = mkIf config.darkman.enable {
    services.darkman = {
      enable = true;
      settings = {
	# FIXME: Make these options
        lat = 30.116866421141836;
        lng = -95.35681905950295;
        usegeoclue = false; # Requires nixpkgs/option/services.geoclue2.enable, maybe find a way to integrate with host/common/optional?
      };
    };
  };
}
