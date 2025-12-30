{ disks ? [ "/dev/sda" "/dev/sdb" "/dev/sdc" ], ... }: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = builtins.elemAt disks 0; # 250GB HDD
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      data1 = {
        type = "disk";
        device = builtins.elemAt disks 1; # 80GB HDD
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank-80gb";
              };
            };
          };
        };
      };
      data2 = {
        type = "disk";
        device = builtins.elemAt disks 2; # 80GB HDD
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank-80gb";
              };
            };
          };
        };
      };
    };
    zpool = {
      tank-80gb = {
        type = "zpool";
        mode = "mirror";
        mountpoint = "/mnt/tank-80gb";
      };
    };
  };
}