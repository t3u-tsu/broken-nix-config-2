{ pkgs, config, uboot }:

let
  diskoImage = config.system.build.diskoImages;
in
pkgs.runCommand "torii-chan-sd-image" {
  nativeBuildInputs = [ pkgs.coreutils ];
} ''
  mkdir -p $out
  echo "Copying disko image..."
  cp ${diskoImage}/mmc.raw $out/torii-chan.img
  chmod u+w $out/torii-chan.img
  
  echo "Writing U-Boot..."
  dd if=${uboot}/u-boot-sunxi-with-spl.bin of=$out/torii-chan.img bs=1024 seek=8 conv=notrunc
  
  echo "Done. Image is at $out/torii-chan.img"
''
