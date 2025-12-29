{ config, lib, ... }:

{
  # Production Security Hardening
  
  # 1. SSH Access Control
  # By default (in configuration.nix), port 22 is open on all interfaces.
  # For production, we strictly limit SSH access to the WireGuard VPN interface.
  
  # Close port 22 on global interfaces (Ethernet/Wi-Fi)
  networking.firewall.allowedTCPPorts = lib.mkForce [];

  # Open port 22 ONLY on WireGuard interface (wg0)
  # WARNING: You must have a working WireGuard peer connection to SSH into the box after deploying this!
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22 ];
}
