{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./arangodb.nix
    ./boot.nix
    ./caddy.nix
    ./factorio.nix
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
        espocrm = {
          autoStart = true;
          image = "espocrm/espocrm:fpm-alpine";
          volumes = [ "/var/www/espocrm:/var/www/html" "/run/mysqld/mysqld.sock:/run/mysqld/mysqld.sock" ];
          environment = {
            ESPOCRM_SITE_URL = "https://espo.8bj.de/";
          };
        };
        espocollin = {
          autoStart = true;
          image = "espocrm/espocrm:fpm-alpine";
          volumes = [ "/var/www/espocollin:/var/www/html" "/run/mysqld/mysqld.sock:/run/mysqld/mysqld.sock" ];
          environment = {
            ESPOCRM_SITE_URL = "https://lel.kohlhof.org/";
          };
        };
        selenium-chrome = {
          autoStart = true;
          image = "selenium/standalone-chrome:latest";
          ports = [ "127.0.0.1:4444:4444" ];
          environment = {
            SCREEN_WIDTH = "1920";
            SCREEN_HEIGHT = "1080";
            SCREEN_DEPTH = "24";
          };
          extraOptions = [
            "--shm-size=2g"
          ];
        };
        changedetection = {
          autoStart = true;
          image = "dgtlmoon/changedetection.io:latest";
          ports = [ "127.0.0.1:5000:5000" ];
          volumes = [ "/var/lib/changedetection:/datastore" ];
          environment = {
            WEBDRIVER_URL = "http://selenium-chrome:4444/wd/hub";
            USE_X_SETTINGS = "1";  # Wichtig für Reverse Proxy
            BASE_URL = "https://monitor.8bj.de";  # Deine Domain
          };
          dependsOn = [ "selenium-chrome" ];
        };
      };
    };
  };

  documentation.nixos.enable = false;

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
      secretFile = "/var/config/listmonk-secrets.ini";
    };
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      dataDir = "/var/lib/mysql";
    };
    nextcloudCaddy = {
      enable = true;
      configureRedis = true;
      package = pkgs.nextcloud31;
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
      authentication = ''
        # "local" is for Unix domain socket connections only
        local   all             all                                     trust
        # IPv4 local connections:
        host    all             all             127.0.0.1/32            trust
        # IPv6 local connections:
        host    all             all             ::1/128                 trust
        # Docker connections:
        host    all             all             172.16.0.0/12           md5
        # Allow replication connections from localhost, by a user with the
        # replication privilege.
        local   replication     all                                     trust
        host    replication     all             127.0.0.1/32            trust
        host    replication     all             ::1/128                 trust
        host    replication     all             172.17.0.0/24           md5
      '';
      settings = {
        listen_addresses = lib.mkForce "localhost,172.17.0.1";
      };
    };
    redis.servers = {
      nextcloud = {
        requirePassFile = "/var/config/redis-password.txt";
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
    vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      environmentFile = "/var/config/vaultwarden.env";
      config = {
        ROCKET_ADDRESS = "::1";
        ROCKET_PORT = 16770;
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/changedetection 0755 root root - -"
  ];
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
    };
    stateVersion="23.11";
  };
}