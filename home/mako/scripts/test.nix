{ pkgs }:

pkgs.writeShellApplication {
  name = "test-mako";
  runtimeInputs = with pkgs; [
    libnotify
    mako
  ];

  text = ''
    makoctl reload

    notify-send \
      -a "Test normal" \
      -i firefox \
      -t 5000 \
      "Here is some summary" \
      "needed to <s>create</s> that script cuz /usr/bin/makoctl reload wasn't working and was preventing the notification to appear with no logs"

    notify-send \
      -a "Test urgent" \
      -i firefox \
      -t 5000 \
      -u critical \
      "Here is some summary" \
      "needed to <s>create</s> that script cuz /usr/bin/makoctl reload wasn't working and was preventing the notification to appear with no logs"
  '';
}
