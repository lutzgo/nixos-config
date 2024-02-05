{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.ireen = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Ireen";
      };
    };
  };

  config = mkIf config.host.user.ireen.enable {
    users.users.ireen = {
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      uid = 4243;
      group = "users" ;
      extraGroups = [
        "wheel"
        "video"
        "audio"
      ] ++ ifTheyExist [
        "adbusers"
        "docker"
        "git"
        "input"
        "lp"
        "network"
      ];

      openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
      hashedPasswordFile = config.sops.secrets.ireen-password.path;
      packages = [ pkgs.home-manager ];
    };

    sops.secrets.ireen-password = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
  };
}
