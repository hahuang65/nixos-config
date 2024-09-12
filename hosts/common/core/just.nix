{ pkgs, programs, ... }:
let
  alias = "nx";
  justfile = "~/.config/nix/Justfile"; # Assuming this repository is cloned here
in {
  environment.shellAliases = { "${alias}" = "just --justfile ${justfile}"; };
  environment.systemPackages = [ pkgs.just ];

  # Cribbed from `just --completions bash`
  # Let's find a better way to do this.
  programs.bash.interactiveShellInit = ''
    eval "$(just --completions bash)"
    complete -F _just -o bashdefault -o default ${alias}
  '';
}
