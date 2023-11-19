{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];
  # Basic System Configuration
  boot.loader.grub.enable = true;
  networking.hostName = "8bj";
  i18n.defaultLocale = "en_US.UTF-8";

  # Users
  users.users = {
    caddy = {
      isSystemUser = true;
      home = "/var/lib/caddy";
    };
    arango = {
      isSystemUser = true;
      home = "/var/lib/arango";
    };
    dpv = {
      isSystemUser = true;
      home = "/var/dpv";
    };
    web = {
      isSystemUser = true;
      home = "/var/www";
    };
    mysql = {
      isSystemUser = true;
      home = "/var/lib/mysql";
    };
    "8bj" = {
      isNormalUser = true;
      extraGroups = ["wheel"]; # Allows sudo
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3Zi67clqatwzcqIpTx+xeaG4lh2F8fNvEkTIooKxwTT5B6bHkxJY2p0mhLJROLrzl0bMR/a33ZJEWkbsdPJ6ibZ3r7sHJUUgm8boq/V2y1sCooPFQusV9sKo0zfdkiguLxzQWzg0jsMIKogwTOSNa2wFZkIlNOVeqW/uO7V+0TACjQUkR0Keon5C/GA2aERF5ZSuqpYdKtkTl2YtWzSDsgQsg42ioNY1hzEoYwcaiJ29meya8OEbepXYOmFfHJmkljfdB8h27LYonLqNx3XWbJ2ESEW5mvxql8y5E0J68Pf0glxD120LyUleJtER5zPBUBHkET7b36FpIiUFb3XguA4W42dRtRRdFvWvwvxpxDHakWKDwYyE8y51YdxEYb78v0otZCx4NZDNsoDu84tS/17lkUyeX3xv4Zc8CYEqp0O69F2X2MOds6aFL3TQHI1Ysc6u+13tPI2JdzPZ1kfQtGHwLaC9szEwVgAvpbx8aLLy8tM2BA2EmpHXRci38j2lkz/32QTkjaITTLnOJEpJkVgjR+WCHFI3CvXDDzjL/UPfp+uFNrkoFNVll2ITFUUEqRnKL9n2aKp3RrT7uCVIupnsWcCGtssTtgUPYxmwBgd47K3o/3W98lIJCbXWP7KaLVEK45eJWwxiBNAhq4bz72IOljyEV4+rIIcMjkOXa+Q== bjoern"
      ];
    };
  };

  # Packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    arangodb
  ];

  # Firewall
  networking.firewall.allowedTCPPorts = [ 80 443 8529 ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  # Services
  services = {
    caddy = {
      enable = true;
      config = ''
        :443 {
          root * /var/www
          file_server {
            index index.htm
          }
        }
      '';
    };
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      dataDir = "/var/lib/mysql";
      socket = "/run/mysqld/mysqld.sock";
    };
  };
}