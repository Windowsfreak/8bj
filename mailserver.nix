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
    enablePop3Ssl = true;
    enableSubmissionSsl = true;
    fqdn = "8bj.de";
    domains = [ "8bj.de" "windowsfreak.de" "parkour-deutschland.de" "rasselbande-horn.de" "kohlhof.org" ];

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
        aliases = ["noreply@8bj.de" "noreply@windowsfreak.de" "noreply@parkour-deutschland.de" "noreply@rasselbande-horn.de" "info@parkour-deutschland.de" "newsletter@parkour-deutschland.de"];
        catchAll = ["8bj.de" "windowsfreak.de"];
        sendOnly = true;
      };
      "noreply@windowsfreak.de" = {
        hashedPasswordFile = "/var/config/mail/noreply.8bj.de.key";
        sendOnly = true;
      };
      "noreply@parkour-deutschland.de" = {
        hashedPasswordFile = "/var/config/mail/noreply.8bj.de.key";
        sendOnly = true;
      };
      "noreply@rasselbande-horn.de" = {
        hashedPasswordFile = "/var/config/mail/noreply.8bj.de.key";
        sendOnly = true;
      };
      "alica@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/alica.kohlhof.org.key";
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          if not exists "reply-to" {
              set "reply-to" "${from}";
          }
          set "from" "alica@kohlhof.org";
          redirect "alicakohlhof@gmail.com";
        '';
      };
      "bennet@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/bennet.kohlhof.org.key";
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          if not exists "reply-to" {
              set "reply-to" "${from}";
          }
          set "from" "bennet@kohlhof.org";
          redirect "bennetkohlhof@gmail.com";
        '';
      };
      "collin@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/collin.kohlhof.org.key";
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          if not exists "reply-to" {
              set "reply-to" "${from}";
          }
          set "from" "collin@kohlhof.org";
          redirect "collinkohlhof@googlemail.com";
        '';
      };
      "corinna@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/corinna.kohlhof.org.key";
        aliases = ["bkhvomkohlhof@kohlhof.org"];
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          if not exists "reply-to" {
              set "reply-to" "${from}";
          }
          set "from" "corinna@kohlhof.org";
          redirect "corinna.kohlhof@googlemail.com";
        '';
      };
      "dominik@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/dominik.kohlhof.org.key";
        aliases = ["bennet@kohlhof.org" "bkhvomkohlhof@kohlhof.org" "collin@kohlhof.org"];
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          if not exists "reply-to" {
              set "reply-to" "${from}";
          }
          set "from" "dominik@kohlhof.org";
          redirect "dominik.kohlhof@googlemail.com";
        '';
      };
      "nicolas@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/nicolas.kohlhof.org.key";
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          if not exists "reply-to" {
              set "reply-to" "${from}";
          }
          set "from" "nicolas@kohlhof.org";
          redirect "nicolaskohlhof@googlemail.com";
        '';
      };
      "ben@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/ben.parkour-deutschland.de.key";
      };
      "bjoern@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/bjoern.parkour-deutschland.de.key";
      };
      "chris@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/chris.parkour-deutschland.de.key";
      };
      "dirk@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/dirk.parkour-deutschland.de.key";
      };
      "dominik@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/dominik.parkour-deutschland.de.key";
      };
      "eike@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/eike.parkour-deutschland.de.key";
      };
      "jewgeni@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/jewgeni.parkour-deutschland.de.key";
      };
      "lukas@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/lukas.parkour-deutschland.de.key";
      };
      "maren@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/maren.parkour-deutschland.de.key";
      };
      "martin@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/martin.parkour-deutschland.de.key";
      };
      "max@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/max.parkour-deutschland.de.key";
      };
      "merlin@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/merlin.parkour-deutschland.de.key";
      };
      "olli@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/olli.parkour-deutschland.de.key";
      };
      "sabine@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/sabine.parkour-deutschland.de.key";
      };
      "soeren@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/soeren.parkour-deutschland.de.key";
      };
      "newsletter@parkour-deutschland.de" = {
        aliases = ["info@parkour-deutschland.de" "noreply@parkour-deutschland.de" "noreply@8bj.de"];
        hashedPasswordFile = "/var/config/mail/newsletter.parkour-deutschland.de.key";
      };
      "info@parkour-deutschland.de" = {
        hashedPasswordFile = "/var/config/mail/info.parkour-deutschland.de.key";
        catchAll = ["parkour-deutschland.de"];
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          if not exists "reply-to" {
              set "reply-to" "${from}";
          }
          set "from" "info@parkour-deutschland.de";
          redirect "sabinehaider@gmx.net";
          redirect "maren@parkour-stuttgart.de";
          redirect "maxheckl@mailbox.org";
          redirect "info@maxheckl.de";
          redirect "info@parkourberlin.de";
          redirect "ben@parkourone.com";
          redirect "lazer.erazer+dpv@gmail.com";
          redirect "eike@plenter.de";
          redirect "lukas@pkgt.de";
          redirect "parkour@twio-x.de";
          redirect "parkourplauen@googlemail.com";
          redirect "schmolldominik@gmail.com";
          redirect "info@parkour-erfurt.de";
          redirect "MTBvet@GMX.de";
          redirect "parkour@sve67.de";
          redirect "Jennifer--Mueller@web.de";
          fileinto "Public.DPV-Team";
          stop;
        '';
      };
      "corinna@rasselbande-horn.de" = {
        aliases = ["info@rasselbande-horn.de"];
        hashedPasswordFile = "/var/config/mail/corinna.rasselbande-horn.de.key";
      };
      "kristin@rasselbande-horn.de" = {
        aliases = ["info@rasselbande-horn.de"];
        hashedPasswordFile = "/var/config/mail/kristin.rasselbande-horn.de.key";
      };
      "info@rasselbande-horn.de" = {
        hashedPasswordFile = "/var/config/mail/info.rasselbande-horn.de.key";
        sieveScript = ''
          require ["fileinto", "envelope"];
          discard;
        '';
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
    mailboxes = {
      Trash = {
        auto = "subscribe";
        specialUse = "Trash";
      };
      Junk = {
        auto = "subscribe";
        specialUse = "Junk";
      };
      Drafts = {
        auto = "subscribe";
        specialUse = "Drafts";
      };
      Sent = {
        auto = "subscribe";
        specialUse = "Sent";
      };
      Archive = {
        auto = "subscribe";
        specialUse = "Archive";
      };
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
      sieve_max_redirects = 75
      sieve_user_email = MAILER-DAEMON@8bj.de
      sieve_redirect_envelope_from = orig_recipient
    }
  '';
}