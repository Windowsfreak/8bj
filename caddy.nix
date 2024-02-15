{ config, pkgs, ... }:

let
  # using pkgs2 to avoid recursive loop with fetchFromGitHub
  # see https://stackoverflow.com/questions/73097604/nixos-how-to-import-some-configuration-from-gitlab-infinite-recursion-encounte
  pkgs2 = (import <nixpkgs> { });
  nix-phps = pkgs2.fetchFromGitHub {
    owner = "fossar";
    repo = "nix-phps";
    rev = "509bc62c91ecf1767b0e0142373d069308cf86c5";
  };
  phps = import nix-phps;
  caddyfileRbh = ''
    header /* {
      -Server
    }
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    root * /var/www/rbh
    php_fastcgi unix/${config.services.phpfpm.pools.php7.socket} {
    }
    file_server
  '';
  caddyfileMail = ''
    header /* {
      -Server
    }
    header Strict-Transport-Security max-age=63072000
    encode zstd gzip
    root * ${pkgs.snappymail}
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
      virtualHosts."8bj.de" = {
        serverAliases = [ "windowsfreak.de" "www.8bj.de" "www.windowsfreak.de" ];
        extraConfig = caddyfile;
      };
      virtualHosts."rbh.8bj.de" = {
        extraConfig = caddyfileRbh;
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
        php7 = {
          phpPackage = phps.packages.${builtins.currentSystem}.php74;
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
      };
    };
  };
}