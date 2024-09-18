{ pkgs, ... }:

let
  customFonts = import ../../../modules/fonts { inherit pkgs; };
in
{
  fonts.packages = [ customFonts.fonts ];
}
