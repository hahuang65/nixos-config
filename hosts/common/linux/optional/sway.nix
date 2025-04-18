{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options = {
    sway = {
      enable = mkEnableOption "sway";

      users = mkOption {
        type = types.listOf types.str;
        description = "Users allowed to use sway";
      };
    };
  };

  config = mkIf config.sway.enable {
    # https://github.com/fpletz/flake/blob/c7136ebb1fa45138ced05b122a185faf9ef812c5/pkgs/default.nix#L28-L55
    nixpkgs.overlays = [
      (final: prev: {
        sway-unwrapped = prev.sway-unwrapped.overrideAttrs (attrs: {
          version = "0-unstable-2024-08-11";
          src = final.fetchFromGitHub {
            owner = "swaywm";
            repo = "sway";
            rev = "b44015578a3d53cdd9436850202d4405696c1f52";
            hash = "sha256-gTsZWtvyEMMgR4vj7Ef+nb+wcXkwGivGfnhnBIfPHOA=";
          };
          buildInputs = attrs.buildInputs ++ [ final.wlroots ];
          mesonFlags =
            let
              inherit (lib.strings) mesonEnable mesonOption;
            in
            [
              (mesonOption "sd-bus-provider" "libsystemd")
              (mesonEnable "tray" attrs.trayEnabled)
            ];
        });
        wlroots = prev.wlroots.overrideAttrs (_attrs: {
          version = "0-unstable-2024-08-11";
          src = final.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "wlroots";
            repo = "wlroots";
            rev = "6214144735b6b85fa1e191be3afe33d6bea0faee";
            hash = "sha256-nuG2xXLDFsGh23CnhaTtdOshCBN/yILqKCSmqJ53vgI=";
          };
        });
      })
    ];

    hardware.graphics = {
      enable = true;
      extraPackages = [ pkgs.vulkan-validation-layers ];
    };

    # Default to Wayland wherever possible https://nixos.wiki/wiki/Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    security.polkit.enable = true;
    security.pam.services.swaylock = { };

    services.gnome.gnome-keyring.enable = true;

    programs.sway.extraSessionCommands = ''
      export WLR_RENDERER=vulkan
    '';

    users.groups.video.members = config.sway.users;
  };
}
