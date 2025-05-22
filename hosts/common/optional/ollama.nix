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
    ollama = {
      enable = mkEnableOption "ollama";

      models = mkOption {
        type = types.listOf types.str;
        description = "List of preloaded models, see https://ollama.com/library";
      };
    };

  };

  config = mkIf config.ollama.enable {
    services.ollama = {
      enable = true;
      acceleration = "rocm";
      loadModels = config.ollama.models;
    };
  };
}
