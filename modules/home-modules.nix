{ lib, ... }: {
  options.flake = {
    homeModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      description = "Home-manager modules, merged across all feature files.";
    };

    darwinModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      description = "nix-darwin modules, merged across all feature files.";
    };
  };
}
