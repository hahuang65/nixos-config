{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption mkIf types;

  lock-false = {
    Value = false;
    Status = "locked";
  };

  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
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
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
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
          "browser.contentblocking.category" = {
            Value = "strict";
            Status = "locked";
          };
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
    xdg.configFile."tridactyl/themes/custom.css".text = ''
      :root {
        --bg: #${config.lib.stylix.colors.base00};
        --currentline: #${config.lib.stylix.colors.base02};
        --fg: #${config.lib.stylix.colors.base05};
        --comment: #${config.lib.stylix.colors.base03};
        --cyan: #${config.lib.stylix.colors.base0C};
        --green: #${config.lib.stylix.colors.base0B};
        --orange: #${config.lib.stylix.colors.base09};
        --pink: #${config.lib.stylix.colors.base0F};
        --purple: #${config.lib.stylix.colors.base07};
        --red: #${config.lib.stylix.colors.base08};
        --yellow: #${config.lib.stylix.colors.base0A};
        --font: "${config.stylix.fonts.sansSerif.name}";
        --fontsize: ${builtins.toString config.stylix.fonts.sizes.popups}pt;

        --tridactyl-fg: var(--fg);
        --tridactyl-bg: var(--bg);
        --tridactyl-url-fg: var(--pink);
        --tridactyl-url-bg: var(--bg);
        --tridactyl-highlight-box-bg: var(--currentline);
        --tridactyl-highlight-box-fg: var(--fg);
        --tridactyl-of-fg: var(--fg);
        --tridactyl-of-bg: var(--currentline);
        --tridactyl-cmdl-fg: var(--bg);
        --tridactyl-cmdl-font-family: var(--font);
        --tridactyl-cmplt-font-family: var(--font);
        --tridactyl-hintspan-font-family: var(--font);
        --tridactyl-hintspan-font-size: var(--fontsize);

        /* Hint character tags */
        --tridactyl-hintspan-fg: var(--bg) !important;
        --tridactyl-hintspan-bg: var(--pink) !important;

        /* Element Highlights */
        --tridactyl-hint-active-fg: none;
        --tridactyl-hint-active-bg: none;
        --tridactyl-hint-active-outline: none;
        --tridactyl-hint-bg: none;
        --tridactyl-hint-outline: none;
      }

      #command-line-holder {
        order: 1;
        border: 2px solid var(--purple);
        background: var(--tridactyl-bg);
      }

      #tridactyl-input {
        padding: 1rem;
        color: var(--tridactyl-fg);
        width: 90%;
        font-size: var(--fontsize);
        line-height: 1.5;
        background: var(--tridactyl-bg);
        padding-left: unset;
        padding: 1rem;
      }

      #completions table {
        font-size: var(--fontsize);
        font-weight: 200;
        border-spacing: 0;
        table-layout: fixed;
        padding: 1rem;
        padding-top: 0 !important;
        padding-bottom: 1rem;
      }

      #completions > div {
        max-height: calc(20 * var(--option-height));
        min-height: calc(10 * var(--option-height));
      }

      /* COMPLETIONS */

      #completions {
        --option-height: 1.4em;
        color: var(--tridactyl-fg);
        background: var(--tridactyl-bg);
        display: inline-block;
        font-size: unset;
        font-weight: 200;
        overflow: hidden;
        width: 100%;
        border-top: unset;
        order: 2;
      }

      /* Olie doesn't know how CSS inheritance works */
      #completions .HistoryCompletionSource {
        max-height: unset;
        min-height: unset;
      }

      #completions .HistoryCompletionSource table {
        width: 100%;
        font-size: var(--fontsize);
        border-spacing: 0;
        table-layout: fixed;
      }

      /* redundancy 2: redundancy 2: more redundancy */
      #completions .BmarkCompletionSource {
        max-height: unset;
        min-height: unset;
      }

      #completions table tr td.prefix,
      #completions table tr td.privatewindow,
      #completions table tr td.container,
      #completions table tr td.icon {
        display: none;
      }

      #completions .BufferCompletionSource table {
        width: unset;
        font-size: unset;
        border-spacing: unset;
        table-layout: unset;
      }

      #completions table tr .title {
        width: 50%;
      }

      #completions table tr {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      #completions .sectionHeader {
        background: unset;
        font-weight: bold;
        border-bottom: unset;
        padding: 1rem !important;
        padding-left: unset;
        padding-bottom: 0.2rem !important;
      }

      #cmdline_iframe {
        position: fixed !important;
        bottom: unset;
        top: 25% !important;
        left: 10% !important;
        z-index: 2147483647 !important;
        width: 80% !important;
        box-shadow: rgba(0, 0, 0, 0.5) 0px 0px 20px !important;
      }

      .TridactylStatusIndicator {
        position: fixed !important;
        bottom: 0 !important;
        background: var(--tridactyl-bg) !important;
        border: unset !important;
        border: 1px var(--purple) solid !important;
        font-size: 10pt !important;
        /*font-weight: 200 !important;*/
        padding: 0.8ex !important;
      }

      #completions .focused {
        background: var(--pink);
        color: var(--bg);
      }

      #completions .focused .url {
        background: var(--pink);
        color: var(--bg);
      }
    '';
  };
}
