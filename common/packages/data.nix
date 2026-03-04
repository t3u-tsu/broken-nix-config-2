{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    jq
    p7zip
    unzip
    xz
    yq-go
    zip
    zstd
  ];
}
