{ config, lib, pkgs, ... }: {
  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.11/nixos-mailserver-nixos-25.11.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-25.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "16kanlk74xnj7xgmjsj7pahy31hlxqcbv76xnsg8qbh54b0hwxgq";
    })
  ];

  mailserver = {
    enable = true;
    enablePop3Ssl = true;
    enableSubmissionSsl = true;
    enableImap = true; # for port 143 STARTTLS
    stateVersion = 3;
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
      "noreply@parkour-deutschland.de" = {
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
      "ben@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "bildung@parkour-deutschland.de" "oeffentlichkeit@parkour-deutschland.de" "parkourparks@parkour-deutschland.de" "lizenzen@parkour-deutschland.de" "aktivmitglieder@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/ben.parkour-deutschland.de.key";
      };
      "bjoern@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "it@parkour-deutschland.de" "webmaster@parkour-deutschland.de" "aktivmitglieder@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/bjoern.parkour-deutschland.de.key";
      };
      "dirk@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "wettkampf@parkour-deutschland.de" "oeffentlichkeit@parkour-deutschland.de" "parkourparks@parkour-deutschland.de" "aktivmitglieder@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/dirk.parkour-deutschland.de.key";
      };
      "dominik@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "finanzen@parkour-deutschland.de" "wettkampf@parkour-deutschland.de" "parkourparks@parkour-deutschland.de" "lizenzen@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/dominik.parkour-deutschland.de.key";
      };
      "eike@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "formular@parkour-deutschland.de" "info@parkour-deutschland.de" "bildung@parkour-deutschland.de" "oeffentlichkeit@parkour-deutschland.de" "lizenzen@parkour-deutschland.de" "aktivmitglieder@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/eike.parkour-deutschland.de.key";
      };
      "jennifer@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "oeffentlichkeit@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/jennifer.parkour-deutschland.de.key";
      };
      "jewgeni@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "formular@parkour-deutschland.de" "info@parkour-deutschland.de" "satzung@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/jewgeni.parkour-deutschland.de.key";
      };
      "lea@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "parkourparks@parkour-deutschland.de" "lizenzen@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/lea.parkour-deutschland.de.key";
      };
      "lukas@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "it@parkour-deutschland.de" "webmaster@parkour-deutschland.de" "satzung@parkour-deutschland.de" "design@parkour-deutschland.de" "aktivmitglieder@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/lukas.parkour-deutschland.de.key";
      };
      "maren@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "formular@parkour-deutschland.de" "info@parkour-deutschland.de" "it@parkour-deutschland.de" "webmaster@parkour-deutschland.de" "oeffentlichkeit@parkour-deutschland.de" "parkourparks@parkour-deutschland.de" "lizenzen@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/maren.parkour-deutschland.de.key";
      };
      "martin@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "design@parkour-deutschland.de" "parkourparks@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/martin.parkour-deutschland.de.key";
      };
      "max@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "formular@parkour-deutschland.de" "info@parkour-deutschland.de" "lizenzen@parkour-deutschland.de" "satzung@parkour-deutschland.de" "wettkampf@parkour-deutschland.de" "aktivmitglieder@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/max.parkour-deutschland.de.key";
      };
      "merlin@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "formular@parkour-deutschland.de" "info@parkour-deutschland.de" "it@parkour-deutschland.de" "webmaster@parkour-deutschland.de" "finanzen@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/merlin.parkour-deutschland.de.key";
      };
      "olli@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/olli.parkour-deutschland.de.key";
      };
      "sabine@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "satzung@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/sabine.parkour-deutschland.de.key";
      };
      "soeren@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "lizenzen@parkour-deutschland.de"];
        hashedPasswordFile = "/var/config/mail/soeren.parkour-deutschland.de.key";
      };
      "newsletter@parkour-deutschland.de" = {
        aliases = ["alle@parkour-deutschland.de" "info@parkour-deutschland.de" "noreply@parkour-deutschland.de" "noreply@8bj.de"];
        hashedPasswordFile = "/var/config/mail/newsletter.parkour-deutschland.de.key";
      };
      "info@parkour-deutschland.de" = {
        hashedPasswordFile = "/var/config/mail/info.parkour-deutschland.de.key";
        catchAll = ["parkour-deutschland.de"];
        sieveScript = ''
          require ["fileinto", "envelope", "variables"];
          fileinto "Public.DPV-Team";
          stop;
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
  services.dovecot2.mailPlugins.globally.enable = [ "acl" "fts" ];
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
  services.rspamd.extraConfig = lib.mkAfter ''
gpt {
  enabled = true;
  allow_ham = true;
  type = "openai";
  api_key = "dummy-key";
  model = "gemini-1.5-flash-8b";
  max_tokens = 1000;
  temperature = 0.7;
  top_p = 0.9;
  timeout = 10s;
  autolearn = true;
  url = "https://8bj.de/api/openai/v1/chat/completions";
  prompt = "Analyze this email strictly as a spam detector given the email message, subject, FROM and url domains. Your recipient lives in Hamburg, Germany, runs a business, kindergarden, parkour organisation, live music performance and trades cryptocurrencies. Evaluate spam probability (0-1). Output ONLY 3 lines:\n1. Numeric score (0.00-1.00)\n2. One-sentence reason citing strongest red flag\n3. Primary concern category if found from the list: malware, phishing, marketing, scam";
  reason_header = "X-GPT-Reason";
}
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
