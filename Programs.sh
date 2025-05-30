#!/bin/bash

# Define the list of packages to install
packages=(
  firefox
  kdeconnect
  torbrowser-launcher
  vesktop
  obsidian
  uv
  spotify
  vlc
  libreoffice
  thunar
  whatsdesk
  telegram-desktop-bin
  vlc
)

# Loop through each package and install using yay
for package in "${packages[@]}"; do
  yay -S --noconfirm "$package"
done

