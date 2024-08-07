{

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
    nixosConfigurations = {
      kamino = lib.nixosSystem {
	inherit system;
        modules = [ ./configuration.nix ];
      };
    };
    homeConfigurations = {
      hao = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
  };  

}
