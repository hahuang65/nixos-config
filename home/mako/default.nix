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
    mako = {
      enable = mkEnableOption "mako";
    };
  };

  config = mkIf config.mako.enable {
    home.packages = with pkgs; [
      libnotify
      (import ./scripts/test.nix { inherit pkgs; })
    ];

    services.mako = {
      enable = true;

      borderSize = 2;
      height = 300;
      width = 600;

      extraConfig = ''
        [urgency=low]
        default-timeout=5000

        [urgency=normal]
        default-timeout=5000

        [urgency=high]
        default-timeout=15000
        border-color=#${config.lib.stylix.colors.base09}
        text-color=#${config.lib.stylix.colors.base08}
      '';
    };
  };
}
