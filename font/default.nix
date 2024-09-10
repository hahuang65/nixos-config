{ pkgs ? import <nixpkgs> {} }:

let
  fonts = pkgs.stdenvNoCC.mkDerivation {
    pname = "customFonts";
    version = "1.0.0";
    src = ./custom;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fonts/
      cp -R opentype $out/share/fonts/
      cp -R truetype $out/share/fonts/
      runHook postInstall
    '';

    meta = {
      description = "All custom fonts";
    };
  };
in
{
  inherit fonts;
  
  xdg.configFile."fontconfig/noto-emoji.conf".source = "./custom/truetype/Noto Color Emoji/noto-emoji.conf";
}

