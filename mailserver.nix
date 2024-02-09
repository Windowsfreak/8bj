{ config, lib, pkgs, ... }: {
  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-23.11/nixos-mailserver-nixos-23.11.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "122vm4n3gkvlkqmlskiq749bhwfd0r71v6vcmg1bbyg4998brvx8";
    })
  ];

  mailserver = {
    enable = true;
    fqdn = "8bj.de";
    domains = [ "8bj.de" "windowsfreak.de" "parkour-deutschland.de" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "mail@8bj.de" = {
        hashedPasswordFile = "/var/config/mail/mail.8bj.de.key";
        aliases = ["@8bj.de" "@windowsfreak.de" "@parkour-deutschland.de"];
        catchAll = ["8bj.de" "windowsfreak.de"];
      };
      "noreply@8bj.de" = {
        hashedPasswordFile = "/var/config/mail/noreply.8bj.de.key";
        aliases = ["noreply@8bj.de" "noreply@windowsfreak.de" "noreply@parkour-deutschland.de"];
        catchAll = ["8bj.de" "windowsfreak.de"];
        sendOnly = true;
      };
      "bjoern@parkour-deutschland.de" = {
        hashedPasswordFile = "/var/config/mail/bjoern.parkour-deutschland.de.key";
      };
    };
    indexDir = "/var/lib/dovecot/indices";
    fullTextSearch = {
      enable = true;
      memoryLimit = 1000;
    };
    certificateScheme = "manual";
    certificateFile = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/8bj.de/8bj.de.crt";
    keyFile = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/8bj.de/8bj.de.key";
    rebootAfterKernelUpgrade = {
      enable = true;
    };
  };
  services.dovecot2.mailPlugins.globally.enable = [ "acl" "fts" "fts_xapian" ];
  services.dovecot2.extraConfig = lib.mkAfter ''
    namespace {
      type = public
      separator = .
      prefix = Public.
      location = maildir:/var/vmail/public:INDEXPVT=/var/lib/dovecot/indices/%d/%n/public
      subscriptions = no
    }

    protocol imap {
     mail_max_userip_connections = 100
     mail_plugins = $mail_plugins imap_acl imap_sieve
    }

    plugin {
      acl = vfile:/etc/dovecot/dovecot-acl:cache_secs=60
      acl_globals_only = yes
    }
  '';
}