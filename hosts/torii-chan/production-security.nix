{ config, lib, ... }:

{
  # Production Security Hardening
  
  # 1. SSH Access Control
  # By default (in configuration.nix), port 22 is open on all interfaces.
  # For production, we strictly limit SSH access to the WireGuard VPN interface.
  
  # Close all ports on global interfaces except for explicitly allowed ones
  # We use mkForce to ensure only these ports are open on end0 (WAN)
  networking.firewall.allowedTCPPorts = lib.mkForce [ 25565 ];

  # Open port 22 (SSH) and 8080 (update-hub) ONLY on WireGuard interfaces
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22 8080 ];
  networking.firewall.interfaces.wg1.allowedTCPPorts = [ 8080 ];
}
