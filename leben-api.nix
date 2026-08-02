{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.leben = {
    path = [ pkgs.chromium ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/leben/apiserver.sock
      exec /var/leben/leben/build/leben config.yml
    '';
    serviceConfig = {
      WorkingDirectory = "/var/leben/leben";
      RuntimeDirectory = "leben";
      User = "leben";
      Group = "leben";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
