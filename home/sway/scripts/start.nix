{ pkgs }:

pkgs.writeShellApplication {
  name = "sway-startup";
  runtimeInputs = with pkgs; [
    jq
    sway
  ];

  text = ''
    function window_exist {
      swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.pid and .visible) | {name} | "\(.name)"' | grep "$1"
    }

    function wait_for_window {
      until window_exist "$1"; do
        sleep 0.2
      done
    }

    function wait_for_service {
      until systemctl --user is-active --quiet "$1"; do
        sleep 0.2
      done
    }

    swaymsg "workspace 1"
    swaymsg "exec firefox"
    wait_for_window "Firefox"
    swaymsg "workspace 2"
    swaymsg "exec slack"
    wait_for_window "Slack"
    swaymsg "splith; exec wezterm start --class 'senpai' -- bash -l -c senpai"
    wait_for_window "senpai"
    swaymsg "splitv; exec thunderbird"
    wait_for_window "Thunderbird"
    swaymsg "focus left; splitv; exec ferdium"
    wait_for_window "Ferdium"
    swaymsg "workspace 1"
  '';
}
