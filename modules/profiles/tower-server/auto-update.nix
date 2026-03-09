{ config, lib, ... }:

{
  my.updateHub.client = {
    enable = true;
    user = lib.mkDefault config.my.user.name;
    onCalendar = "*-*-* 04:00:00";
  };
}
