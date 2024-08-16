args@{...}:

{
  imports =
    [ # Include the results of the hardware scan.
      ../../nixosModules/host.nix
      ./hardware-configuration.nix
    ];

  host.name = "endor";
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hao = {
    isNormalUser = true;
    home = "/home/hao";
    description = "Howard Huang";
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
