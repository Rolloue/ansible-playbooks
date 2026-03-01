#!/usr/bin/env bash

set -e

USERNAME="ansible"
SSH_KEY="ssh-ed25519 AAAA...your-public-key... comment"

echo "[*] Checking if user exists..."

if id "$USERNAME" &>/dev/null; then
    echo "[*] User $USERNAME already exists"
else
    echo "[*] Creating user $USERNAME"
    useradd -m -s /bin/bash "$USERNAME"
fi

echo "[*] Creating .ssh directory"
mkdir -p /home/$USERNAME/.ssh

echo "[*] Adding public key"
grep -qxF "$SSH_KEY" /home/$USERNAME/.ssh/authorized_keys 2>/dev/null || \
echo "$SSH_KEY" >> /home/$USERNAME/.ssh/authorized_keys

echo "[*] Setting permissions"
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys

echo "[*] Ensuring password login disabled"
passwd -l $USERNAME >/dev/null 2>&1 || true

echo "[*] Adding passwordless sudo"
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 440 /etc/sudoers.d/$USERNAME

echo "[✓] Setup complete"