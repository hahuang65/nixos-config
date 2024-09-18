{ pkgs, programs, ... }:
{
  environment.shells = [ pkgs.bashInteractive ];
  users.defaultUserShell = pkgs.bashInteractive;
}
