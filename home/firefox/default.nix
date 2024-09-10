{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  lock-false = {
    Value = false;
    Status = "locked";
  };

  lock-true = {
    Value = true;
    Status = "locked";
  };
in {
  options = {
    firefox = {
      enable = mkEnableOption "firefox";
    };
  };
  
  config = mkIf config.firefox.enable {
    programs.firefox = {
      enable = true;
      nativeMessagingHosts = [ pkgs.tridactyl-native ];
      policies = {
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;

          Cryptomining = true;
          Fingerprinting = true;
        };
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";

        # See about:support for extension ID strings
        ExtensionSettings = {
          "*".installation_mode = "blocked";

          # 1Password
          "{d634138d-c276-4fc8-924b-40a0ea21d284" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password_x_password_manager/latest.xpi";
            installation_mode = "force_installed";
          };

          # Catppuccin Mauve
          "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin_mocha_mauve_git/latest.xpi";
            installation_mode = "force_installed";
          };

          # Raindrop
          "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/raindropio/latest.xpi";
            installation_mode = "force_installed";
          };

          # Tree Style Tab
          "treestyletab@piro.sakura.ne.jp" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree_style_tab/latest.xpi";
            installation_mode = "force_installed";
          };

          # Tridactyl
          "tridactyl.vim@cmcaine.co.uk" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl_vim/latest.xpi";
            installation_mode = "force_installed";
          };

          # uBlock
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
        };

	# See about:config for options
        Preferences = {
          "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
          "browser.newtabpage.activity-stream.feeds.section.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.highlights.includeDownloads" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.highlights.includeVisited" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.topsites.contile.enabled" = lock-false;
          "extensions.pocket.enabled" = lock-false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "widget.use-xdg-desktop-portal.file-picker" = 1;
	}; 
      };
      profiles = {
        profile_0 = {
          id = 0;
          isDefault = true;
          name = "profile_0";

          settings = {
	    "browser.search.suggest.enabled.private" = lock-false;
	    "browser.sessionstore.enabled" = lock-true;
	    "browser.sessionstore.resume_from_crash" = lock-true;
	    "browser.sessionstore.resume_session_once" = lock-true;
	    "browser.tabs.drawInTitlebar" = lock-true;
	    "browser.tabs.tabmanager.enabled" = lock-false;
	    "browser.urlbar.suggest.addons" = lock-false;
	    "browser.urlbar.suggest.pocket" = lock-false;
	    "browser.urlbar.suggest.topsites" = lock-false;
	    "general.smoothScroll" = lock-true;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
            "browser.startup.homepage" = "about:blank";
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "widget.use-xdg-desktop-portal.mime-handler" = 1;
          };

          userChrome = builtins.readFile ./treeStyleTabs/userChrome.css;
        };
      };
    };
    
    home.sessionVariables = {
      MOZ_USE_XINPUT2 = "1"; # Improves touchscreen/touchpad, and smoothscroll
    };

    xdg.configFile."tridactyl/tridactylrc".source = ./tridactyl/tridactylrc;
    xdg.configFile."tridactyl/themes/catppuccin.css".source = ./tridactyl/catppuccin.css;
  };
}
