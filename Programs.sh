#!/bin/bash

# Define the list of packages to install
packages=(
  firefox
  kdeconnect
  torbrowser-launcher
)

# Loop through each package and install using yay
for package in "${packages[@]}"; do
  yay -S --noconfirm "$package"
done

