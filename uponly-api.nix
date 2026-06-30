{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.uponly = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    script = ''
      export UNIX=/run/uponly/apiserver.sock
      exec /var/uponly/uponly/uponly
    '';
    serviceConfig = {
      WorkingDirectory = "/var/uponly/uponly";
      RuntimeDirectory = "uponly";
      User = "uponly";
      Group = "uponly";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
