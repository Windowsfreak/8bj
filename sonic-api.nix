{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.sonic = {
    path = [
      pkgs.nodejs
      pkgs.chromium
    ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    script = ''
      export UNIX=/run/sonic/apiserver.sock
      exec /var/sonic/sonic/sonic-server
    '';
    serviceConfig = {
      WorkingDirectory = "/var/sonic/sonic";
      RuntimeDirectory = "sonic";
      User = "sonic";
      Group = "sonic";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
