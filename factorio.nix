{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    factorio-headless-experimental
  ];
  nixpkgs.config.allowUnfree = true;

  services.factorio = {
    enable = true;
    package = pkgs.factorio-headless-experimental;
    public = false;
    requireUserVerification = false;
    openFirewall = true;
    loadLatestSave = true;
    lan = true;
    game-name = "8bj";
    extraSettingsFile = "/var/lib/factorio/extra-settings.json";
    description = "do we really need this?";
    autosave-interval = 10;
    mods =
        let
          inherit (pkgs) lib;
          modDir = /var/lib/factorio/mods;
          modList = lib.pipe modDir [
            builtins.readDir
            (lib.filterAttrs (k: v: v == "regular"))
            (lib.mapAttrsToList (k: v: k))
            (builtins.filter (lib.hasSuffix ".zip"))
          ];
          modToDrv = modFileName:
            pkgs.runCommand "copy-factorio-mods" {} ''
              mkdir $out
              cp ${modDir + "/${modFileName}"} $out/${modFileName}
            ''
            // { deps = []; };
        in
          builtins.map modToDrv modList;
  };
}