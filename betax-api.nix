{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.betax = {
    path = [ pkgs.chromium ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/betax/apiserver.sock
      exec /var/betax/betax/build/betax-saas config.yml
    '';
    serviceConfig = {
      WorkingDirectory = "/var/betax/betax";
      RuntimeDirectory = "betax";
      User = "betax";
      Group = "betax";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
