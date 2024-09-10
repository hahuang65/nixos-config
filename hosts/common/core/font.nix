{ pkgs,... }:

let
  customFonts = import ../../../font { inherit pkgs; };
in {
  fonts.packages = [ customFonts.fonts ];
}
