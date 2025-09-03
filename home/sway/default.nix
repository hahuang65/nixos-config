{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) stdenv;

  docs = (import ./scripts/docs.nix { inherit pkgs; });
  notepad = (import ./scripts/notepad.nix { inherit pkgs; });
  scratchpad = (import ./scripts/scratchpad.nix { inherit pkgs; });
  sway-startup = (import ./scripts/start.nix { inherit pkgs; });
  waybar-media = (import ./scripts/media.nix { inherit pkgs; });
  mod = "Mod1";
  term = "wezterm";
  editor = "wezterm start -- bash -l -c $EDITOR";
  laptopMonitor = "eDP-1";
  launcher = "tofi-drun --drun-launch=true";
  scriptLauncher = "tofi-srun";
  lock = "swaylock --daemonize --indicator --screenshots --clock --effect-greyscale --effect-pixelate 5";
  lockWithGrace = "${lock} --grace 15";
in
{
  options = {
    sway = {
      enable = mkEnableOption "sway";
    };
  };

  config = mkIf (stdenv.isLinux && config.sway.enable) {
    home.packages = with pkgs; [
      brightnessctl
      grim
      playerctl
      slurp
      swaybg
      swayidle
      swaylock-effects
      wl-clipboard

      (import ./scripts/restart.nix { inherit pkgs; })
    ];

    home.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    wayland.windowManager.sway = {
      enable = true;
      checkConfig = false; # Otherwise it will error on the `output.*.bg` line.
      config = {
        assigns = {
          "1" = [
            { app_id = "firefox"; }
            { app_id = "vivaldi"; }
            { class = "Google-chrome"; }
          ];
          "2" = [
            { app_id = "thunderbird"; }
            { app_id = "org.squidowl.halloy"; }
            { class = "aerc"; }
            { class = "Ferdium"; }
            { class = "senpai"; }
            { class = "Slack"; }
          ];
          "3" = [
            { app_id = "mpv"; }
            { app_id = "tv.plex.Plex"; }
            { app_id = "spotify"; }
            { class = "Spotify"; }
            { class = "Plexamp"; }
          ];
        };

        bars = [ ]; # Disable swaybar

        focus = {
          followMouse = false;
          wrapping = "no";
        };

        gaps = {
          inner = 10;
          outer = 10;
        };

        input = {
          "type:keyboard" = {
            xkb_options = "ctrl:nocaps";
          };
          "type:touchpad" = {
            dwt = "enabled";
            tap = "disabled";
            natural_scroll = "disabled";
            middle_emulation = "disabled";
            scroll_method = "two_finger";
            click_method = "clickfinger";
          };
        };

        keybindings = {
          "${mod}+return" = "exec ${editor}";
          "${mod}+shift+return" = "exec ${term}";
          "${mod}+space" = "exec ${launcher}";
          "${mod}+ctrl+space" = "exec ${scriptLauncher}";
          "${mod}+shift+space" = "exec ${lock}";

          "${mod}+s" = "exec ${lib.getExe scratchpad}";
          "${mod}+w" = "exec ${lib.getExe notepad}";
          "${mod}+x" = "exec ${lib.getExe docs}";
          "${mod}+shift+p" = "exec 1password --quick-access --ozone-platform-hint=auto";

          "${mod}+q" = "kill";
          "${mod}+z" = "fullscreen";

          "${mod}+shift+c" = "reload";
          "${mod}+shift+r" = "mode \"resize\"";
          "${mod}+shift+4" =
            "exec grim -g \"$(slurp)\" \"${config.xdg.userDirs.pictures}/Screenshots/$(date +'screenshot-%m-%d-%y-%H%M%S.png')\"";

          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+0" = "workspace number 4";
          "${mod}+shift+1" = "move container to workspace number 1";
          "${mod}+shift+2" = "move container to workspace number 2";
          "${mod}+shift+3" = "move container to workspace number 3";
          "${mod}+shift+0" = "move container to workspace number 4";

          "${mod}+backslash" = "splith";
          "${mod}+minus" = "splitv";

          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";
          "${mod}+shift+h" = "move left";
          "${mod}+shift+j" = "move down";
          "${mod}+shift+k" = "move up";
          "${mod}+shift+l" = "move right";

          "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

          "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
          "XF86AudioNext" = "exec --no-startup-id playerctl next";
          "XF86AudioPrev" = "exec --no-startup-id playerctl previous";

          "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 5%-";
          "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl set +5%";
        };

        modes = {
          resize = {
            h = "resize shrink width 10px";
            k = "resize grow height 10px";
            j = "resize shrink height 10px";
            l = "resize grow width 10px";
            Return = "mode default";
            Escape = "mode default";
          };
        };

        modifier = mod;

        output = {
          "*".resolution = "3840x2160";
          "${laptopMonitor}" = {
            scale = "1.4";
          };
        };

        startup = [
          # Sync wayland clipboards, so 1Password copying works
          # https://wiki.archlinux.org/title/Clipboard#Tools
          { command = "wl-paste --primary --watch wl-copy"; }
          { command = "1password --silent"; }
          {
            command = "swayidle -w timeout 900 '${lockWithGrace}' timeout 1000 'swaymsg \"output * power off\"' resume 'swaymsg \"output * power on \"' before-sleep '${lock}'";
          }
        ];

        terminal = term;

        window = {
          commands = [
            {
              criteria = {
                app_id = "firefox";
              };
              command = "inhibit_idle fullscreen";
            }

            {
              criteria = {
                app_id = "google-chrome";
              };
              command = "inhibit_idle fullscreen";
            }

            {
              criteria = {
                app_id = "mpv";
              };
              command = "inhibit_idle fullscreen";
            }

            {
              criteria = {
                app_id = "org.kde.polkit-kde-authentication-agent-1";
              };
              command = "floating enable";
            }

            {
              criteria = {
                app_id = "thunar";
              };
              command = "floating enable";
            }

            {
              criteria = {
                app_id = "vivaldi";
              };
              command = "inhibit_idle fullscreen";
            }

            {
              criteria = {
                class = "1Password";
              };
              command = "floating enable";
            }
            {
              criteria = {
                window_role = "GtkFileChooserDialog";
              };
              command = "resize set 800 600";
            }

            {
              criteria = {
                window_role = "GtkFileChooserDialog";
              };
              command = "move position center";
            }

            {
              criteria = {
                window_role = "pop-up";
              };
              command = "floating enable";
            }

            {
              criteria = {
                window_role = "bubble";
              };
              command = "floating enable";
            }

            {
              criteria = {
                window_role = "task_dialog";
              };
              command = "floating enable";
            }

            {
              criteria = {
                window_role = "Preferences";
              };
              command = "floating enable";
            }

            {
              criteria = {
                window_type = "dialog";
              };
              command = "floating enable";
            }

            {
              criteria = {
                window_type = "menu";
              };
              command = "floating enable";
            }

            {
              criteria = {
                app_id = "firefox";
                title = "^Picture-in-Picture$";
              };
              command = "floating enable, resize set 800 450";
            }

            {
              criteria = {
                class = "^steam_app";
                title = "^Battle.net$";
              };
              command = "floating enable, resize set 1600 900";
            }

            {
              criteria = {
                class = "^steam$";
              };
              command = "floating enable, resize set 1600 900";
            }
          ];

          titlebar = false;
        };

        workspaceAutoBackAndForth = true;
      };

      extraConfig = ''
        bindswitch --reload --locked lid:on exec ${lock} && output ${laptopMonitor} disable
        bindswitch --reload --locked lid:off output ${laptopMonitor} enable

        include /etc/sway/config.d/*

        exec ${lib.getExe sway-startup}
      '';

      systemd.enable = true; # For waybar integration
    };

    programs.waybar = {
      enable = true;

      systemd = {
        enable = true;
        target = "sway-session.target";
      };

      style = ''
        @define-color background #${config.lib.stylix.colors.base00};
        @define-color highlight  #${config.lib.stylix.colors.base02};
        @define-color foreground #${config.lib.stylix.colors.base05};
        @define-color comment    #${config.lib.stylix.colors.base03};
        @define-color cyan       #${config.lib.stylix.colors.base0C};
        @define-color green      #${config.lib.stylix.colors.base0B};
        @define-color orange     #${config.lib.stylix.colors.base09};
        @define-color pink       #${config.lib.stylix.colors.base0F};
        @define-color blue       #${config.lib.stylix.colors.base0D};
        @define-color red        #${config.lib.stylix.colors.base08};
        @define-color yellow     #${config.lib.stylix.colors.base0A};

        * {
          border: none;
          border-radius: 0;
          font-family: "Homespun TT BRK", "FontAwesome";
          font-size: ${builtins.toString config.stylix.fonts.sizes.desktop}px;
          min-height: 0;
        }

        window#waybar {
          background: @background;
          border-bottom: 3px solid @orange;
          color: @yellow;
        }

        @keyframes blink {
          to {
            background-color: @foreground;
            color: @foreground;
          }
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #temperature,
        #backlight,
        #network,
        #pulseaudio {
          margin: 0 10px;
        }

        #battery {
          color: @green;
        }

        #battery.charging {
          color: @green;
        }

        #battery.good {
          color: @yellow;
        }

        #battery.warning {
          color: @orange;
        }

        #battery.critical {
          color: @pink;
        }

        #battery.warning:not(.charging),
        #battery.critical:not(.charging) {
          padding: 0 10px;
          border-bottom: 3px solid @highlight; /* Same as window#waybar for consistency */
          background: @red;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        #backlight {
          color: @yellow;
        }

        #clock {
          color: @pink;
        }

        #cpu {
          color: @red;
        }

        #memory {
          color: @cyan;
        }

        #network {
          color: @blue;
        }

        #pulseaudio {
          color: @cyan;
        }

        #temperature {
          color: @orange;
        }

        #idle_inhibitor {
          color: @red;
        }

        #temperature.critical {
          color: @red;
        }

        #workspaces button {
          background: transparent;
          color: @comment;
          border-bottom: 3px solid transparent;
        }

        #workspaces button.focused {
          background: @highlight;
          border-bottom: 2px solid white;
          color: @orange;
        }
      '';
    };

    xdg.configFile."waybar/config".text = ''
      {
        "modules-left": ["sway/workspaces", "sway/mode"],
        "modules-center": ["cpu", "memory", "temperature"],
        "modules-right": ["custom/media", "pulseaudio", "backlight", "network", "battery", "idle_inhibitor", "clock#calendar", "clock"],
        "sway/workspaces": {
            "disable-scroll": true,
            "all-outputs": true,
            "format": "{icon}",
            "format-icons": {
                "1": "󰈹",
                "2": "",
                "3": "",
                "4": "", }
        },
        "backlight": {
            "format": "{percent}% {icon}",
            "format-icons": ["󰃝", "󰃞", "󰃟", "󰃠"]
        },
        "battery": {
            "states": {
                "good": 80,
                "warning": 40,
                "critical": 20
            },
            "format": "{capacity}% {icon}",
            "format-charging": "{capacity}% ",
            "format-icons": ["", "", "", "", ""]
        },
        "clock": {
            "format": "{:%H:%M} 󰥔",
        },
        "clock#calendar": {
            "format": "{:%Y/%m/%d} ",
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        },
        "cpu": {
            "format": "{usage}% ",
            "tooltip": false
        },
        "memory": {
            "format": "{}% 󰍛"
        },
        "network": {
            "format-wifi": "{essid} ",
            "format-ethernet": "VPN ",
            "tooltip-format-wifi": "Signal Strength: {signalStrength}%",
            "format-disconnected": "NONE ",
        },
        "temperature": {
            "critical-threshold": 70,
            "format-critical": "{icon} {temperatureC}°C",
            "format": "{temperatureC}°C {icon}",
            "format-icons": [""]
        },
        "pulseaudio": {
            "scroll-step": 1, // %, can be a float
            "format": "{volume}% {icon}  | {format_source}",
            "format-bluetooth": "{volume}% {icon}  | {format_source}",
            "format-bluetooth-muted": " 󰝟  | {format_source}",
            "format-muted": "󰝟  | {format_source}",
            "format-source": "{volume}% ",
            "format-source-muted": "",
            "format-icons": {
                "default": ["", "", ""]
            }
        },
        "idle_inhibitor": {
            "format": "{icon}",
            "format-icons": {
                "activated": " 󰅶 ",
                "deactivated": " 󰛊 "
            }
        },
        "custom/media": {
            "format": "{} {icon}",
            "return-type": "json",
            "format-icons": {
                "spotify": "",
                "ncspot": "",
                "default": ""
            },
            "escape": true,
            "on-click": "playerctl play-pause",
            "exec": "${lib.getExe waybar-media} 2> /dev/null"
        }
      }
    '';

  };
}
