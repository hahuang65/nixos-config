{ self, inputs, ... }: {
  flake.nixosModules.home = { pkgs, ... }: {
    imports = [
      self.nixosModules.user-hao
      self.nixosModules.onepassword
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.hao = { ... }: {
        imports = builtins.attrValues (self.homeModules or {})
          ++ [ inputs.sops-nix.homeManagerModules.sops ];
        home.stateVersion = "25.05";
      };
    };
  };

  flake.darwinModules.home = { pkgs, ... }: {
    imports = [ self.darwinModules.user-hao ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.hhhuang = { ... }: {
        imports = builtins.attrValues (self.homeModules or {})
          ++ [ inputs.sops-nix.homeManagerModules.sops ];
        home.stateVersion = "25.05";
      };
    };
  };
}
