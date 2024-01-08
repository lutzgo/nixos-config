{ config, lib, pkgs, ... }:
  with lib;
{
  options = {
    host.user.root = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable root";
      };
    };
  };

  config = mkIf config.host.user.root.enable {
    users.users.root = {
      shell = pkgs.bashInteractive;
      hashedPasswordFile = mkDefault config.sops.secrets.root-password.path;
      packages = [ pkgs.home-manager ];

    #openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];

    };

    sops.secrets.root-password = {
      sopsFile = mkDefault ../secrets.yaml;
      neededForUsers = mkDefault true;
    };
  };
}
