{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./arangodb.nix
    ./boot.nix
    ./caddy.nix
    ./users.nix
    ./mailserver.nix
    ./minecraft.nix
    ./nextcloudCaddy.nix
    ./dpv-api.nix
    ./paranoia.nix
  ];

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    oci-containers = {
      backend = "docker";
      containers = {
        jupyterLab = {
          autoStart = true;
          image = "quay.io/jupyter/datascience-notebook";
          volumes = [ "/srv/jupyter/home:/home/jovyan" ];
          ports = [ "127.0.0.1:38877:8888" ];
        };
        wordpress = {
          autoStart = true;
          image = "wordpress:fpm";
          volumes = [ "/var/www/wordpress:/var/www/html" "/run/mysqld/mysqld.sock:/run/mysqld/mysqld.sock" "/var/config/wordpress:/var/config/wordpress" ];
          ports = [ "127.0.0.1:9001:9000" ];
          environment = {
            WORDPRESS_DB_HOST = "localhost:/run/mysqld/mysqld.sock";
            WORDPRESS_DB_USER = "wordpress";
            WORDPRESS_DB_NAME = "wordpress";
            WORDPRESS_DB_PASSWORD_FILE = "/var/config/wordpress/db-password";
            WORDPRESS_CONFIG_EXTRA = "define('FS_METHOD', 'direct');";
          };
        };
      };
    };
  };

  # Packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    arangodb
    php
    pkgs.snappymail
  ];

  # Services
  services = {
    arangodb = {
      enable = true;
    };
    fail2ban = {
      enable = true;
      bantime = "70m";
      maxretry = 3;
      ignoreIP = [ "ddns.8bj.de" ];
    };
    listmonk = {
      enable = true;
      database = {
        createLocally = true;
      };
      secretFile = "/var/config/listmonk.ini";
    };
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      dataDir = "/var/lib/mysql";
    };
    nextcloudCaddy = {
      enable = true;
      configureRedis = true;
      package = pkgs.nextcloud29;
      hostName = "localhost";
      https = false;
      database.createLocally = true;
      config = {
        adminpassFile = "/var/config/nextcloud-admin-pass.txt";
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
      };
      settings = {
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
    ntp.enable = false;
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    postgresql = {
      listen_addresses = [ "localhost" "172.17.0.1" ];
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