{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/902E501F2E5000A0";
    fsType = "ntfs";
  };

  fileSystems."/mnt/Data" = {
    device = "jupiter:/mnt/Data";
    fsType = "nfs4";
  };

  fileSystems."/mnt/Documents" = {
    device = "jupiter:/mnt/Documents";
    fsType = "nfs4";
  };

  fileSystems."/mnt/Temporary" = {
    device = "jupiter:/mnt/Temporary";
    fsType = "nfs4";
  };

  fileSystems."/mnt/Music" = {
    device = "jupiter:/mnt/Music";
    fsType = "nfs4";
  };

  fileSystems."/mnt/Photos" = {
    device = "jupiter:/mnt/Photos";
    fsType = "nfs4";
  };

  fileSystems."/mnt/Videos" = {
    device = "jupiter:/mnt/Videos";
    fsType = "nfs4";
  };

  fileSystems."/mnt/Software" = {
    device = "jupiter:/mnt/Software";
    fsType = "nfs4";
  };

  fileSystems."/mnt/Media" = {
    device = "jupiter:/mnt/Media";
    fsType = "nfs4";
  };

  fileSystems."/mnt/docker-nas" = {
    device = "jupiter:/mnt/docker";
    fsType = "nfs4";
  };
}
