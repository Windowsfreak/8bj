{ config, pkgs, ... }:

let
  # using pkgs2 to avoid recursive loop with fetchFromGitHub
  # see https://stackoverflow.com/questions/73097604/nixos-how-to-import-some-configuration-from-gitlab-infinite-recursion-encounte
  pkgs2 = (import <nixpkgs> { });
  nix-phps = pkgs2.fetchFromGitHub {
    owner = "fossar";
    repo = "nix-phps";
    rev = "509bc62c91ecf1767b0e0142373d069308cf86c5";
    hash = "sha256-msZIntNplD+UUHXtyT72jE7Znwj/010U4g1Tv8NGpGg";
  };
  phps = import nix-phps;
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  caddyfileRbh = ''
    header /* {
      -Server
    }
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    root * /var/www/rbh
    php_fastcgi unix/${config.services.phpfpm.pools.php5.socket} {
    }
    file_server
  '';
  caddyfileKhf = ''
    header /* {
      -Server
    }
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    root * /var/www/kohlhof
    file_server
  '';
  caddyfileListmonk = ''
    header /* {
      -Server
    }
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    reverse_proxy * :9000
  '';
  caddyfileWordpress = ''
    header /* {
      -Server
    }
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    respond "This is the wrong server!" 410
    root * /var/www/wordpress
    @forbidden {
      not path /wp-includes/ms-files.php
      path /wp-admin/includes/*.php
      path /wp-includes/*.php
      path /wp-config.php
      path /wp-content/uploads/*.php
      path /.user.ini
      path /wp-content/debug.log
    }
    respond @forbidden "Access denied" 403

    php_fastcgi localhost:9001 {
      root /var/www/html
    }
    file_server
    header / {
      X-Frame-Options "SAMEORIGIN"
      X-Content-Type-Options "nosniff"
    }
  '';
  caddyfileEspocrm = ''
    header /* {
      -Server
    }
    header {
      Strict-Transport-Security "max-age=63072000"
      X-Frame-Options "SAMEORIGIN"
      X-Content-Type-Options "nosniff"
      Access-Control-Allow-Methods "POST, GET, PUT, PATCH, DELETE"
    }
    encode zstd gzip
    root * /var/www/espocrm/public
    @forbidden {
      path /data/*
      path /application/*
      path /custom/*
      path /vendor/*
      path /web.config
      path /public/*
    }
    respond @forbidden "Access denied" 403

    @rewrite {
      not path /client/*
    }
    rewrite @rewrite /index.php?{query}

    php_fastcgi localhost:9002 {
      root /var/www/html
    }
    file_server
  '';
  caddyfileJupyter = ''
    header /* {
      -Server
    }
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    reverse_proxy * :38877
  '';
  caddyfileMail = ''
    header /* {
      -Server
    }
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    root * ${unstable.snappymail}
    php_fastcgi unix/${config.services.phpfpm.pools.php.socket} {
    }
    file_server
  '';
  caddyfile = ''
    header /* {
      -Server
    }
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    @php not path /obj/* # /**/
    root * /var/www/8bj
    handle /vault/* {
      reverse_proxy * [::1]:16770 {
        header_up X-Real-IP {remote_host}
      }
    }
    handle /api/* { # /**/
      reverse_proxy * unix//run/dpv1/apiserver.sock
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
  services = {
    caddy = {
      enable = true;
      globalConfig = "";
      logFormat = ''
        output file /var/log/caddy/caddy.log
        level ERROR
      '';
      email = "lazer.erazer@gmail.com";
      virtualHosts."localhost:80" = {
        extraConfig = caddyfile;
      };
      virtualHosts."mail.8bj.de" = {
        extraConfig = caddyfileMail;
      };
      virtualHosts."newsletter.8bj.de" = {
        extraConfig = caddyfileListmonk;
      };
      virtualHosts."beta.parkour-deutschland.de" = {
        extraConfig = caddyfileWordpress;
      };
      virtualHosts."espo.8bj.de" = {
        extraConfig = caddyfileEspocrm;
      };
      virtualHosts."lab.8bj.de" = {
        extraConfig = caddyfileJupyter;
      };
      virtualHosts."8bj.de" = {
        serverAliases = [ "windowsfreak.de" "www.8bj.de" "www.windowsfreak.de" ];
        extraConfig = caddyfile;
      };
      virtualHosts."rasselbande-horn.de" = {
        serverAliases = [ "www.rasselbande-horn.de" "rbh.8bj.de" ];
        extraConfig = caddyfileRbh;
      };
      virtualHosts."kohlhof.org" = {
        serverAliases = [ "www.kohlhof.org" "kohlhof.8bj.de" ];
        extraConfig = caddyfileKhf;
      };
    };
    phpfpm = {
      phpOptions = ''
        output_buffering = "0";
        short_open_tag = "Off";
        expose_php = "Off";
        error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
        display_errors = "stderr";
        log_errors = true;
        error_log = "/var/log/php/php.log";
        upload_max_filesize = "512M";
        post_max_size = "512M";
        memory_limit = "512M";
        opcache.enable_cli = "1";
        opcache.interned_strings_buffer = "32";
        opcache.max_accelerated_files = "10000";
        opcache.memory_consumption = "128";
        opcache.revalidate_freq = "1";
        opcache.fast_shutdown = "1";
        openssl.cafile = "/etc/ssl/certs/ca-certificates.crt";
        catch_workers_output = "yes";
      '';
      pools = {
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
        php5 = {
          phpPackage = phps.packages.${builtins.currentSystem}.php56;
          user = "rbh";
          group = "rbh";
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
    };
  };
}