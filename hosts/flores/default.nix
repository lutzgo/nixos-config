{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    inputs.nur.nixosModules.nur
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "x";
      };
    };
    filesystem = {
      encryption.enable = true;   # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true; # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "intel";
      gpu = "intel";
      raid.enable = false;        # This line can be removed if not needed as it is already default set by the role template
      sound = {
        server = "pipewire";
      };
    };
    network = {
      hostname = "flores";
      wired.enable = false;             # This line can be removed if not using wired networking
    };
    role = "laptop";
    user = {
      root.enable = true;
      ireen.enable = true;
      sgo.enable = true;
    };
  };
}
