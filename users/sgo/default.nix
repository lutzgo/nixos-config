{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.sgo = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable sgo";
      };
    };
  };

  config = mkIf config.host.user.sgo.enable {
    users.users.sgo = {
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      uid = 4242;
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
      hashedPasswordFile = config.sops.secrets.sgo-password.path;
      packages = [ pkgs.home-manager ];
    };

    sops.secrets.sgo-password = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
  };
}
