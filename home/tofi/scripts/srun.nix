{ pkgs }:

pkgs.writeShellApplication {
  name = "tofi-srun";

  text = builtins.readFile ./srun.sh;
}
