{ config, pkgs, ... }:

{
  imports = [
  ];
  # Basic System Configuration
  boot.loader = {
    grub = {
      enable = true;
      devices = [ "/dev/sda" ];
    };
    timeout = 2;
  };
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
}