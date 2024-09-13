{ pkgs }:

pkgs.writeShellApplication {
  name = "notepad";
  runtimeInputs = with pkgs; [
    obsidian
  ];

  text = ''
    toggle_notepad() {
      if ! notepad_opened; then
        launch_notepad
        while ! pgrep electron | xargs --no-run-if-empty ps fp | grep "obsidian" >/dev/null; do
          sleep .1
        done
        sleep 1
        position_notepad
      fi
    
      focus_notepad
    }
    
    notepad_opened() {
      pgrep --full "obsidian" | wc --lines
    }
    
    launch_notepad() {
      obsidian &
    }
    
    position_notepad() {
      swaymsg "[instance=obsidian] move scratchpad"
      resize_notepad
    }
    
    resize_notepad() {
      swaymsg "[instance=obsidian] resize set 2560 1440"
      swaymsg "[instance=obsidian] move absolute position center"
    }
    
    focus_notepad() {
      resize_notepad
      swaymsg "[instance=obsidian] scratchpad show"
    }
    
    toggle_notepad
  '';
}
