{ configLib, ... }:
{
  imports = (configLib.scanPaths ./.) ++ (map configLib.fromRoot [ "hosts/common/optional" ]);
}
