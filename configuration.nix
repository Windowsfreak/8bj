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
          entrypoint = "start-notebook.py";
          cmd = [ "--PasswordIdentityProvider.hashed_password=$6$rounds=800000$uVZUmCstdsRKZpGr$AO6ZZ.AlRheMf8CRzN/AJ/tz.CUOz1.r77d2jyxh7.SmPVgbpoTpoZGf701PRheQuAeAXNfcE7divN42bDnBn."];
          volumes = [ "/srv/jupyter/home:/home/jovyan" ];
          ports = [ "127.0.0.1:38877:8888" ];
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