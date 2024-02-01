{ config, pkgs, ... }:

let
  caddyfile = ''
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    @php not path /obj/* # /**/
    root * /var/www
    handle /api/* { # /**/
      reverse_proxy * unix//var/run/dpv/apiserver1.sock
    }
    handle @php {
      # @keyword {
      #   path_regexp ^/[^\.\/]+$
      #   not file
      # }
      # handle @keyword {
      #   rewrite * /index.php?{path}
      # }
      php_fastcgi unix/${config.services.phpfpm.pools.php.socket} {
        try_files {path} {path}/index.php {path}/index.htm {path}/index.html index.php
      }
      file_server {
        index index.htm index.html
      }
    }
    handle /obj/* { # /**/
      file_server {
        index index.htm index.html
      }
    }
    handle_errors {
      @404 expression `{http.error.status_code} == 404`
      handle @404 {
        rewrite * "/404.htm"
        file_server
      }
    }
    # /**/
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./arangodb.nix
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

  security.sudo.wheelNeedsPassword = false;

  # Users
  users.groups = {
    arango = {};
    dpv = {};
    web = {};
    bjoern = {};
  };
  users.users = {
    caddy = {
      isSystemUser = true;
      home = "/var/lib/caddy";
    };
    dpv = {
      isSystemUser = true;
      home = "/var/dpv";
      group = "dpv";
    };
    web = {
      isSystemUser = true;
      home = "/var/www";
      group = "web";
    };
    mysql = {
      isSystemUser = true;
      home = "/var/lib/mysql";
    };
    "bjoern" = {
      isNormalUser = true;
      group = "bjoern";
      extraGroups = ["wheel"]; # Allows sudo
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3Zi67clqatwzcqIpTx+xeaG4lh2F8fNvEkTIooKxwTT5B6bHkxJY2p0mhLJROLrzl0bMR/a33ZJEWkbsdPJ6ibZ3r7sHJUUgm8boq/V2y1sCooPFQusV9sKo0zfdkiguLxzQWzg0jsMIKogwTOSNa2wFZkIlNOVeqW/uO7V+0TACjQUkR0Keon5C/GA2aERF5ZSuqpYdKtkTl2YtWzSDsgQsg42ioNY1hzEoYwcaiJ29meya8OEbepXYOmFfHJmkljfdB8h27LYonLqNx3XWbJ2ESEW5mvxql8y5E0J68Pf0glxD120LyUleJtER5zPBUBHkET7b36FpIiUFb3XguA4W42dRtRRdFvWvwvxpxDHakWKDwYyE8y51YdxEYb78v0otZCx4NZDNsoDu84tS/17lkUyeX3xv4Zc8CYEqp0O69F2X2MOds6aFL3TQHI1Ysc6u+13tPI2JdzPZ1kfQtGHwLaC9szEwVgAvpbx8aLLy8tM2BA2EmpHXRci38j2lkz/32QTkjaITTLnOJEpJkVgjR+WCHFI3CvXDDzjL/UPfp+uFNrkoFNVll2ITFUUEqRnKL9n2aKp3RrT7uCVIupnsWcCGtssTtgUPYxmwBgd47K3o/3W98lIJCbXWP7KaLVEK45eJWwxiBNAhq4bz72IOljyEV4+rIIcMjkOXa+Q== bjoern"
      ];
    };
    php = {
      isSystemUser = true;
      home = "/var/www";
      group = "php";
    };
  };
  users.groups.php = {};

  # Packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    arangodb
    php
    gnumake
    go
    nodejs
  ];

  # Services
  services = {
    arangodb = {
      enable = true;
    };
    caddy = {
      enable = true;
      email = "lazer.erazer@gmail.com";
      virtualHosts."localhost:80" = {
        extraConfig = caddyfile;
      };
      virtualHosts."srv.windowsfreak.de" = {
        extraConfig = caddyfile;
      };
      virtualHosts."srv.8bj.de" = {
        extraConfig = caddyfile;
      };
    };
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      dataDir = "/var/lib/mysql";
    };
    ntp.enable = false;
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    phpfpm.pools = {
      php = {
        user = "php";
        group = "php";
        settings = {
          "listen.owner" = config.services.caddy.user;
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.max_requests" = 500;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 5;
        };
      };
    };
    timesyncd = {
      enable = true;
      servers = [
        "0.de.pool.ntp.org"
        "1.de.pool.ntp.org"
        "2.de.pool.ntp.org"
        "3.de.pool.ntp.org"
      ];
    };
  };
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
    };
    stateVersion="23.11";
  };
}