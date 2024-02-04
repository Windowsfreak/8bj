{ pkgs, ... }:

let
  stopScript = pkgs.writeShellScript "minecraft-server-stop" ''
    echo stop > /run/minecraft-server.stdin

    # Wait for the PID of the minecraft server to disappear before
    # returning, so systemd doesn't attempt to SIGKILL it.
    while kill -0 "$1" 2> /dev/null; do
      sleep 1s
    done
  '';
in

{
  environment.systemPackages = with pkgs; [
    pkgs.jdk21_headless
  ];

  systemd.sockets.minecraft-server = {
    bindsTo = [ "minecraft-server.service" ];
    socketConfig = {
      ListenFIFO = "/run/minecraft-server.stdin";
      SocketMode = "0660";
      SocketUser = "minecraft";
      SocketGroup = "minecraft";
      RemoveOnStop = true;
      FlushPending = true;
    };
  };

  systemd.services.minecraft-server = {
    description   = "Minecraft Server Service";
    #wantedBy      = [ "multi-user.target" ];
    requires      = [ "minecraft-server.socket" ];
    after         = [ "network.target" "minecraft-server.socket" ];

    serviceConfig = {
      ExecStart = "/home/minecraft/server/java -Xmx2G -jar fabric-server-mc.1.20.4-loader.0.15.6-launcher.1.0.0.jar nogui";
      ExecStop = "${stopScript} $MAINPID";
      Restart = "always";
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/home/minecraft/server";

      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";

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