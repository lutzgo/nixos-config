{ inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix
    ../common
  ];

  fileSystems = {
      "/mnt/media".options = [ "compress=zstd" "noatime"  ];
  };

  host = {
    container = {
      restic = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
    };
    filesystem = {
      encryption.enable = false;
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "vm-intel";
    };
    role = "server";
    service = {
      syncthing.enable = true;
      vscode_server.enable = true;
    };
    network = {
      hostname = "butcher";
      wired = {
        enable = true;
        ip = "192.168.137.5/24";
        gateway = "192.168.137.1";
        mac = "2A:BE:78:89:51:A5";
      };
    };
    user = {
      dave.enable = true;
      root.enable = false;
    };
  };
}
