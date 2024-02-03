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
  caddyfileNext = ''
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip

    redir /.well-known/carddav /remote.php/dav 301
    redir /.well-known/caldav /remote.php/dav 301

    reverse_proxy http://localhost:8080 {
      # forward host info to nextcloud
      header_up Host {host}
      header_up X-Real-IP {remote}
      header_up X-Forwarded-For {remote}
      header_up X-Forwarded-Port {server_port}
      header_up X-Forwarded-Proto {scheme}
    }
  '';
  caddyfileNext2 = ''
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip

    redir /.well-known/carddav /remote.php/dav 301
    redir /.well-known/caldav /remote.php/dav 301

    root * ${pkgs.nextcloud28}

    php_fastcgi unix/${config.services.phpfpm.pools.nextcloud2.socket} {
      env front_controller_active true
    }
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./arangodb.nix
    ./boot.nix
    ./users.nix
  ];

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
        extraConfig = caddyfileNext2;
      };
      virtualHosts."srv.windowsfreak.de" = {
        extraConfig = caddyfile;
      };
      virtualHosts."srv.8bj.de" = {
        extraConfig = caddyfile;
      };
      virtualHosts."share.parkour-deutschland.de" = {
        extraConfig = caddyfileNext;
      };
    };
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      dataDir = "/var/lib/mysql";
    };
    nextcloud = {
      enable = true;
      configureRedis = true;
      package = pkgs.nextcloud28;
      hostName = "localhost";
      https = false;
      database.createLocally = true;
      config = {
        adminpassFile = "/var/config/nextcloud-admin-pass.txt";
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        dbpassFile = "/var/config/nextcloud-pgsql-pass.txt";
      };
      extraOptions = {
        mail_smtpmode = "sendmail";
        mail_sendmailmode = "pipe";
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
        ];
      };
      maxUploadSize = "1G";
      secretFile = "/var/config/nextcloud-secrets.json";
    };
    nginx.virtualHosts."localhost" = {
      listen = [ { addr = "127.0.0.1"; port = 8080; } ];
      forceSSL = false;
      enableACME = false;
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
          "listen.group" = config.services.caddy.group;
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.max_requests" = 500;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 5;
        };
      };
      nextcloud2 = {
        user = "nextcloud";
        group = "nextcloud";
        phpEnv = {
          NEXTCLOUD_CONFIG_DIR = "/var/lib/nextcloud/config";
          PATH = "/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/bin:/bin";
        };
        settings = {
          "listen.owner" = config.services.caddy.user;
          "listen.group" = config.services.caddy.group;
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.max_requests" = 500;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 5;
        };
      };
    };
    redis.servers.nextcloud = {
      requirePassFile = "/var/config/redis-password.txt";
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