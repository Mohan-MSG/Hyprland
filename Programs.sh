#!/bin/bash

# Define the list of packages to install
packages=(
  torbrowser-launcher
  uv
  vlc
  libreoffice
  brave-bin
  vlc
  windsurf
  duf
)

# Loop through each package and install using yay
for package in "${packages[@]}"; do
  yay -S --noconfirm "$package"
done
