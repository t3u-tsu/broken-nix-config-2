#!/usr/bin/env bash
set -e

# Required environment variables:
# FLAKE_PATH, TOKEN_PATH, HUB_URL, REMOTE_URL, HOSTNAME, USERNAME, GROUPNAME
# PUSH_CHANGES (true/false)
# GIT_USER_NAME, GIT_USER_EMAIL
# NVFETCHER_DIRS (space separated list of directories)
# NVFETCHER_CONFIGS (space separated list of config filenames)

export NIX_CONFIG="extra-experimental-features = nix-command flakes"
TOKEN=$(cat "$TOKEN_PATH")

# Git safe directory
git config --global --add safe.directory "$FLAKE_PATH"

# Prepare repository
if [ ! -d "$FLAKE_PATH/.git" ]; then
  echo "Preparing repository at $FLAKE_PATH..."
  mkdir -p "$FLAKE_PATH"
  rm -rf "$FLAKE_PATH"
  git clone "https://x-access-token:$TOKEN@$REMOTE_URL" "$FLAKE_PATH"
  chown -R "$USERNAME:$GROUPNAME" "$FLAKE_PATH"
fi

cd "$FLAKE_PATH"

# Fetch latest state
git fetch origin main
CURRENT_HEAD=$(git rev-parse HEAD)

if [ "$PUSH_CHANGES" = "true" ]; then
  # --- Producer Mode ---
  echo "Producer mode: Checking for updates..."
  git reset --hard origin/main
  nix flake update
  
  # Run nvfetcher if requested
  IFS=' ' read -r -a DIRS <<< "$NVFETCHER_DIRS"
  IFS=' ' read -r -a CONFIGS <<< "$NVFETCHER_CONFIGS"
  for i in "${!DIRS[@]}"; do
    dir="${DIRS[$i]}"
    config="${CONFIGS[$i]}"
    echo "Running nvfetcher in $dir..."
    if [ -d "$dir" ]; then
      (cd "$dir" && nvfetcher -c "$config")
    else
      echo "Warning: Directory $dir does not exist. Skipping."
    fi
  done

  # Git commit & push
  git -c user.name="$GIT_USER_NAME" -c user.email="$GIT_USER_EMAIL" add .
  if ! git diff --cached --exit-code; then
    git -c user.name="$GIT_USER_NAME" -c user.email="$GIT_USER_EMAIL" commit -m "chore(auto): update system and plugins $(date +%F)"
    git push "https://x-access-token:$TOKEN@$REMOTE_URL" main
  fi
  
  NEW_COMMIT=$(git rev-parse HEAD)
  curl -X POST -d "{\"commit\": \"$NEW_COMMIT\"}" "$HUB_URL/producer/done"
  
  if [ "$CURRENT_HEAD" != "$NEW_COMMIT" ]; then
    nixos-rebuild switch --flake .
  fi
else
  # --- Consumer Mode ---
  echo "Consumer mode: Checking hub for updates..."
  HUB_COMMIT=$(curl -s "$HUB_URL/latest-commit" | tr -d '\r\n[:space:]')
  
  if [ -z "$HUB_COMMIT" ]; then
     echo "Hub has no commit info. Skipping update."
  elif [ "$CURRENT_HEAD" = "$HUB_COMMIT" ]; then
     echo "System is already at the target commit ($HUB_COMMIT)."
  else
     echo "Syncing to commit: $HUB_COMMIT..."
                  git fetch origin "$HUB_COMMIT"
                  git reset --hard "$HUB_COMMIT"
                  nixos-rebuild switch --flake .
               fi
             fi
# Report status back to hub
REPORT_COMMIT=$(git rev-parse HEAD)
TIMESTAMP=$(date -Iseconds)
curl -X POST -d "{\"host\": \"$HOSTNAME\", \"commit\": \"$REPORT_COMMIT\", \"timestamp\": \"$TIMESTAMP\"}" "$HUB_URL/consumer/reported"
