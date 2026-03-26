{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
      brightnessctl
      playerctl
    ];
  };

  perSystem = { pkgs, lib, self', system, ... }: lib.optionalAttrs (lib.hasSuffix "linux" system) {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        prefer-no-csd = null;

        input = {
          keyboard.xkb = {
            layout = "us";
            options = "ctrl:nocaps";
          };

          touchpad = {
            tap = null;
            dwt = null;
            natural-scroll = null;
            click-method = "clickfinger";
            scroll-method = "two-finger";
          };
        };

        # Catppuccin Mocha colors for borders
        layout = {
          gaps = 5;
          border = {
            width = 3;
            active-color = "#cba6f7";   # mauve
            inactive-color = "#313244"; # surface0
          };
          focus-ring.off = null;
        };

        spawn-at-startup = [
          (lib.getExe self'.packages.noctalia)
        ];

        # Named workspaces
        workspaces = {
          "web" = null;
          "chat" = null;
          "media" = null;
          "game" = null;
          "code" = null;
        };

        binds = {
          # Terminal (Shift+Return like sway)
          "Mod+Shift+Return".spawn = lib.getExe pkgs.wezterm;

          # Editor (Return like sway)
          "Mod+Return".spawn-sh = "${lib.getExe pkgs.wezterm} start -- bash -l -c nvim";

          # Kill focused window
          "Mod+Q".close-window = null;

          # Launcher (noctalia)
          "Mod+Space".spawn-sh = "${lib.getExe self'.packages.noctalia} ipc call launcher toggle";

          # 1Password quick access
          "Ctrl+Shift+P".spawn-sh = "1password --quick-access --ozone-platform-hint=auto";

          # Fullscreen
          "Mod+Z".fullscreen-window = null;

          # Maximize column (closest sway equivalent)
          "Mod+F".maximize-column = null;

          # Toggle floating
          "Mod+Shift+F".toggle-window-floating = null;

          # Center column
          "Mod+C".center-column = null;

          # Focus navigation (hjkl like sway)
          "Mod+H".focus-column-left = null;
          "Mod+J".focus-window-down = null;
          "Mod+K".focus-window-up = null;
          "Mod+L".focus-column-right = null;

          # Move windows (Shift+hjkl like sway)
          "Mod+Shift+H".move-column-left = null;
          "Mod+Shift+J".move-window-down = null;
          "Mod+Shift+K".move-window-up = null;
          "Mod+Shift+L".move-column-right = null;

          # Resize (Ctrl+hjkl)
          "Mod+Ctrl+H".set-column-width = "-5%";
          "Mod+Ctrl+L".set-column-width = "+5%";
          "Mod+Ctrl+J".set-window-height = "-5%";
          "Mod+Ctrl+K".set-window-height = "+5%";

          # Workspaces (same numbers as sway)
          "Mod+1".focus-workspace = "web";
          "Mod+2".focus-workspace = "chat";
          "Mod+3".focus-workspace = "media";
          "Mod+4".focus-workspace = "game";
          "Mod+0".focus-workspace = "code";

          # Move to workspace
          "Mod+Shift+1".move-column-to-workspace = "web";
          "Mod+Shift+2".move-column-to-workspace = "chat";
          "Mod+Shift+3".move-column-to-workspace = "media";
          "Mod+Shift+4".move-column-to-workspace = "game";
          "Mod+Shift+0".move-column-to-workspace = "code";

          # Scroll between columns/workspaces
          "Mod+WheelScrollDown".focus-column-right = null;
          "Mod+WheelScrollUp".focus-column-left = null;
          "Mod+Ctrl+WheelScrollDown".focus-workspace-down = null;
          "Mod+Ctrl+WheelScrollUp".focus-workspace-up = null;

          # Media keys
          "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioPlay".spawn-sh = "playerctl play-pause";
          "XF86AudioNext".spawn-sh = "playerctl next";
          "XF86AudioPrev".spawn-sh = "playerctl previous";

          # Brightness
          "XF86MonBrightnessUp".spawn-sh = "brightnessctl set +5%";
          "XF86MonBrightnessDown".spawn-sh = "brightnessctl set 5%-";

          # Screenshots (grim/slurp like sway)
          "Ctrl+Shift+4".spawn = [
            (lib.getExe (pkgs.writeShellApplication {
              name = "screenshot-region";
              runtimeInputs = [ pkgs.grim pkgs.slurp ];
              text = ''
                mkdir -p "$HOME/Pictures/Screenshots"
                grim -g "$(slurp)" "$HOME/Pictures/Screenshots/$(date +'grim_%m_%d_%y-%H_%M_%S.png')"
              '';
            }))
          ];

          # Lock (noctalia)
          "Mod+Shift+Space".spawn-sh = "${lib.getExe self'.packages.noctalia} ipc call lockScreen lock";

          # Scratchpads (from sway config)
          "Mod+S".spawn-sh = "$HOME/.config/scripts/shared/scratchpad";
          "Mod+W".spawn-sh = "$HOME/.config/scripts/shared/notepad";
        };

        # Window rules (floating apps from sway)
        window-rules = [
          {
            matches = [{ app-id = "1Password"; }];
            open-floating = true;
          }
          {
            matches = [{ app-id = "thunar"; }];
            open-floating = true;
          }
          {
            matches = [{ app-id = "pavucontrol"; }];
            open-floating = true;
          }
          {
            matches = [{ app-id = "nm-connection-editor"; }];
            open-floating = true;
          }
          {
            matches = [{ app-id = "org.kde.polkit-kde-authentication-agent-1"; }];
            open-floating = true;
          }
        ];
      };
    };
  };
}
