{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  
  pythonEmbed = pkgs.python3.withPackages (ps: with ps; [
    fastapi
    uvicorn
    onnxruntime
    tokenizers
    numpy
    huggingface-hub
  ]);
in {
  # 1. Independent ONNX Embedding Daemon
  systemd.services.leben-embed = {
    description = "Leben ONNX Embedding Sidecar (IBM Granite 97M)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      WorkingDirectory = "/var/leben/leben/embed-sidecar";
      ExecStart = "${pythonEmbed}/bin/uvicorn service:app --host 127.0.0.1 --port 8089";
      User = "leben";
      Group = "leben";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
      MemoryMax = "1G";
    };
  };

  # 2. Main Leben Service
  systemd.services.leben = {
    path = [
      pkgs.chromium
      pkgs.imagemagick
      pkgs.libwebp
    ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" "leben-embed.service" ];
    wants = [ "leben-embed.service" ];
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
