{ pkgs }:

pkgs.writeShellApplication {
  name = "tofi-kill";

  text = builtins.readFile ./kill.sh;
}
