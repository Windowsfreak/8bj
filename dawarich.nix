{ config, pkgs, lib, ... }:

{
  services.dawarich = {
    enable = true;
    configureNginx = false;
    package = pkgs.callPackage ./dawarich-pkg/package.nix { };
    secretKeyBaseFile = "/var/config/dawarich-secret-key-base";
    extraEnvFiles = [ "/var/config/dawarich-secrets.env" ];
    localDomain = "dawarich.8bj.de";
    webPort = 19790;
    smtp = {
      host = "8bj.de";
      port = 465;
      user = "noreply@8bj.de";
      fromAddress = "dawarich <noreply@8bj.de>";
      passwordFile = "/var/config/dawarich-smtp-password";
    };
    environment = {
      SMTP_DOMAIN = "8bj.de";
    };
  };
}
