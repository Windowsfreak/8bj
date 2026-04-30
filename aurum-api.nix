{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.aurumtax = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/aurumtax/apiserver.sock
      exec /var/aurumtax/aurumtax/bin/saas config.yml
    '';
    serviceConfig = {
      WorkingDirectory = "/var/aurumtax/aurumtax";
      RuntimeDirectory = "aurumtax";
      User = "aurumtax";
      Group = "aurumtax";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
