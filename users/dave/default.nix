{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.dave = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Dave";
      };
    };
  };

  config = mkIf config.host.user.dave.enable {
    users.users.dave = {
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      uid = 2324;
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
      hashedPasswordFile = mkDefault config.sops.secrets.dave-password.path;
      packages = [ pkgs.home-manager ];
    };

    sops.secrets.dave-password = {
      sopsFile = mkDefault ../secrets.yaml;
      neededForUsers = mkDefault true;
    };
  };
}
