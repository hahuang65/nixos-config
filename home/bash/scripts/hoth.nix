{ pkgs }:

pkgs.writeShellApplication {
  name = "hoth";
  runtimeInputs = with pkgs; [ gum ];

  text = builtins.readFile ./hoth.sh;
}
