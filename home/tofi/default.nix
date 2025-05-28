{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (pkgs) stdenv;
in
{
  options = {
    tofi = {
      enable = mkEnableOption "tofi";
    };
  };

  config = mkIf (stdenv.isLinux && config.tofi.enable) {
    home.packages = [
      (import ./scripts/kill.nix { inherit pkgs; })
      (import ./scripts/power.nix { inherit pkgs; })
      (import ./scripts/srun.nix { inherit pkgs; })
    ];

    programs.tofi = {
      enable = true;
      settings = {
        width = "100%";
        height = "100%";
        border-width = 0;
        outline-width = 0;
        padding-left = "45%";
        padding-top = "35%";
        result-spacing = 25;
        num-results = 8;
        font = config.stylix.fonts.monospace.name;
        input-color = mkForce config.lib.stylix.colors.base05;
        text-color = mkForce config.lib.stylix.colors.base03;
        selection-color = mkForce config.lib.stylix.colors.base09;
        selection-match-color = mkForce config.lib.stylix.colors.base08;
      };
    };
  };

}
