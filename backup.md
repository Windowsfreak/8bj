# Backup Strategy & Implementation Guide for 8bj.de -> TrueNAS (Copyparty)

This document outlines the backup architecture, data inventory, network bandwidth behavior, Copyparty configuration, and disaster recovery procedures for backing up `8bj.de` to TrueNAS via Copyparty (`https://ddns.8bj.de/`).

---

## 1. Executive Summary & Architecture

The backup strategy employs a **Dual-Tier Model**:

```
+-----------------------------------------------------------------------------------------+
|                                8bj.de (NixOS Server)                                    |
|                                                                                         |
|  +---------------------------+   +-----------------------+   +-----------------------+  |
|  |  Hot DB Dump Engine       |   |  Live User Storage    |   |  Full System Files    |  |
|  |  Postgres, MariaDB,       |   |  Go app storage/jobs, |   |  Nextcloud, Maildir,  |  |
|  |  ArangoDB, SQLite         |   |  XMLs, CSVs, Configs  |   |  Jupyter, Web roots   |  |
|  +-------------+-------------+   +-----------+-----------+   +-----------+-----------+  |
|                |                             |                           |              |
|                v                             v                           v              |
|       /var/backup-staging/         Direct inclusion in Restic snapshot pipeline         |
|                |                                                                        |
|                +------------------------------------+-----------------------------------+  |
|                                                     |                                   |
|                                                     v                                   |
|                                 +---------------------------------------+               |
|                                 |   Restic Backup Engine (NixOS Module) |               |
|                                 |   • Client-side AES-256 encryption    |               |
|                                 |   • Content-Defined Chunking (CDC)    |               |
|                                 |   • Deduplication & Compression (zstd)|               |
|                                 +-------------------+-------------------+               |
|                                                     |                                   |
+-----------------------------------------------------|-----------------------------------+
                                                      |
                                          HTTPS (WebDAV Protocol)
                                                      |
                                                      v
+-----------------------------------------------------------------------------------------+
|                                TrueNAS Core / Scale                                     |
|                                                                                         |
|  +-----------------------------------------------------------------------------------+  |
|  | Copyparty File Server (https://ddns.8bj.de/)                                      |  |
|  | • WebDAV Ingest endpoint at /backups/                                             |  |
|  | • Permissions: write-without-delete (Anti-Ransomware protection)                  |  |
|  +-----------------------------------------+-----------------------------------------+  |
|                                            |                                            |
|                                            v                                            |
|  +-----------------------------------------------------------------------------------+  |
|  | TrueNAS ZFS Storage Pool (/mnt/tank/backups/8bj)                                  |  |
|  | • Daily automated ZFS snapshots (Point-in-time recovery, zero delta overhead)     |  |
|  | • Automatic scrub and bitrot protection                                          |  |
|  +-----------------------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------------------+
```

---

## 2. Server Data & Storage Inventory

Based on the live filesystem inspection of `8bj.de` (total footprint ~45 GB uncompressed active state):

### A. Included Paths

| Category | Specific Paths | Notes & Details |
| :--- | :--- | :--- |
| **System & Secrets** | • `/etc/nixos`<br>• `/var/config`<br>• `/var/dkim`<br>• `/var/sieve`<br>• `/etc/dovecot` | Cryptographic keys, secrets (`vaultwarden.env`, `nextcloud-secrets.json`, etc.), mail passwords. |
| **Custom Go/Node Services** | • `/var/aurumtax`<br>• `/var/tagtax`<br>• `/var/hypetax`<br>• `/var/uebtax`<br>• `/var/leben`<br>• `/var/uponly`<br>• `/var/dpv`<br>• `/var/freellmapi` | Includes `storage/jobs`, `uploads/clubs`, `usd.xml`, `chf.xml`, `crypto_rates.csv`, `ars.json`, `config.yml`, `uponly.db`, `zoom_accounts.db`, `freeapi.db`. *(Compiler caches `/var/*/go` and `.cache` are excluded).* |
| **Web Roots & Reports** | • `/var/www` | Includes WordPress (`alica`), EspoCRM (`espocrm`, `espocollin`), static sites (`8bj`, `rbh`, `kohlhof`), and **`/var/www/pdf`** (AurumTax client invoice/report PDFs). |
| **User Data & Mail** | • `/var/vmail` (~5.1 GB)<br>• `/var/lib/nextcloud` (~4.4 GB)<br>• `/home/bjoern` (~900 MB) | Dovecot Maildir boxes, Nextcloud file storage, user home directory. *(Jupyter workspace `/srv/jupyter` is excluded).* |
| **App State & Databases** | • `/var/lib/snappymail`<br>• `/var/lib/dawarich`<br>• `/var/lib/changedetection`<br>• `/var/lib/minecraft`<br>• `/var/lib/private/factorio`<br>• `/var/lib/private/listmonk` | SnappyMail contacts/prefs, Dawarich attachments, monitor data, game worlds/saves. |
| **Database Staging** | • `/var/backup-staging` | Fresh atomic dumps of PostgreSQL, MariaDB, and ArangoDB created immediately prior to snapshotting. |

### B. Excluded Paths

| Path | Reason for Exclusion |
| :--- | :--- |
| `/srv/jupyter` | JupyterLab workspace and large research datasets (excluded per user instruction). |
| `/var/lib/docker` | Stateless container layers (all containers are declaratively recreated via NixOS `virtualisation.oci-containers`). |
| `/var/*/go`, `*/.cache`, `*/.npm`, `*/node_modules` | Ephemeral compilation caches and package dependencies (~3+ GB saved). |
| `/var/lib/dovecot/indices` | Full-Text Search (FTS) index cache (~4.9 GB). Auto-regenerates from Maildir when queried. |
| `/var/vmail-backup-2025-12-09` & `/var/db/*backup*` | Stale manual backup directories (~4.5 GB). |
| `/var/log` | Systemd journal and service logs. |
| `/var/lib/mysql`, `/var/lib/postgresql`, `/var/db/arangodb` | Raw running database directories are replaced by clean, atomic dumps in `/var/backup-staging`. |

---

## 3. Copyparty on TrueNAS: Protocols & Capabilities

### Does Copyparty Support Everything We Need?
**Yes, 100%. You do not need to install anything else on TrueNAS.**

1. **Native WebDAV**:
   Copyparty is an RFC-compliant WebDAV server out of the box. Any WebDAV client or backup tool supporting WebDAV (like `rclone`, `restic` via rclone, `kopia`, `duplicacy`, or `cadaver`) connects seamlessly over HTTPS to `https://ddns.8bj.de/<volume-path>`.

2. **Ransomware / Anti-Deletion Protection**:
   In Copyparty’s volume configuration, you can assign user permissions without the delete (`d`) flag:
   ```ini
   [/backups]
     /mnt/tank/backups/8bj
     accs:
       # 'backupbot' can read (r) and write/upload (w/a), but CANNOT delete (d)
       rwa: backupbot
       rwad: admin
   ```
   *Benefit*: If the public server `8bj.de` is ever compromised, the attacker cannot delete or overwrite existing backup snapshots on TrueNAS.

3. **HTTP REST & Streaming Uploads**:
   Copyparty supports direct `curl -T`, chunked uploads, and upget for raw database dumps or emergency tarball uploads.

---

## 4. Network Traffic & Bandwidth Efficiency

### Will regular backups create massive internet traffic?
**No. Only new/changed bytes are transmitted over the internet.**

1. **Content-Defined Chunking (CDC)**:
   - Restic breaks files into variable-sized chunks (typically 1–8 MB) and calculates cryptographically secure hashes (BLAKE2b).
   - On every scheduled run, Restic checks the remote repository index on Copyparty.
   - If a chunk already exists on TrueNAS (e.g. datasets in Jupyter, static Nextcloud photos, existing PDF invoices, or older emails), **0 bytes of payload are uploaded**.
   - Only modified chunks (e.g. newly received emails, append-only SQLite transactions, fresh daily database dumps) are compressed with `zstd`, encrypted, and transmitted.

2. **Typical Daily Transfer Volume**:
   - Initial Full Backup: ~40–45 GB (one-time).
   - Daily Incremental Run: **~50 MB to 200 MB** of actual upload traffic.

3. **Synergy with TrueNAS ZFS Snapshots**:
   - TrueNAS stores the Restic repository on a ZFS dataset (e.g. `tank/backups/8bj`).
   - TrueNAS can run a daily ZFS snapshot schedule on `tank/backups/8bj`.
   - ZFS snapshots take 0 seconds and consume only the delta between days on the NAS disks, providing immutable versioning even if a local Restic prune operation is executed.

---

## 5. Declarative NixOS Configuration (`backup.nix`)

Below is the complete NixOS configuration module.

### File: `/etc/nixos/backup.nix`

```nix
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
    if ${pkgs.docker}/bin/docker ps --format '{{.Names}}' | grep -q arangodb; then
      ${pkgs.docker}/bin/docker exec arangodb arangodump \
        --server.endpoint tcp://127.0.0.1:8529 \
        --output-directory /tmp/arangodump-staging \
        --overwrite true 2>/dev/null || true
      tar -czf "$STAGING/arango/arangodb.tar.gz" -C /var/db/arangodb /tmp/arangodump-staging 2>/dev/null || true
    fi

    echo "[4/4] Safely copying SQLite databases..."
    for db in /var/uponly/uponly/uponly.db \
              /var/dpv/zoom/zoom_accounts.db \
              /var/freellmapi/freellmapi/server/data/freeapi.db; do
      if [ -f "$db" ]; then
        ${pkgs.sqlite}/bin/sqlite3 "$db" ".backup '$STAGING/sqlite/$(basename "$db")'" || cp "$db" "$STAGING/sqlite/"
      fi
    done

    echo "Database dump complete. Staging size: $(du -sh $STAGING | cut -f1)"
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
      
      # Excluded Services & Large Rebuildables
      "/srv/jupyter"              # Excluded Jupyter workspace
      "/var/lib/docker"
      "/var/lib/private/ollama"
      "/var/lib/dovecot/indices"
      
      # Raw DB directories (replaced by atomic dumps in /var/backup-staging)
      "/var/lib/mysql"
      "/var/lib/postgresql"
      "/var/db/arangodb"

      # Stale / Old Backups
      "/var/vmail-backup-2025-12-09"
      "/var/db/*backup*"
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
```

---

## 6. Setup & Deployment Steps

1. **On TrueNAS (Copyparty)**:
   - Ensure volume `/backups` exists and points to `/mnt/tank/backups/8bj`.
   - Add user `backupbot` with write/append permission (`rwa`).

2. **On `8bj.de`**:
   - Generate restic password:
     ```bash
     openssl rand -base64 32 | sudo tee /var/config/restic-password.txt
     sudo chmod 0400 /var/config/restic-password.txt
     ```
   - Obscure Copyparty password for rclone:
     ```bash
     rclone obscure "YourCopypartyPassword"
     ```
     Place the obscured password into `rcloneConfigFile` in `backup.nix`.
   - Add `./backup.nix` to `configuration.nix` under `imports = [ ... ];`.
   - Run `sudo nixos-rebuild switch`.
   - Test the first backup manually:
     ```bash
     sudo systemctl start restic-backups-truenas.service
     sudo journalctl -u restic-backups-truenas.service -f
     ```

---

## 7. Disaster Recovery (DR) Runbook

In the event of complete server loss:

1. **Bootstrap Clean Server**:
   Install base NixOS on the new VPS, clone the git repo to `/etc/nixos`.
2. **Restore Secrets & Restic Key**:
   Download `/var/config/restic-password.txt` from TrueNAS (via Copyparty Web UI or local copy) to `/var/config/`.
3. **Restore Snapshot**:
   ```bash
   restic -r rclone:copyparty:/ restore latest --target /
   ```
4. **Restore Databases**:
   - PostgreSQL: `${pkgs.zstd}/bin/zstdcat /var/backup-staging/postgres/all-databases.sql.zst | psql -U postgres`
   - MariaDB: `${pkgs.zstd}/bin/zstdcat /var/backup-staging/mysql/all-databases.sql.zst | mysql -u root`
   - ArangoDB: `docker exec arangodb arangorestore --input-directory /tmp/arangodump-staging`
5. **Switch System**:
   ```bash
   nixos-rebuild switch
   ```
6. **Restart Services**:
   ```bash
   systemctl restart phpfpm-nextcloud dovecot postfix docker
   ```
