{ self, inputs, ... }: {
  flake.homeModules.ssh = { pkgs, ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
  };
}
