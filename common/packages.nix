{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Core CLI Utilities
    bat
    direnv
    eza
    fd
    file
    fzf
    git
    ripgrep
    tealdeer
    tmux
    vim
    which
    zoxide

    # System Monitoring & Hardware
    btop
    duf
    dust
    fastfetch
    htop
    hwinfo
    hwloc
    lm_sensors
    nvme-cli
    pciutils
    smartmontools
    usbutils

    # Networking
    bandwhich
    curl
    dnsutils
    lsof
    mtr
    nmap
    rsync
    tcpdump
    wget

    # Data & Archives
    jq
    p7zip
    unzip
    xz
    yq-go
    zip
    zstd

    # Nix Ecosystem
    nh
    nix-du
    nix-index
    nix-output-monitor
    nix-tree
    nixfmt-rfc-style

    # Security
    age
    gnupg
    sops
  ];
}