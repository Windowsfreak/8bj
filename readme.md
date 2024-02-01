The purpose of this file is to collect troubleshooting knowledge over time.

### DHCP
- if host has no DHCP, use `network.nix` to set IP addresses

### static content
- put static content and php pages in `/var/www/`
- put real static content in `/var/www/obj/`
- there is no `/var/www/api` (see below)
- caddy logs in `/var/logs/caddy/access*.log`
- the 404 handlers are a bit tricky, especially since caddy uses no `.htaccess`

### php-fpm
- available via socket
- TODO: hide `X-Powered-By` header

### dpv
- put server code in `/var/dpv/api/` and build
- prepare `config.yml`
- run server with socket `/var/run/dpv/apiserver1.sock`
- remember to `make test` before restarting
- TODO: deploy as systemd service

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
- reachable via `ssh -N -L 8529:127.0.0.1:8529 srv.8bj.de`
- has no root password, but can be set in `_system` db
- connection problems:
  - check IP address again
  - make sure you use HTTP