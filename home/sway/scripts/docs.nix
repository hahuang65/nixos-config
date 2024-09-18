{ pkgs }:

pkgs.writeShellApplication {
  name = "docs";
  runtimeInputs = with pkgs; [
    sway
    zeal
  ];

  text = ''
    toggle_docs() {
      if ! docs_opened; then
        launch_docs

        while ! pgrep "zeal" >/dev/null; do
          sleep .1
        done
        sleep 1
        position_docs
      fi

      focus_docs
    }

    docs_opened() {
      pgrep --full "zeal" | wc --lines
    }

    launch_docs() {
      QT_SCALE_FACTOR=1.4 QT_DEVICE_PIXEL_RATIO=1 zeal &
    }

    position_docs() {
      swaymsg "[app_id=org.zealdocs.zeal] move scratchpad"
      resize_docs
    }

    resize_docs() {
      swaymsg "[app_id=org.zealdocs.zeal] resize set 2560 1440"
      swaymsg "[app_id=org.zealdocs.zeal] move absolute position center"
    }

    focus_docs() {
      resize_docs
      swaymsg "[app_id=org.zealdocs.zeal] scratchpad show"
    }

    toggle_docs
  '';
}
