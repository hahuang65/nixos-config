{

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {

    nixosConfigurations = {
      endor = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/endor/configuration.nix
        ];
      };
    };

    homeConfigurations = {
      hao = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        specialArgs = { inherit inputs outputs; };
        modules = [ ./home.nix ];
      };
    };
  };  

}
