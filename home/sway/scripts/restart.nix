{ pkgs }:

pkgs.writeShellApplication {
  name = "restart-waybar";
  runtimeInputs = with pkgs; [ waybar ];

  text = ''
    pgrep --full waybar | xargs kill -9
    waybar >/dev/null 2>&1 &
  '';
}
