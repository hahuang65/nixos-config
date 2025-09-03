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
    streamDeck = {
      enable = mkEnableOption "streamDeck";
    };
  };

  config = mkIf config.streamDeck.enable {
    programs.streamcontroller.enable = true;
    environment.systemPackages = with pkgs; [
      streamcontroller
    ];
  };
}
