{ pkgs }:

pkgs.writeShellApplication {
  name = "asdf";
  runtimeInputs = with pkgs; [ mise ];

  text = ''
    case "$1" in
    "plugin-add")
      shift
      mise plugin add "$@"
      ;;

    *)
      mise "$@"
      ;;
    esac
  '';
}
