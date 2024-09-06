{ pkgs, ... }:
{
    environment.shells = [ pkgs.bash ];
    users.defaultUserShell = pkgs.bash;
}
