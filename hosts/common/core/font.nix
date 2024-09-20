{ configLib, pkgs, ... }:

let
  customFonts = import (configLib.fromRoot "modules/fonts") { inherit pkgs; };
in
{
  fonts.packages = [ customFonts.fonts ];
}
