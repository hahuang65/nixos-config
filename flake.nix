{

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      url = "git+ssh://git@github.com/hahuang65/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    nix-citizen.url = "github:LovingMelody/nix-citizen";
    # Optional - updates underlying without waiting for nix-citizen to update
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      stylix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable { inherit system; };

      inherit (nixpkgs) lib;
      configLib = import ./lib { inherit lib; };

      specialArgs = {
        inherit
          inputs
          outputs
          configLib
          nixpkgs
          unstable
          ;
      };

      commonModules = name: [
        {
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          networking.hostName = name;
        }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = specialArgs;
            sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
          };
        }
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        ./hosts/${name}
      ];

      mkHost =
        name: cfg:
        nixpkgs.lib.nixosSystem {
          system = cfg.system or "x86_64-linux";
          modules = (commonModules name) ++ (cfg.extraModules or [ ]);
          inherit specialArgs;
        };

      hosts = {
        bespin = {
          extraModules = [ ];
        };
        endor = {
          extraModules = [ ];
        };
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkHost hosts;
    };
}
