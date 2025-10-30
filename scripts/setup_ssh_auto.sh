#!/usr/bin/env bash
# setup_ssh_auto.sh - automatic GitHub SSH key setup
# Configure your email and passphrase here:
GITHUB_EMAIL="you@example.com"
SSH_PASSPHRASE="your_passphrase_here"  # leave empty "" for no passphrase

set -euo pipefail

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

# Ensure .ssh directory exists with correct permissions
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Check if key exists
if [ -f "$SSH_KEY" ]; then
  echo "✅ SSH key already exists at $SSH_KEY"
else
  echo "⚠ No SSH key found. Generating one automatically..."
  ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$SSH_KEY" -N "$SSH_PASSPHRASE"

  # Set correct permissions
  chmod 600 "$SSH_KEY"
  chmod 644 "$SSH_KEY.pub"

  echo "✅ SSH key generated."
fi

# Start the ssh-agent and add the key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY"

# Show the public key for adding to GitHub
echo
echo "📋 Your public key is:"
echo "----------------------------------------"
cat "$SSH_KEY.pub"
echo "----------------------------------------"
echo "Copy this and add it to GitHub → Settings → SSH and GPG keys → New SSH key"

# Optional: print SSH test command
echo
echo "🔹 Test GitHub connection with:"
echo "    ssh -T git@github.com"
echo
echo "🔹 Optional: switch your repo to SSH:"
echo "    git remote set-url origin git@github.com:username/repo.git"

