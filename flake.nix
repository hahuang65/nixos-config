{

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      stylix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
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
    in
    {

      nixosConfigurations = {
        endor = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/endor ];
        };

        bespin = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/bespin ];
        };
      };

      homeConfigurations = {
        hao = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = specialArgs;
          modules = [
            stylix.homeManagerModules.stylix
            ./users/hao.nix
          ];
        };
      };
    };

}
