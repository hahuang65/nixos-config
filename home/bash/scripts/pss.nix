{ pkgs }:

pkgs.writeShellApplication {
  name = "pss";
  text = ''
    # Finds all processes with the given name
    pgrep "$@" | xargs --no-run-if-empty ps -o pid -o command fp
  '';
}
