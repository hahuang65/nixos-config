{ pkgs }:

pkgs.writeShellApplication {
  name = "tofi-power";

  text = builtins.readFile ./power.sh;
}
