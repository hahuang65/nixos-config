{ pkgs }:

pkgs.writeShellApplication {
  name = "tofi-nix-search";

  text = builtins.readFile ./nix-search.sh;
}
