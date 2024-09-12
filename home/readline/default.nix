{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    readline = {
      enable = mkEnableOption "readline";
    };
  };
  
  config = mkIf config.readline.enable {
    programs.readline = {
      enable = true;
      bindings = {
        "\\C-p" = "history-search-backward";
        "\\C-n" = "history-search-forward";
      };
      variables = {
        editing-mode = "vi";
        colored-stats = true;
        completion-ignore-case = true;
        completion-map-case = true;
        completion-prefix-display-length = 3;
        mark-symlinked-directories = true;
        show-all-if-ambiguous = true;
        show-all-if-unmodified = true;
        visible-stats = true;
      };
    };
  };
}
