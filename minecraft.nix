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
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d -s minecraft 'cd /home/minecraft/server && java -Xmx2G -jar /home/minecraft/server/fabric-server-mc.1.20.4-loader.0.15.6-launcher.1.0.0.jar nogui'";
      ExecStop = "${pkgs.tmux}/bin/tmux send-keys -t minecraft 'stop' C-m";
      Restart = "always";
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/home/minecraft/server";
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
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 25565 ];
    allowedTCPPorts = [ 25565 25575 ];
  };
}