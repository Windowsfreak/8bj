{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.hypetax = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/hypetax/apiserver.sock
      exec /var/hypetax/hypetax/build/hypetax-saas config.yml
    '';
    serviceConfig = {
      WorkingDirectory = "/var/hypetax/hypetax";
      RuntimeDirectory = "hypetax";
      User = "hypetax";
      Group = "hypetax";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
