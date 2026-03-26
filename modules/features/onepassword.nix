{ self, inputs, ... }: {
  flake.nixosModules.onepassword = { pkgs, lib, ... }: {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "hao" ];
    };
  };

  flake.homeModules.onepassword = { pkgs, lib, ... }: lib.mkIf pkgs.stdenv.isLinux {
    systemd.user.services.onepassword = {
      Unit.Description = "1Password";
      Unit.After = [ "graphical-session.target" ];
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${lib.getExe pkgs._1password-gui} --silent";
        Restart = "on-failure";
      };
    };
  };
}
