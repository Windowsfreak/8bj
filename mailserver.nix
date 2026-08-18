{ config, lib, pkgs, ... }: {
  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-26.05/nixos-mailserver-nixos-26.05.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-26.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "1i2d9v2is1sfacaxyxncagyxlppipqmw554f1gfvq5b164djws5q";
    })
  ];

  mailserver = {
    srs = {
      enable = true;
    };
    enable = true;
    enablePop3Ssl = true;
    enableSubmissionSsl = true;
    enableSubmission = true; # for port 587 STARTTLS
    enableImap = true; # for port 143 STARTTLS
    stateVersion = 5;
    fqdn = "8bj.de";
    domains = [ "8bj.de" "windowsfreak.de" "rasselbande-horn.de" "kohlhof.org" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    accounts = {
      "mail@8bj.de" = {
        hashedPasswordFile = "/var/config/mail/mail.8bj.de.key";
        aliases = ["@8bj.de" "@windowsfreak.de"];
        catchAll = ["8bj.de" "windowsfreak.de"];
      };
      "noreply@8bj.de" = {
        hashedPasswordFile = "/var/config/mail/noreply.8bj.de.key";
        aliases = ["noreply@8bj.de" "noreply@windowsfreak.de" "noreply@rasselbande-horn.de" "dpv-mitgliederportal@8bj.de" "dpv-mitgliederportal-test@8bj.de"];
        catchAll = ["8bj.de" "windowsfreak.de"];
        sendOnly = true;
        sieveScript = ''
          require ["fileinto", "envelope"];
          discard;
        '';
      };
      "reisenderdruide@8bj.de" = {
        hashedPasswordFile = "/var/config/mail/reisenderdruide.8bj.de.key";
      };
      "darkzilla893@8bj.de" = {
        hashedPasswordFile = "/var/config/mail/darkzilla893.8bj.de.key";
      };
      "noreply@windowsfreak.de" = {
        hashedPasswordFile = "/var/config/mail/noreply.8bj.de.key";
        sendOnly = true;
        sieveScript = ''
          require ["fileinto", "envelope"];
          discard;
        '';
      };
      "noreply@rasselbande-horn.de" = {
        hashedPasswordFile = "/var/config/mail/noreply.8bj.de.key";
        sendOnly = true;
        sieveScript = ''
          require ["fileinto", "envelope"];
          discard;
        '';
      };
      "alica@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/alica.kohlhof.org.key";
        aliases = ["alica@rasselbande-horn.de"];
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          redirect "alicakohlhof@googlemail.com";
        '';
      };
      "bennet@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/bennet.kohlhof.org.key";
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          redirect "bennetkohlhof@googlemail.com";
        '';
      };
      "collin@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/collin.kohlhof.org.key";
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          redirect "collinkohlhof@googlemail.com";
        '';
      };
      "corinna@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/corinna.kohlhof.org.key";
        aliases = ["bkhvomkohlhof@kohlhof.org" "alica@rasselbande-horn.de"];
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          redirect "corinnakohlhof@googlemail.com";
        '';
      };
      "dominik@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/dominik.kohlhof.org.key";
        aliases = ["bennet@kohlhof.org" "bkhvomkohlhof@kohlhof.org" "collin@kohlhof.org"];
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          redirect "dominikkohlhof@googlemail.com";
        '';
      };
      "nicolas@kohlhof.org" = {
        hashedPasswordFile = "/var/config/mail/nicolas.kohlhof.org.key";
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          redirect "nicolaskohlhof@googlemail.com";
        '';
      };
      "corinna@rasselbande-horn.de" = {
        aliases = ["info@rasselbande-horn.de"];
        hashedPasswordFile = "/var/config/mail/corinna.rasselbande-horn.de.key";
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          keep;
          redirect "corinnakohlhof@googlemail.com";
        '';
      };
      "kristin@rasselbande-horn.de" = {
        aliases = ["info@rasselbande-horn.de"];
        hashedPasswordFile = "/var/config/mail/kristin.rasselbande-horn.de.key";
        sieveScript = ''
          require ["date", "relational", "vacation", "fileinto", "envelope", "variables"];
          keep;
          redirect "rasselbandehorn@googlemail.com";

          if header :contains "X-Spam-Flag" "YES" {
            fileinto "Junk";
            stop;
          }

          if allof (
            currentdate :zone "+0200" :value "ge" "iso8601" "2025-07-28T00:00:00+02:00",
            currentdate :zone "+0200" :value "le" "iso8601" "2025-08-17T23:59:59+02:00"
          ) {
            vacation
              :days 1
              :subject "Unser Büro ist zurzeit nicht besetzt!"
              :addresses ["info@rasselbande-horn.de"]
              "Unser Büro ist in der Zeit vom 28.07.2025 bis 17.08.2025 nicht besetzt. Ihre E-Mail wird nicht bearbeitet. Bitte senden Sie uns Ihr Anliegen erneut ab dem 18.08.2025 zu. Vielen Dank für Ihr Verständnis";
          }
        '';
      };
      "bewerbung@rasselbande-horn.de" = {
        hashedPasswordFile = "/var/config/mail/bewerbung.rasselbande-horn.de.key";
        sieveScript = ''
          require ["vacation", "fileinto", "envelope", "variables"];
          keep;
          redirect "alicakohlhof@googlemail.com";

          vacation
            :days 1
            :subject "Vielen Dank für Deine Bewerbung"
            :addresses ["bewerbung@rasselbande-horn.de"]
            "Liebe BewerberInnen,

vielen Dank für Deine Bewerbung und Dein Interesse daran, Teil unseres Teams zu werden. Wir freuen uns sehr über jede eingehende Bewerbung und sind schon jetzt gespannt darauf, all die motivierten Persönlichkeiten kennenzulernen, die sich bei uns vorstellen möchten.

Bitte beachte, dass wir im Bewerbungsverfahren nur vollständige Unterlagen berücksichtigen können. Schau daher gerne noch einmal nach, ob alles enthalten ist. Sollten Unterlagen fehlen, kannst Du diese selbstverständlich noch nachreichen.

Aufgrund der großen Nachfrage können wir leider nicht alle BewerberInnen in die nächste Runde mitnehmen. Wenn Du innerhalb von drei Wochen keine Rückmeldung von uns erhalten hast, konnte Deine Bewerbung dieses Mal leider nicht berücksichtigt werden.

Bis dahin danken wir Dir für Dein Vertrauen und wünschen Dir von Herzen alles Gute.

Vielleicht startet für Dich ja schon bald Dein Rasselbanden-Abenteuer.

Liebe Grüße
Dein Rasselbanden-Team

Corinna Kohlhof (Trägerin/Leitung)
Alica Kohlhof (Stellvertretung pädagogische Leitung)
Kristin Bendfeldt (Stellvertretung geschäftsführende Leitung)
Kita Rasselbande-Horn
Sandkamp 8, 22111 Hamburg
Tel.: 040-6552347 | Fax: 040-65590732";
        '';
      };
    };
    indexDir = "/var/lib/dovecot/indices";
    fullTextSearch = {
      enable = true;
      memoryLimit = 1000;
    };
    x509 = {
      certificateFile = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/8bj.de/8bj.de.crt";
      privateKeyFile = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/8bj.de/8bj.de.key";
    };
    mailboxes = {
      Trash = {
        auto = "subscribe";
        special_use = "\\Trash";
      };
      Junk = {
        auto = "subscribe";
        special_use = "\\Junk";
      };
      Drafts = {
        auto = "subscribe";
        special_use = "\\Drafts";
      };
      Sent = {
        auto = "subscribe";
        special_use = "\\Sent";
      };
      Archive = {
        auto = "subscribe";
        special_use = "\\Archive";
      };
    };
  };

  services.dovecot2.settings = {
    mail_plugins = {
      acl = true;
      fts = true;
    };

    "namespace inbox" = {
      "mailbox *" = {
        "acl user=mail@8bj.de" = {
          rights = "lrwstipekxa";
        };
      };
    };

    "namespace public" = {
      type = "public";
      separator = ".";
      prefix = "Public.";
      mail_driver = "maildir";
      mail_path = "/var/vmail/public";
      mail_index_private_path = "/var/lib/dovecot/indices/%{user | domain}/%{user | username}/public";
      subscriptions = false;
      mailbox_list_index_prefix = "public-list";

      "mailbox *" = {
        "acl user=mail@8bj.de" = {
          rights = "lrwstipekxa";
        };
      };
    };

    "protocol imap" = {
      mail_max_userip_connections = 100;
      mail_plugins = {
        imap_acl = true;
        imap_sieve = true;
      };
    };

    # ACL plugin settings
    acl_driver = "vfile";
    acl_globals_only = true;

    # Sieve plugin settings
    sieve_max_redirects = 75;
    sieve_user_email = "MAILER-DAEMON@8bj.de";
    sieve_redirect_envelope_from = "orig_recipient";
  };

  services.rspamd.locals."gpt.conf".text = ''
    enabled = true;
    allow_ham = true;
    type = "openai";
    .include(try=true) "/var/config/rspamd-gpt-secret.conf"
    model = "auto";
    max_tokens = 1000;
    temperature = 0.7;
    top_p = 0.9;
    timeout = 10s;
    autolearn = true;
    url = "http://localhost:3001/v1/chat/completions";
    prompt = "Analyze this email strictly as a spam detector given the email message, subject, FROM and url domains. Your recipient lives in Hamburg, Germany, runs a business, kindergarden, parkour organisation, live music performance and trades cryptocurrencies. Evaluate spam probability (0-1). Output ONLY 3 lines:\n1. Numeric score (0.00-1.00)\n2. One-sentence reason citing strongest red flag\n3. Primary concern category if found from the list: malware, phishing, marketing, scam";
    reason_header = "X-GPT-Reason";
  '';
  services.rspamd.locals."arc.conf".text = ''
    # Use the existing simple-nixos-mailserver DKIM keys
    path = "/var/dkim/$domain.$selector.key";
    selector = "mail"; # SNM's default selector

    # Essential for Sieve redirects: sign incoming mail before it gets forwarded
    sign_inbound = true;

    # Also sign normal outbound mail just in case
    sign_local = true;
    sign_authenticated = true;

    # Use the domain of the recipient (e.g., kohlhof.org or 8bj.de)
    # to find the correct signing key, rather than the original sender's domain
    use_domain = "recipient";

    allow_envfrom_empty = true;
  '';

  services.rspamd.locals."rbl.conf".text = ''
    rbls {
      spamhaus {
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.zen.dq.spamhaus.net";
        from = false;
      }
      spamhaus_from {
        from = true;
        received = false;
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.zen.dq.spamhaus.net";
        returncodes {
          SPAMHAUS_ZEN = [
            "127.0.0.2", "127.0.0.3", "127.0.0.4", "127.0.0.5",
            "127.0.0.6", "127.0.0.7", "127.0.0.9", "127.0.0.10", "127.0.0.11"
          ];
        }
      }
      spamhaus_authbl_received {
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.authbl.dq.spamhaus.net";
        from = false;
        received = true;
        ipv6 = true;
        returncodes {
          SH_AUTHBL_RECEIVED = "127.0.0.20";
        }
      }
      spamhaus_dbl {
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.dbl.dq.spamhaus.net";
        helo = true;
        rdns = true;
        dkim = true;
        disable_monitoring = true;
        returncodes {
          RBL_DBL_SPAM = "127.0.1.2";
          RBL_DBL_PHISH = "127.0.1.4";
          RBL_DBL_MALWARE = "127.0.1.5";
          RBL_DBL_BOTNET = "127.0.1.6";
          RBL_DBL_ABUSED_SPAM = "127.0.1.102";
          RBL_DBL_ABUSED_PHISH = "127.0.1.104";
          RBL_DBL_ABUSED_MALWARE = "127.0.1.105";
          RBL_DBL_ABUSED_BOTNET = "127.0.1.106";
          RBL_DBL_DONT_QUERY_IPS = "127.0.1.255";
        }
      }
      spamhaus_dbl_fullurls {
        ignore_defaults = true;
        no_ip = true;
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.dbl.dq.spamhaus.net";
        selector = 'urls:get_host';
        disable_monitoring = true;
        returncodes {
          DBLABUSED_SPAM_FULLURLS = "127.0.1.102";
          DBLABUSED_PHISH_FULLURLS = "127.0.1.104";
          DBLABUSED_MALWARE_FULLURLS = "127.0.1.105";
          DBLABUSED_BOTNET_FULLURLS = "127.0.1.106";
        }
      }
      spamhaus_zrd {
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.zrd.dq.spamhaus.net";
        helo = true;
        rdns = true;
        dkim = true;
        disable_monitoring = true;
        returncodes {
          RBL_ZRD_VERY_FRESH_DOMAIN = ["127.0.2.2", "127.0.2.3", "127.0.2.4"];
          RBL_ZRD_FRESH_DOMAIN = [
            "127.0.2.5", "127.0.2.6", "127.0.2.7", "127.0.2.8", "127.0.2.9",
            "127.0.2.10", "127.0.2.11", "127.0.2.12", "127.0.2.13", "127.0.2.14",
            "127.0.2.15", "127.0.2.16", "127.0.2.17", "127.0.2.18", "127.0.2.19",
            "127.0.2.20", "127.0.2.21", "127.0.2.22", "127.0.2.23", "127.0.2.24"
          ];
          RBL_ZRD_DONT_QUERY_IPS = "127.0.2.255";
        }
      }
      "SPAMHAUS_ZEN_URIBL" {
        enabled = true;
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.zen.dq.spamhaus.net";
        resolve_ip = true;
        checks = ['urls'];
        replyto = true;
        emails = true;
        ipv4 = true;
        ipv6 = true;
        emails_domainonly = true;
        returncodes {
          URIBL_SBL = "127.0.0.2";
          URIBL_SBL_CSS = "127.0.0.3";
          URIBL_XBL = ["127.0.0.4", "127.0.0.5", "127.0.0.6", "127.0.0.7"];
          URIBL_PBL = ["127.0.0.10", "127.0.0.11"];
          URIBL_DROP = "127.0.0.9";
        }
      }
      SH_EMAIL_DBL {
        ignore_defaults = true;
        replyto = true;
        emails_domainonly = true;
        disable_monitoring = true;
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.dbl.dq.spamhaus.net";
        returncodes = {
          SH_EMAIL_DBL = [ "127.0.1.2", "127.0.1.4", "127.0.1.5", "127.0.1.6" ];
          SH_EMAIL_DBL_ABUSED = [ "127.0.1.102", "127.0.1.104", "127.0.1.105", "127.0.1.106" ];
          SH_EMAIL_DBL_DONT_QUERY_IPS = [ "127.0.1.255" ];
        }
      }
      SH_EMAIL_ZRD {
        ignore_defaults = true;
        replyto = true;
        emails_domainonly = true;
        disable_monitoring = true;
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.zrd.dq.spamhaus.net";
        returncodes = {
          SH_EMAIL_ZRD_VERY_FRESH_DOMAIN = ["127.0.2.2", "127.0.2.3", "127.0.2.4"];
          SH_EMAIL_ZRD_FRESH_DOMAIN = [
            "127.0.2.5", "127.0.2.6", "127.0.2.7", "127.0.2.8", "127.0.2.9",
            "127.0.2.10", "127.0.2.11", "127.0.2.12", "127.0.2.13", "127.0.2.14",
            "127.0.2.15", "127.0.2.16", "127.0.2.17", "127.0.2.18", "127.0.2.19",
            "127.0.2.20", "127.0.2.21", "127.0.2.22", "127.0.2.23", "127.0.2.24"
          ];
          SH_EMAIL_ZRD_DONT_QUERY_IPS = [ "127.0.2.255" ];
        }
      }
      "DBL" {
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.dbl.dq.spamhaus.net";
        disable_monitoring = true;
      }
      "ZRD" {
        ignore_defaults = true;
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.zrd.dq.spamhaus.net";
        no_ip = true;
        dkim = true;
        emails = true;
        emails_domainonly = true;
        urls = true;
        returncodes = {
          ZRD_VERY_FRESH_DOMAIN = ["127.0.2.2", "127.0.2.3", "127.0.2.4"];
          ZRD_FRESH_DOMAIN = [
            "127.0.2.5", "127.0.2.6", "127.0.2.7", "127.0.2.8", "127.0.2.9",
            "127.0.2.10", "127.0.2.11", "127.0.2.12", "127.0.2.13", "127.0.2.14",
            "127.0.2.15", "127.0.2.16", "127.0.2.17", "127.0.2.18", "127.0.2.19",
            "127.0.2.20", "127.0.2.21", "127.0.2.22", "127.0.2.23", "127.0.2.24"
          ];
        }
      }
      spamhaus_sbl_url {
        ignore_defaults = true;
        rbl = "btbjyz62vqqleb7wgwtte7y4yy.sbl.dq.spamhaus.net";
        checks = ['urls'];
        disable_monitoring = true;
        returncodes {
          SPAMHAUS_SBL_URL = "127.0.0.2";
        }
      }
    }
  '';

  services.rspamd.locals."rbl_group.conf".text = ''
    symbols = {
      "SPAMHAUS_ZEN" { weight = 7.0; }
      "SH_AUTHBL_RECEIVED" { weight = 4.0; }
      "RBL_DBL_SPAM" { weight = 7.0; }
      "RBL_DBL_PHISH" { weight = 7.0; }
      "RBL_DBL_MALWARE" { weight = 7.0; }
      "RBL_DBL_BOTNET" { weight = 7.0; }
      "RBL_DBL_ABUSED_SPAM" { weight = 3.0; }
      "RBL_DBL_ABUSED_PHISH" { weight = 3.0; }
      "RBL_DBL_ABUSED_MALWARE" { weight = 3.0; }
      "RBL_DBL_ABUSED_BOTNET" { weight = 3.0; }
      "RBL_ZRD_VERY_FRESH_DOMAIN" { weight = 7.0; }
      "RBL_ZRD_FRESH_DOMAIN" { weight = 4.0; }
      "ZRD_VERY_FRESH_DOMAIN" { weight = 7.0; }
      "ZRD_FRESH_DOMAIN" { weight = 4.0; }
      "SH_EMAIL_DBL" { weight = 7.0; }
      "SH_EMAIL_DBL_ABUSED" { weight = 7.0; }
      "SH_EMAIL_ZRD_VERY_FRESH_DOMAIN" { weight = 7.0; }
      "SH_EMAIL_ZRD_FRESH_DOMAIN" { weight = 4.0; }
      "RBL_DBL_DONT_QUERY_IPS" { weight = 0.0; }
      "RBL_ZRD_DONT_QUERY_IPS" { weight = 0.0; }
      "SH_EMAIL_ZRD_DONT_QUERY_IPS" { weight = 0.0; }
      "SH_EMAIL_DBL_DONT_QUERY_IPS" { weight = 0.0; }
      "DBL" { weight = 0.0; description = "DBL unknown result"; groups = ["spamhaus"]; }
      "DBL_SPAM" { weight = 7.0; description = "DBL uribl spam"; groups = ["spamhaus"]; }
      "DBL_PHISH" { weight = 7.0; description = "DBL uribl phishing"; groups = ["spamhaus"]; }
      "DBL_MALWARE" { weight = 7.0; description = "DBL uribl malware"; groups = ["spamhaus"]; }
      "DBL_BOTNET" { weight = 7.0; description = "DBL uribl botnet C&C domain"; groups = ["spamhaus"]; }
      "DBLABUSED_SPAM_FULLURLS" { weight = 5.5; description = "DBL uribl abused legit spam"; groups = ["spamhaus"]; }
      "DBLABUSED_PHISH_FULLURLS" { weight = 5.5; description = "DBL uribl abused legit phish"; groups = ["spamhaus"]; }
      "DBLABUSED_MALWARE_FULLURLS" { weight = 5.5; description = "DBL uribl abused legit malware"; groups = ["spamhaus"]; }
      "DBLABUSED_BOTNET_FULLURLS" { weight = 5.5; description = "DBL uribl abused legit botnet"; groups = ["spamhaus"]; }
      "DBL_ABUSE" { weight = 5.5; description = "DBL uribl abused legit spam"; groups = ["spamhaus"]; }
      "DBL_ABUSE_REDIR" { weight = 1.5; description = "DBL uribl abused spammed redirector domain"; groups = ["spamhaus"]; }
      "DBL_ABUSE_PHISH" { weight = 5.5; description = "DBL uribl abused legit phish"; groups = ["spamhaus"]; }
      "DBL_ABUSE_MALWARE" { weight = 5.5; description = "DBL uribl abused legit malware"; groups = ["spamhaus"]; }
      "DBL_ABUSE_BOTNET" { weight = 5.5; description = "DBL uribl abused legit botnet C&C"; groups = ["spamhaus"]; }
      "DBL_PROHIBIT" { weight = 0.0; description = "DBL uribl IP queries prohibited!"; groups = ["spamhaus"]; }
      "DBL_BLOCKED_OPENRESOLVER" { weight = 0.0; description = "Spamhaus open resolver warning"; groups = ["spamhaus"]; }
      "DBL_BLOCKED" { weight = 0.0; description = "Spamhaus query limit exceeded"; groups = ["spamhaus"]; }
      "SPAMHAUS_ZEN_URIBL" { weight = 0.0; description = "Spamhaus ZEN URIBL: Filtered result"; groups = ["spamhaus"]; }
      "URIBL_SBL" { weight = 6.5; description = "Domain in body resolves to SBL IP"; one_shot = true; groups = ["spamhaus"]; }
      "URIBL_SBL_CSS" { weight = 6.5; description = "Domain in body resolves to SBL CSS IP"; one_shot = true; groups = ["spamhaus"]; }
      "URIBL_PBL" { weight = 0.01; description = "Domain in body resolves to PBL IP"; one_shot = true; groups = ["spamhaus"]; }
      "URIBL_DROP" { weight = 6.5; description = "Domain in body resolves to DROP IP"; one_shot = true; groups = ["spamhaus"]; }
      "URIBL_XBL" { weight = 5.0; description = "Domain in body resolves to XBL IP"; one_shot = true; groups = ["spamhaus"]; }
      "SPAMHAUS_SBL_URL" { weight = 6.5; description = "Numeric URL in body listed in SBL"; one_shot = true; groups = ["spamhaus"]; }
    }
  '';

  services.rspamd.extraConfig = lib.mkAfter ''
settings {
  local {
    priority = high;
    ip = ["127.0.0.1"];
    apply {
      symbols_enabled = ["DKIM_SIGNED"];
      flags = ["skip_process"];
    }
  }
}
  '';
}

