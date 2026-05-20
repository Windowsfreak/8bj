{ pkgs, ... }:

{
  systemd.services.freellmapi = {
    description = "FreeLLMAPI Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      WorkingDirectory = "/var/freellmapi/freellmapi/server";
      ExecStart = "${pkgs.nodejs}/bin/node dist/index.js";
      User = "freellmapi";
      Group = "freellmapi";
      Restart = "always";
      EnvironmentFile = "/var/config/freellmapi.env";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
