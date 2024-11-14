{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    factorio
  ];

  systemd.services.factorio = {
    description   = "Factorio Server";
    #wantedBy      = [ "multi-user.target" ];
    after         = [ "network.target" ];

    serviceConfig = {
      ExecStart = "/var/lib/factorio --start-server-load-latest --server-settings /var/lib/factorio/server-settings.json --mod-directory /var/lib/factorio/mods";
      Restart = "always";
      User = "factorio";
      Group = "factorio";
      WorkingDirectory = "/var/lib/factorio/server";
      TimeoutStopSec = 90;

      # Hardening
      CapabilityBoundingSet = [ "" ];
      DeviceAllow = [ "" ];
      LockPersonality = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      ProtectProc = "invisible";
      ReadWritePaths = [ "/var/lib/factorio" ];
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 34197 ];
  };
}