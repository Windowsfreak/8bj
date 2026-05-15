{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.tagtax = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/tagtax/apiserver.sock
      exec /var/tagtax/tagtax/build/tagtax-saas config.yml
    '';
    serviceConfig = {
      WorkingDirectory = "/var/tagtax/tagtax";
      RuntimeDirectory = "tagtax";
      User = "tagtax";
      Group = "tagtax";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
