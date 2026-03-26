{ self, inputs, ... }: {
  flake.homeModules.shell = { pkgs, config, ... }: {
    programs.bash = {
      enable = true;
      historyFile = "${config.home.homeDirectory}/.bash_history";
      historyFileSize = 500000;
      historySize = 500000;
      historyControl = [ "erasedups" "ignorespace" ];

      initExtra = ''
        source "${config.xdg.configHome}/bash/bashrc"
      '';
    };

    xdg.configFile."bash" = {
      source = ./shell;
      recursive = true;
    };

    home.packages = with pkgs; [
      fzf
      starship
    ];
  };
}
