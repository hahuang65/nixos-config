{ configLib, ... }:
{
  imports = (configLib.scanPaths ./.) ++ [ ]; # Any other imports go in here
}
