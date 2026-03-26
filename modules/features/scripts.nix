{ self, inputs, ... }: {
  flake.homeModules.scripts = { pkgs, lib, config, ... }: {
    home.sessionPath = [
      "${config.xdg.configHome}/scripts/shared"
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      "${config.xdg.configHome}/scripts/linux"
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      "${config.xdg.configHome}/scripts/darwin"
    ];

    xdg.configFile."scripts" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
