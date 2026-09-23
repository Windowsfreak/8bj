{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.polartax = {
    path = [ pkgs.chromium ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/polartax/apiserver.sock
      exec /var/polartax/polartax/build/polartax-saas config.yml
    '';
    serviceConfig = {
      WorkingDirectory = "/var/polartax/polartax";
      RuntimeDirectory = "polartax";
      User = "polartax";
      Group = "polartax";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
