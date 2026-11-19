{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.ct3tax = {
    path = [ pkgs.chromium ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/ct3tax/apiserver.sock
      exec /var/ct3tax/ct3tax/build/ct3tax-saas config.yml
    '';
    serviceConfig = {
      WorkingDirectory = "/var/ct3tax/ct3tax";
      RuntimeDirectory = "ct3tax";
      User = "ct3tax";
      Group = "ct3tax";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}

