{
  host_feature_btrfs = import = ./btrfs.nix;
  host_feature_encryption = import ./encryption.nix;
  host_feature_impermanence = import ./impermanence.nix;
  host_feature_powermanagement = import ./power_management.nix;
}