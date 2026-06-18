The purpose of this file is to collect troubleshooting knowledge over time.

### DHCP
- if host has no DHCP, use `network.nix` to set IP addresses

### static content
- put static content and php pages in `/var/www/8bj/`
- put real static content in `/var/www/8bj/obj/`
- there is no `/var/www/8bj/api` (see below)
- caddy logs in `/var/logs/caddy/access*.log`
- the 404 handlers are a bit tricky, especially since caddy uses no `.htaccess`
- TODO: redirect `/folder` to `/folder/` if it contains an `index.php`

### php-fpm
- available via socket

### Go / Custom APIs (DPV, AurumTax, HypeTax, TagTax)
These services run natively as systemd daemons, communicating with Caddy via Unix sockets and using ArangoDB as their backend.
- **DPV**:
  - Code directories: `/var/dpv/api` (DPV1/DPV2), `/var/dpv/zoom` (Zoom), `/var/dpv/dpv` (Membership).
  - Services: `dpv1.service` (socket `/run/dpv1/apiserver.sock`), `dpv2.service` (socket `/run/dpv2/apiserver.sock`), `zoom.service` (socket `/run/zoom/apiserver.sock`), `dpv.service` (socket `/run/dpv/apiserver.sock`).
  - Run under user `dpv`.
  - Remember to `make test` in the working directory before restarting.
- **AurumTax**:
  - Code directory: `/var/aurumtax/aurumtax` (Frontend is in `/var/aurumtax/aurumtax/frontend`).
  - Service: `aurumtax.service` (socket `/run/aurumtax/apiserver.sock`).
  - Run under user `aurumtax`.
- **HypeTax**:
  - Code directory: `/var/hypetax/hypetax` (Frontend is in `/var/hypetax/hypetax/frontend`).
  - Service: `hypetax.service` (socket `/run/hypetax/apiserver.sock`).
  - Run under user `hypetax`.
- **TagTax**:
  - Code directory: `/var/tagtax/tagtax` (Frontend is in `/var/tagtax/tagtax/frontend`).
  - Service: `tagtax.service` (socket `/run/tagtax/apiserver.sock`).
  - Run under user `tagtax`.

### 502 Gateway Error
- Check that the corresponding API/systemd service is running.
- Check if the socket file exists in `/run/<service>/apiserver.sock`.
- Check that permissions of the socket are set to `666`.
- Test if the file is accessible by the `caddy` user: `sudo su caddy -s /bin/sh -c 'test -w /run/xxx/apiserver.sock && echo "writable"'`.
- Avoid placing sockets in `/tmp` or virtual directories.

### MySQL / MariaDB
- Configured natively under `services.mysql` (MariaDB).
- Port is not exposed; accessible only via Unix socket `/run/mysqld/mysqld.sock`.
- Databases:
  - `bjoern` (for general use).
  - `alica` (WordPress container).
  - `espocrm` and `espocollin` (EspoCRM containers).
- Database passwords are managed by system tables in `/var/lib/mysql`.
- WordPress and EspoCRM Docker containers mount `/run/mysqld/mysqld.sock` to connect to the host's MariaDB instance.

### PostgreSQL
- Configured natively under `services.postgresql`.
- Port is exposed locally (`localhost`) and to the Docker bridge (`172.17.0.1`).
- Firewall: custom `iptables` rule allows TCP 5432 traffic from the Docker container network (`172.16.0.0/12`).
- Databases:
  - `nextcloud` (Nextcloud).
  - `vaultwarden` (Vaultwarden).
  - `listmonk` (Listmonk).

### ArangoDB
- Runs inside a Docker container (image `arangodb:3.12`) mapped to `127.0.0.1:8529`.
- Data volume: `/var/db/arangodb` mapped to `/var/lib/arangodb3`.
- Reachable securely from localhost or via SSH port-forwarding: `ssh -N -L 8529:127.0.0.1:8529 8bj.de`.
- Access root password can be set in the `_system` database (initially blank).

### Docker / OCI Containers
Configured under `virtualisation.oci-containers` with `docker` backend:
- **WordPress (alica-reena.de)**:
  - Image: `wordpress:php8.3-fpm-alpine`.
  - Port: `9001` (proxied by Caddy).
  - Sockets mounted: `/run/mysqld/mysqld.sock` (MariaDB), `/run/redis-alica/redis.sock` (Redis).
  - Volumes: Web files in `/var/www/alica`, config files in `/var/config/alica`.
  - DB secrets: `/var/config/wordpress/db-password`.
- **EspoCRM (espo.8bj.de) & EspoCollin (lel.kohlhof.org)**:
  - Image: `espocrm/espocrm:fpm-alpine`.
  - Sockets mounted: `/run/mysqld/mysqld.sock` (MariaDB).
  - Web files: `/var/www/espocrm`, `/var/www/espocollin`.
  - Cron timers: NixOS services `espocrm-cron` and `espocollin-cron` execute `cron.php` every minute.
- **JupyterLab (lab.8bj.de)**:
  - Image: `quay.io/jupyter/datascience-notebook`.
  - Port: `38877` (proxied by Caddy).
  - Volume: `/srv/jupyter/home` mapped to `/home/jovyan`.
- **Changedetection.io (monitor.8bj.de)**:
  - Image: `dgtlmoon/changedetection.io:latest`.
  - Port: `5000` (proxied by Caddy).
  - Volume: `/var/lib/changedetection`.
  - Dependencies: `selenium-chrome` container running on port `4444`.

### NextCloud
- Adds a hardcoded VirtualHost to Caddy.
- Uses its own php-fpm pool using nextcloud user and group, caddy is in nextcloud group.
- Caddyfile redirects `/store-apps` to `/var/lib/nextcloud/store-apps` because the symlink didn't work.
- Config and secret files:
  - `/var/config/nextcloud-admin-pass.txt` (admin credentials, pgsql-pass is probably not needed as we're using unix socket auth)
  - `/var/config/redis-password.txt` (Redis credentials)
  - `/var/config/nextcloud-secrets.json` (contains passwordsalt, instanceid, mail SMTP settings, etc.):
```json
{
  "passwordsalt": "***",
  "secret": "***",
  "instanceid": "***",
  "redis": {
    "password": "same as redis-password.txt"
  },
  "maintenance_window_start": 2,
  "mail_smtpmode": "sendmail",
  "mail_sendmailmode": "smtp",
  "mail_smtpsecure": "",
  "mail_from_address": "noreply",
  "mail_domain": "8bj.de",
  "mail_smtphost": "127.0.0.1",
  "mail_smtpport": 25,
  "mail_smtpauth": true,
  "mail_smtpname": "noreply@8bj.de",
  "mail_smtppassword": "***",
  "trusted_domains": ["share.parkour-deutschland.de"],
  "trusted_proxies": ["127.0.0.1", "::1"],
  "default_language": "de",
  "default_locale": "de_DE",
  "default_phone_region": "de",
  "overwriteprotocol": "https"
}
```

### Mailserver
- Uses [nixos-mailserver](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver).
- Uses Postfix + Dovecot + Snappymail (served with an extra VirtualHost at `mail.8bj.de`).
- Users' password hashes are stored in `/var/config/mail`.
- DKIM private keys and text records are stored in `/var/dkim`.
- User sieve filters are stored in `/var/sieve`.
- Users' shared mail boxes (team mailboxes) are configured in `/etc/dovecot/dovecot-acl`. Example:
```ini
Public user=administrator@example.com lrwstipekxa
Public.* user=administrator@example.com lrwstipekxa
Public.Teamfolder user=member1@example.com lrwstipek
Public.Teamfolder.* user==member1@example.com lrwstipekxa
```
- Rspamd GPT spam analyzer is integrated with the local FreeLLMAPI instance. Its API key is stored in `/var/config/rspamd-gpt-secret.conf` (owned by `rspamd:rspamd`, `0400`) and loaded via UCL `.include` in Rspamd.
- Changing password hashes is handled via [dpv api](github.com/parkour-de/api) endpoint.
- It may be necessary to reboot the entire server if new FQDNs were added. Failing to do so will result in login errors.

### FreeLLMAPI
- Gateway for LLM API keys served at `llm.8bj.de` (via Caddy with HTTP Basic Authentication) or locally on port `3001`.
- Code cloned to `/var/freellmapi/freellmapi` and owned by `freellmapi:freellmapi`.
- Environment config and encryption keys are stored in `/var/config/freellmapi.env` (owned by `freellmapi:freellmapi`, `0600`).

### Vaultwarden
- Configured natively under `services.vaultwarden`.
- Served at `8bj.de/vault/` (proxied to `[::1]:16770`).
- Environment configuration: `/var/config/vaultwarden.env` (contains SMTP, database connection, and admin secrets).
- Uses PostgreSQL database.

### Listmonk
- Configured natively under `services.listmonk`.
- Served at `newsletter.8bj.de` (port 9000).
- Configuration/DB credentials file: `/var/config/listmonk-secrets.ini`.
- Uses PostgreSQL database (created locally).

### Game Servers
- **Minecraft**:
  - Service: `minecraft-server`.
  - Path: `/var/lib/minecraft/server` (running Fabric jar).
  - Ports: 25565 (TCP/UDP), 19132 (TCP/UDP), 25575 (TCP).
  - Runs under user `minecraft`.
- **Factorio**:
  - Service: `factorio` (headless experimental package).
  - Path: `/var/lib/factorio` (saves and mods).
  - Config: `/var/lib/factorio/extra-settings.json`.
  - Firewall port opened automatically (UDP 34197).

### Wireguard
- Interface `wg0`, listenPort `51820` (UDP).
- Private key file: `/var/config/wireguard/private.key`.
- Peers (i7, P3, Kiki) are statically defined with allowed IPs in `network.nix`.

### System Security & User Administration
- **Sudo**: `wheelNeedsPassword = false`.
- **SSH**: Password and interactive authentication are disabled; SSH key-only access is enforced (`paranoia.nix`).
- **Immutable Users**: `users.mutableUsers = false` is active. You CANNOT use `useradd` or `passwd` to create/modify users. All users, groups, and SSH keys must be configured declaratively in `users.nix`.

### Unique file locations (For Backups):
- `/etc/nixos` (NixOS configuration repository)
- `/var/config` (secrets and configurations: vaultwarden, nextcloud, mail, redis, wireguard, listmonk, freellmapi, wordpress)
- `/var/freellmapi` (FreeLLMAPI files and repo)
- `/var/dpv` (DPV APIs and binaries)
- `/var/aurumtax` (AurumTax frontend and binary)
- `/var/hypetax` (HypeTax frontend and binary)
- `/var/tagtax` (TagTax frontend and binary)
- `/var/www` (web roots for 8bj, rbh, kohlhof, wordpress, id, di, espocrm, espocollin)
- `/srv/jupyter` (JupyterLab notebooks home directory)
- `/var/lib` (persistent data for factorio, minecraft, mysql/mariadb, postgresql, nextcloud, changedetection)
- `/etc/dovecot/acl` (group/shared folders for mailserver)
- `/var/dkim` (DKIM keys for mail domains)
- `/var/sieve` (Dovecot sieve script directories per user)
- `/var/vmail` (mailboxes data)