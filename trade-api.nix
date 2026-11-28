{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  systemd.services.trade = {
    path = [ pkgs.chromium ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    script = ''
      export UNIX=/run/trade/apiserver.sock
      exec /var/trade/trade/build/trade-server config.yml
    '';
    serviceConfig = {
      WorkingDirectory = "/var/trade/trade";
      RuntimeDirectory = "trade";
      User = "trade";
      Group = "trade";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
