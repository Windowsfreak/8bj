{ config, pkgs, lib, ... }:

let
  # Pre-backup staging script: Creates atomic database dumps
  dbDumpScript = pkgs.writeShellScript "backup-db-dump" ''
    set -euo pipefail
    STAGING="/var/backup-staging"
    mkdir -p "$STAGING/postgres" "$STAGING/mysql" "$STAGING/arango" "$STAGING/sqlite"

    echo "[1/4] Dumping PostgreSQL databases..."
    ${pkgs.postgresql_17}/bin/pg_dumpall -U postgres | ${pkgs.zstd}/bin/zstd -3 -f -o "$STAGING/postgres/all-databases.sql.zst"

    echo "[2/4] Dumping MariaDB databases..."
    ${pkgs.mariadb}/bin/mariadb-dump -u root --all-databases --single-transaction --quick | ${pkgs.zstd}/bin/zstd -3 -f -o "$STAGING/mysql/all-databases.sql.zst"

    echo "[3/4] Dumping ArangoDB container..."
    if ${pkgs.docker}/bin/docker ps --format '{{.Names}}' 2>/dev/null | grep -q arangodb; then
      ${pkgs.docker}/bin/docker exec arangodb arangodump \
        --server.endpoint tcp://127.0.0.1:8529 \
        --output-directory /tmp/arangodump-staging \
        --overwrite true 2>/dev/null || true
      tar -czf "$STAGING/arango/arangodb.tar.gz" -C /var/db/arangodb /tmp/arangodump-staging 2>/dev/null || true
    fi

    echo "[4/4] Safely backing up SQLite databases..."
    for db in /var/uponly/uponly/uponly.db \
              /var/dpv/zoom/zoom_accounts.db \
              /var/freellmapi/freellmapi/server/data/freeapi.db; do
      if [ -f "$db" ]; then
        ${pkgs.sqlite}/bin/sqlite3 "$db" ".backup '$STAGING/sqlite/$(basename "$db")'" 2>/dev/null || cp "$db" "$STAGING/sqlite/"
      fi
    done

    echo "Database dumps staged successfully in $STAGING."
  '';

  # Post-backup cleanup script
  cleanupScript = pkgs.writeShellScript "backup-cleanup" ''
    rm -rf /var/backup-staging/*
  '';
in
{
  environment.systemPackages = with pkgs; [
    restic
    rclone
    zstd
    sqlite
  ];

  services.restic.backups.truenas = {
    initialize = true;
    repository = "rclone:copyparty:/";
    rcloneConfigFile = "/var/config/rclone-backup.conf";
    passwordFile = "/var/config/restic-password.txt";

    # Hook: Run atomic DB dumps before snapshotting
    backupPrepareCommand = "${dbDumpScript}";
    backupCleanupCommand = "${cleanupScript}";

    paths = [
      # 1. System Configs & Secrets
      "/etc/nixos"
      "/var/config"
      "/var/dkim"
      "/var/sieve"
      "/etc/dovecot"

      # 2. Custom Go & Node Services (Storage, Jobs, Configs, DBs)
      "/var/aurumtax"
      "/var/tagtax"
      "/var/hypetax"
      "/var/uebtax"
      "/var/polartax"
      "/var/leben"
      "/var/uponly"
      "/var/dpv"
      "/var/freellmapi"

      # 3. Web & Application Data
      "/var/www"                  # Includes alica, espocrm, espocollin, and /var/www/pdf
      "/var/vmail"                # Live mailboxes
      "/var/lib/nextcloud"        # Nextcloud user files
      "/var/lib/snappymail"       # Webmail preferences & contacts
      "/var/lib/dawarich"         # Dawarich datastore
      "/var/lib/changedetection"  # Web monitor datastore
      "/var/lib/minecraft"        # Minecraft world
      "/var/lib/private/factorio" # Factorio saves & mods
      "/var/lib/private/listmonk" # Listmonk uploads & config
      "/home/bjoern"              # User home directory

      # 4. Atomic Database Dumps
      "/var/backup-staging"
    ];

    exclude = [
      # Ephemeral / Build Caches
      "*/.cache"
      "*/.npm"
      "*/node_modules"
      "/var/*/go"

      # Excluded Services & Datasets
      "/srv/jupyter"              # Excluded Jupyter workspace
      "/srv/torrents"             # Excluded torrents
      "/var/lib/transmission"     # Excluded transmission
      "/var/lib/docker"           # Rebuilt declaratively
      "/var/lib/private/ollama"   # Downloadable model weights
      "/var/lib/dovecot/indices"  # Rebuildable FTS search index

      # Raw DB directories (replaced by atomic dumps in /var/backup-staging)
      "/var/lib/mysql"
      "/var/lib/postgresql"
      "/var/db/arangodb"

      # Stale / Old Backups
      "/var/vmail-backup-2025-12-09"
      "/var/db/*backup*"
      "/var/log"
    ];

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 1"
    ];

    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
    };
  };
}
