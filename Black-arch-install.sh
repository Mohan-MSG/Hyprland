#!/bin/bash

set -e

echo "[*] Downloading BlackArch strap.sh script..."
curl -O https://blackarch.org/strap.sh

echo "[*] Verifying strap.sh..."
EXPECTED_HASH="e26445d34490cc06bd14b51f9924debf569e0ecb"
DOWNLOADED_HASH=$(sha1sum strap.sh | awk '{print $1}')

if [ "$EXPECTED_HASH" != "$DOWNLOADED_HASH" ]; then
    echo "[!] strap.sh checksum mismatch!"
    echo "Expected: $EXPECTED_HASH"
    echo "Got     : $DOWNLOADED_HASH"
    exit 1
fi

echo "[*] Making strap.sh executable..."
chmod +x strap.sh

echo "[*] Running strap.sh to add BlackArch repo..."
sudo ./strap.sh

echo "[*] Updating package database..."
sudo pacman -Syu --noconfirm

echo "[*] Fetching BlackArch tool categories..."
GROUPS=$(pacman -Sg | awk '/^blackarch-/ {print $1}' | sort -u)

echo "[*] Found the following categories:"
echo "$GROUPS"

read -p "Install ALL BlackArch tool categories? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "[*] Installation cancelled."
    exit 0
fi

for group in $GROUPS; do
    echo "[*] Installing $group..."
    sudo pacman -S --noconfirm "$group"
done

echo "[+] All BlackArch tools installed successfully."
