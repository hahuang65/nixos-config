{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    mise = {
      enable = mkEnableOption "mise";
      asdfShimEnable = mkEnableOption "asdfShim";
    };
  };
  
  config = mkIf config.mise.enable {
    programs.mise.enable = true;

    home.file.".default-gems".source = ./default-ruby-gems;
    home.file.".default-go-packages".source = ./default-go-packages;
    home.file.".default-npm-packages".source = ./default-npm-packages;
    home.file.".default-python-packages".source = ./default-python-packages;

    home.file.".local/bin/asdf" = mkIf config.mise.asdfShimEnable {
      source = ./asdf;
    };
  };
}