{ self, inputs, ... }: {
  flake.homeModules.terminal = { pkgs, ... }: {
    home.packages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.wezterm
    ];

    xdg.configFile."wezterm" = {
      source = ./terminal;
      recursive = true;
    };
  };

  perSystem = { pkgs, lib, ... }: {
    packages.wezterm = pkgs.symlinkJoin {
      name = "wezterm-wrapped";
      paths = [ pkgs.wezterm ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/wezterm \
          --set WEZTERM_CONFIG_DIR "${./terminal}"
      '';
    };
  };
}
