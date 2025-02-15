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

### dpv
- put server code in `/var/dpv/api/` and build
- prepare `config.yml`
- run server with socket `/var/run/dpv1/apiserver.sock`
- remember to `make test` before restarting `dpv1` or `dpv2` via `systemctl`

### 502 Gateway Error
- check api server running
- check socket exists
- check permissions of socket set to `666`
- test if file accessible, via `sudo su caddy -s /bin/sh`
- don't put socket in `/tmp` or any virtual folder

### MySQL
- only via unix socket, e.g. `mysql:unix_socket=/run/mysqld/mysqld.sock;dbname=bjoern`
- db passwords are managed by system table in `/var/lib/mysql`

### ArangoDB
- reachable via `ssh -N -L 8529:127.0.0.1:8529 8bj.de`
- has no root password, but can be set in `_system` db
- connection problems:
  - check IP address again
  - make sure you use HTTP

### NextCloud
- adds a hardcoded VirtualHost to caddy
- uses its own php-fpm pool using nextcloud user and group, caddy is in nextcloud group
- caddyfile redirects `/store-apps` to `/var/lib/nextcloud/store-apps` because the symlink didn't work
- `/var/config/nextcloud-admin-pass.txt` contains a string
- `/var/config/nextcloud-pgsql-pass.txt` contains a string (but it's probably not needed as we're using unix socket auth!)
- `/var/config/redis-password.txt` contains a string
- `/var/config/nextcloud-secrets.json` contains:
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
- uses [nixos-mailserver](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver)
- uses Postfix+Dovecot+Snappymail
- Snappymail is served with an extra VirtualHost
- Users' password hashes are stored in `/var/config/mail`
- Users' shared mail boxes (team mailboxes) are configured in `/etc/dovecot/dovecot-acl`. Example:
```ini
Public user=administrator@example.com lrwstipekxa
Public.* user=administrator@example.com lrwstipekxa
Public.Teamfolder user=member1@example.com lrwstipek
Public.Teamfolder.* user==member1@example.com lrwstipekxa
```
- [dpv api](https://github.com/parkour-de/api) has an endpoint to change password hashes
- It may be necessary to reboot the entire server if new FQDNs were added. Failing to do so will result in login errors.

### Other services

- Factorio server: `factorio.nix`
- Vaultwarden: `caddy.nix` and `configuration.nix`
- Jupyter Server: details on docker file in `configuration.nix`
- Sieve filters and mail forwarding: `mailserver.nix`
- Minecraft server: `minecraft.nix`
- Wireguard: `network.nix`
- Listmonk: `configuration.nix`

### Unique file locations:

- `/etc/nixos` (this repo)
- `/var/config` (secrets and configuration files for e.g. vaultwarden, nextcloud, mail, redis, wireguard, listmonk)
- `/var/dpv/api` (dpv server, see [DPV api](github.com/parkour-de/api))
- `/var/www`
- `/var/lib` (factorio, minecraft, mysql, nextcloud and more)
- `/etc/dovecot/acl` (group folders for mailserver)
- `/var/vmail`