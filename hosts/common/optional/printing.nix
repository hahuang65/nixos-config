{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    printing = {
      enable = mkEnableOption "printing";
    };
  };

  config = mkIf config.printing.enable {
   # Enable CUPS to print documents.
   services.printing.enable = true;
  };
}
