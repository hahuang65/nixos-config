{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  mod = "Mod1";
  term = "foot";
  editor = "foot -l vim";
  laptopMonitor = "eDP-1";
  launcher = "pkill fuzzel || fuzzel";
  lock = "swaylock --daemonize --indicator --screenshots --clock --effect-greyscale --effect-pixelate 5";
  lockWithGrace = "${lock} --grace 15";
in {
  options = {
    sway = {
      enable = mkEnableOption "sway";
    };
  };
  
  config = mkIf config.sway.enable {
    home.packages = with pkgs; [
      brightnessctl
      gobject-introspection
      grim
      playerctl
      python312Packages.pygobject3
      slurp
      swaybg
      swayidle
      swaylock-effects
      wl-clipboard
    ];

    home.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    wayland.windowManager.sway = {
      enable = true;
      config = rec {
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
          ];
        };

        bars = []; # Disable swaybar

        colors = {
          background = "#1e1e2e";
          focused = {
            background = "#1e1e2e";
            border = "#f5c2e7";
            childBorder = "#cba6f7";
            indicator = "#f5e0dc";
            text = "#cdd6f4";
          };
          focusedInactive = {
            background = "#1e1e2e";
            border = "#cba6f7";
            childBorder = "#313244";
            indicator = "#f5e0dc";
            text = "#cdd6f4";
          };
          placeholder = {
            background = "#1e1e2e";
            border = "#6c7086";
            childBorder = "#6c7086";
            indicator = "#6c7086";
            text = "#cdd6f4";
          };
          unfocused = {
            background = "#1e1e2e";
            border = "#cba6f7";
            childBorder = "#313244";
            indicator = "#f5e0dc";
            text = "#cdd6f4";
          };
          urgent = {
            background = "#1e1e2e";
            border = "#fab387";
            childBorder = "#f38ba8";
            indicator = "#6c7086";
            text = "#fab387";
          };
        };

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
          "${mod}+shift+space" = "exec ${lock}";

          "${mod}+s" = "exec $HOME/.scripts/scratchpad";
          "${mod}+w" = "exec $HOME/.scripts/notepad";
          "${mod}+x" = "exec $HOME/.scripts/docs";
          "ctrl+shift+p" = "exec 1password --quick-access --ozone-platform-hint=auto";

          "${mod}+q" = "kill";
          "${mod}+z" = "fullscreen";

          "${mod}+shift+c" = "reload";
          "${mod}+shift+r" = "mode \"resize\"";
          "${mod}+shift+4" = "exec grim -g \"$(slurp)\" \"$HOME/Pictures/Screenshots/$(date +'screenshot-%m/%d/%y-%H:%M:%S.png')\"";

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
            scale = "1.2";
          };
        };
        
        startup = [
          { command = "1password --silent"; }
          { command = "swayidle -w timeout 900 ${lockWithGrace} timeout 1000 'swaymsg \"output * power off\"' resume 'swaymsg \"output * power on \"' before-sleep ${lock}"; }
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
          ];  

          titlebar = false;
        };

        workspaceAutoBackAndForth = true;
      };

      extraConfig = ''
        bindswitch --reload --locked lid:on exec ${lock} && output ${laptopMonitor} disable
        bindswitch --reload --locked lid:off output ${laptopMonitor} enable

        include /etc/sway/config.d/*
      '';

      systemd.enable = true; # For waybar integration
    };

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
    };
    xdg.configFile."waybar/config".source = ./waybar/config;
    xdg.configFile."waybar/style.css".source = ./waybar/style.css;
    xdg.configFile."waybar/scripts/mediaplayer.py".source = ./waybar/scripts/mediaplayer.py;
  };
}
