{ pkgs }:

pkgs.writeShellApplication {
  name = "scratchpad";
  runtimeInputs = with pkgs; [ wezterm ];

  text = ''
    toggle_scratchpad() {
      if ! scratchpad_opened; then
        launch_scratchpad

        while ! pgrep wezterm-gui | xargs --no-run-if-empty ps fp | grep "Scratchpad" >/dev/null; do
          sleep .1
        done
        sleep 1
        position_scratchpad
      fi

      focus_scratchpad
    }

    scratchpad_opened() {
      pgrep --full "wezterm-gui start --class Scratchpad" | wc --lines
    }

    launch_scratchpad() {
      wezterm start --class "Scratchpad" &
    }

    position_scratchpad() {
      swaymsg "[class=Scratchpad] move scratchpad"
      resize_scratchpad
    }

    resize_scratchpad() {
      swaymsg "[class=Scratchpad] resize set 2560 1440"
      swaymsg "[class=Scratchpad] move absolute position center"
    }

    focus_scratchpad() {
      resize_scratchpad
      swaymsg "[class=Scratchpad] scratchpad show"
    }

    toggle_scratchpad
  '';
}
