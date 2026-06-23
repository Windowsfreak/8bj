{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.uebtax = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/uebtax/apiserver.sock
      exec /var/uebtax/uebtax/build/uebtax-saas config.yml
    '';
    serviceConfig = {
      WorkingDirectory = "/var/uebtax/uebtax";
      RuntimeDirectory = "uebtax";
      User = "uebtax";
      Group = "uebtax";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
