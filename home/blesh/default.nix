{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  blesh-latest = pkgs.stdenv.mkDerivation rec {
    pname = "ble.sh";
    version = "nightly";

    src = pkgs.fetchurl {
      url = "https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz";
      sha256 = "sha256-0FJrZwusOmXjapzrvsZGplwchIbRMepN5n/ODlFBw7U=";
    };

    buildInputs = with pkgs; [ bash ];

    unpackPhase = ''
      tar xJf $src
    '';

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/share/blesh
      cp -r ble-nightly/* $out/share/blesh/

      # Make sure ble.sh is executable
      chmod +x $out/share/blesh/ble.sh
    '';

    meta = with lib; {
      description = "Bash Line Editor - A full-featured line editor written in pure Bash (nightly)";
      homepage = "https://github.com/akinomyoga/ble.sh";
      license = licenses.bsd3;
      platforms = platforms.unix;
    };
  };
in
{
  options = {
    blesh = {
      enable = mkEnableOption "blesh";
    };
  };

  config = mkIf config.blesh.enable {
    home.packages = [
      blesh-latest
    ];
    programs.bash = {
      enable = true;
      initExtra = ''
        source ${blesh-latest}/share/blesh/ble.sh
        bleopt color_scheme=catppuccin_mocha
      '';
    };
  };
}
