{ config, configLib, ... }:

{
  imports = (
    map configLib.fromRoot [
      "hosts/common/darwin/core"
      "hosts/common/darwin/optional"

      "users/hhhuang"
    ]
  );

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.settings.trusted-users = [ config.users.users.hhhuang.name ];
  system.defaults.loginwindow.autoLoginUser = config.users.users.hhhuang.name;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
