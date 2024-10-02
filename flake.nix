{

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-24.05";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      url = "git+ssh://git@github.com/hahuang65/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    {
      self,
      home-manager,
      home-manager-darwin,
      nix-darwin,
      nixpkgs,
      nixpkgs-darwin,
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

      specialArgsDarwin = {
        nixpkgs = import nixpkgs-darwin { inherit system; };
        inherit
          inputs
          outputs
          configLib
          unstable
          ;
      };

      commonModules = name: [
        {
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
        }
        ./hosts/${name}
      ];

      linuxModules = name: commonModules name ++ [
        {
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
      ];

      darwinModules = name: commonModules name ++ [
        {
          networking.computerName = name;
          networking.hostName = name;
          networking.localHostName = name;
          system.defaults.smb.NetBIOSName = name;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
        }

	home-manager-darwin.darwinModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = specialArgsDarwin;
            sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
          };
        }
        stylix.darwinModules.stylix
      ];

      mkLinuxHost =
        name: cfg:
        nixpkgs.lib.nixosSystem {
          system = cfg.system or "x86_64-linux";
          modules = (linuxModules name) ++ (cfg.extraModules or [ ]);
          inherit specialArgs;
        };

      mkDarwinHost =
        name: cfg:
        nix-darwin.lib.darwinSystem {
          system = cfg.system or "aarch64-darwin";
          modules = (darwinModules name) ++ (cfg.extraModules or [ ]);
          specialArgs = specialArgsDarwin;
        };

      linuxHosts = {
        bespin = {
          extraModules = [ ];
        };
        endor = {
          extraModules = [ ];
        };
      };

      darwinHosts = {
        "6649L06" = {
          extraModules = [ ];
        };
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkLinuxHost linuxHosts;
      
      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwinHost darwinHosts;
    };
}
