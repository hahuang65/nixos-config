<<<<<<< HEAD
{ pkgs, ... }:
{
    environment.shells = [ pkgs.bash ];
    users.defaultUserShell = pkgs.bash;
=======
{ ... }:
{
    environment.shells = [ pkg.bash ];
    users.defaultUserShell = pkg.bash;
>>>>>>> 44ffca9 (WIP)
}
