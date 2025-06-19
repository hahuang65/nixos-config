{ config, configLib, ... }:

{
  imports =
    [ ./hardware-configuration.nix ]
    ++ (map configLib.fromRoot [
      "hosts/common/linux/core"
      "hosts/common/linux/optional"

      "users/hao"
    ]);

  _1password = {
    enable = true;
    users = [ config.users.users.hao.name ];
  };

  location.enable = true;

  podman = {
    enable = true;
    users = [ config.users.users.hao.name ];
  };

  printing.enable = true;
  pipewire.enable = true;

  sway = {
    enable = true;
    users = [ config.users.users.hao.name ];
  };

  thunar.enable = true;
  vpn.enable = true;

  # TRIM support
  fileSystems."/".options = [
    "noatime"
    "nodiratime"
    "discard"
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
