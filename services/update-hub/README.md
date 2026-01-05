# Coordinated Update System (Update Hub)

This directory manages the "Coordinated Update System" designed to synchronize NixOS system updates across multiple hosts.

## Architecture

The system follows a **Producer-Hub-Consumer** model:

1.  **Producer (`shosoin-tan`)**: 
    - Runs daily at 04:00.
    - Performs `flake update`, updates plugins, and pushes changes to GitHub.
    - Notifies the Hub of the latest commit ID upon completion.
2.  **Hub (`torii-chan`)**: 
    - Stores the latest commit ID reported by the Producer.
    - Collects status reports from all hosts to visualize progress.
    - Dashboard: `http://10.0.0.1:8080/status`
3.  **Consumer (All Hosts)**: 
    - Polls the Hub for the target commit ID.
    - Automatically performs `nixos-rebuild switch` if a newer commit is available.
    - Reports current status back to the Hub after updating.

## File Structure

- **`default.nix`**: The Hub server implementation (Python-based). Runs on `torii-chan`.
- **`client.nix`**: The auto-update logic for each host. Applied globally via `common/default.nix`.

## Operational Commands

### Check Status (CLI)
```bash
curl -s http://10.0.1.1:8080/status | jq
```

### Trigger Manual Update
- **Start the service directly:**
  ```bash
  sudo systemctl start nixos-auto-update.service
  ```
- **Trigger via Webhook (Target specific host):**
  ```bash
  # 10.0.1.1 (torii-chan), 10.0.1.3 (kagutsuchi), etc.
  curl -X POST http://<HOST_IP>:8081/trigger-update
  ```
- **Notify Hub of latest commit (Triggers all hosts):**
  ```bash
  curl -X POST -d '{"commit": "<COMMIT_HASH>"}' http://10.0.0.1:8080/producer/done
  ```

### View Logs
```bash
sudo journalctl -u nixos-auto-update.service -f
```

## Benefits
- **Consistency**: Ensures all hosts are running on the exact same commit.
- **Efficiency**: Only the Producer builds/pushes, allowing Consumers to leverage caches effectively.
- **Visibility**: Provides a centralized view of update status across the entire fleet.
