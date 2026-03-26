{ self, inputs, ... }: {
  flake.nixosModules.user-hao = { pkgs, ... }: {
    users.users.hao = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      shell = pkgs.bash;
    };
  };

  flake.darwinModules.user-hao = { pkgs, ... }: {
    users.users.hhhuang = {
      shell = pkgs.bash;
      home = "/Users/hhhuang";
    };
  };
}
