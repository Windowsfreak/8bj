{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.jdk21_headless
  ];

  systemd.services.minecraft-server = {
    description   = "Minecraft Server Service";
    #wantedBy      = [ "multi-user.target" ];
    after         = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.jdk21_headless}/bin/java -Xmx2G -jar /var/lib/minecraft/server/fabric-server-mc.1.20.4-loader.0.15.6-launcher.1.0.0.jar nogui";
      Restart = "always";
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/var/lib/minecraft/server";
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
      ReadWritePaths = [ "/var/lib/minecraft" ];
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 25565 19132 ];
    allowedTCPPorts = [ 25565 25575 19132 ];
  };
}