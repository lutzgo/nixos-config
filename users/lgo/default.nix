{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.lgo = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable lgo";
      };
    };
  };

  config = mkIf config.host.user.lgo.enable {
    users.users.lgo = {
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      uid = 2323;
      group = "users" ;
      extraGroups = [
        "wheel"
        "video"
        "audio"
      ] ++ ifTheyExist [
        "adbusers"
        "deluge"
        "docker"
        "git"
        "input"
        "libvirtd"
        "lp"
        "mysql"
        "network"
        "podman"
      ];

      openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
      hashedPasswordFile = mkDefault config.sops.secrets.lgo-password.path;
      packages = [ pkgs.home-manager ];
    };

    sops.secrets.lgo-password = {
      sopsFile = mkDefault ../secrets.yaml;
      neededForUsers = mkDefault true;
    };
  };
}
