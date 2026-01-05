{ lib, ... }:

{
  my.autoUpdate = {
    enable = lib.mkDefault true;
    user = lib.mkDefault "t3u";
    pushChanges = lib.mkDefault false; # Default to Consumer mode
  };
}
