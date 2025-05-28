{
  xdg.desktopEntries = {
    # Add these by matching the name of the .desktop file to the key
    # Desktop files can be found in:
    # `~/.nix-profile/share/applications/`
    # `/run/current-system/sw/share/applications/`

    # FIXME: Cannot just set name, it leaves all other fields empty
    # chiaking = {
    #   name = "Chiaki";
    # };

    cups = {
      name = "cups";
      noDisplay = true;
    };

    darkman = {
      name = "darkman";
      noDisplay = true;
    };

    footclient = {
      name = "footclient";
      noDisplay = true;
    };

    foot-server = {
      name = "foot-server";
      noDisplay = true;
    };

    geoclue-demo-agent = {
      name = "geoclue-demo-agent";
      noDisplay = true;
    };

    geoclue-where-am-i = {
      name = "geoclue-where-am-i";
      noDisplay = true;
    };

    gvim = {
      name = "gvim";
      noDisplay = true;
    };

    htop = {
      name = "htop";
      noDisplay = true;
    };

    kvantummanager = {
      name = "kvantummanager";
      noDisplay = true;
    };

    # FIXME: Cannot just set name, it leaves all other fields empty
    # mullvad-vpn = {
    #   name = "Mullvad";
    # };
    nixos-manual = {
      name = "nixos-manual";
      noDisplay = true;
    };

    nvim = {
      name = "nvim";
      noDisplay = true;
    };

    "org.freedesktop.Xwayland" = {
      name = "org.freedesktop.Xwayland";
      noDisplay = true;
    };

    "org.pwmt.zathura-cb" = {
      name = "org.pwmt-zathura-cb";
      noDisplay = true;
    };

    "org.pwmt.zathura-djvu" = {
      name = "org.pwmt-zathura-djvu";
      noDisplay = true;
    };

    "org.pwmt.zathura-pdf" = {
      name = "org.pwmt-zathura-pdf-mupdf";
      noDisplay = true;
    };

    "org.pwmt.zathura-ps" = {
      name = "org.pwmt-zathura-ps";
      noDisplay = true;
    };

    # FIXME: Cannot just set name, it leaves all other fields empty
    # protonup-qt = {
    #   name = "ProtonUp";
    # };

    qt5ct = {
      name = "qt5ct";
      noDisplay = true;
    };

    qt6ct = {
      name = "qt6ct";
      noDisplay = true;
    };

    # FIXME: Cannot just set name, it leaves all other fields empty
    # thunar = {
    #   name = "Thunar";
    # };

    thunar-bulk-rename = {
      name = "thunar-bulk-rename";
      noDisplay = true;
    };

    thunar-settings = {
      name = "thunar-settings";
      noDisplay = true;
    };

    thunar-volman-settings = {
      name = "thunar-volman-settings";
      noDisplay = true;
    };

    vim = {
      name = "vim";
      noDisplay = true;
    };

    xdg-desktop-portal-gtk = {
      name = "xdg-desktop-portal-gtk";
      noDisplay = true;
    };

    # FIXME: Cannot just set name, it leaves all other fields empty
    # xivlauncher = {
    #   name = "Final Fantasy XIV";
    # };
  };
}
