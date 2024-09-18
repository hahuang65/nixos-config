{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    fzf = {
      enable = mkEnableOption "fzf";
    };
  };

  config = mkIf config.fzf.enable {
    programs.fzf = {
      enable = true;

      fileWidgetOptions = [
        "--preview 'bat -n --color=always {}'"
        "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
      ];

      historyWidgetOptions = [
        "--preview 'echo {}' --preview-window up:3:hidden:wrap"
        "--bind 'ctrl-/:toggle-preview'"
        "--color header:italic"
      ];

      changeDirWidgetOptions = [ "--preview 'tree -C {}'" ];
    };
  };
}
