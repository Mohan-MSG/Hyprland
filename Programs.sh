#!/bin/bash

# Define the list of packages to install
packages=(
  # Web Browsers
  torbrowser-launcher
  
  # Media
  vlc
  obs-studio
  gimp
  inkscape
  gwenview
  
  # Office
  libreoffice-fresh
  
  # System Utilities
  htop
  btop
  duf
  dust
  fastfetch
  ranger
  stacer
  gparted
  gnome-disk-utility
  zoxide
  ntfs-3g
  
  # Development & Productivity
  neovim
  git
  obsidian
  windsurf
  rustup
  uv
  lazygit
  
  # Communication
  whatsapp-nativefier
  telegram-desktop
  vesktop
  
  # Shell & Terminal
  zsh
  zsh-completions
  zsh-syntax-highlighting
  zsh-autosuggestions
  tmux
  fzf
  exa
  bat
  ripgrep
  fd
)

# Function to check if a package is installed
is_package_installed() {
  if pacman -Qi "$1" &> /dev/null || pacman -Qg "$1" &> /dev/null; then
    return 0  # Package is installed
  else
    return 1  # Package is not installed
  fi
}

# Loop through each package and check if it's already installed
for package in "${packages[@]}"; do
  if is_package_installed "$package"; then
    echo "$package is already installed. Skipping..."
  else
    read -p "Do you want to install $package? [y/N] " -n 1 -r
    echo    # move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Installing $package..."
      yay -S --noconfirm "$package"
    else
      echo "Skipping $package installation."
    fi
  fi
done

# Install Rust if rustup was installed
if command -v rustup &> /dev/null; then
  read -p "Do you want to install the latest stable Rust toolchain? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Rust..."
    rustup default stable
    echo "Rust has been installed!"
  fi
fi

# Install Oh My Zsh if zsh was installed
if command -v zsh &> /dev/null; then
  read -p "Do you want to install Oh My Zsh? (highly recommended) [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Install Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    
    # Set Zsh as default shell
    read -p "Do you want to set Zsh as your default shell? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Changing default shell to Zsh..."
      chsh -s $(which zsh)
      echo "Zsh will be your default shell after you log out and back in."
    fi
    
    echo "\nZsh and Oh My Zsh have been installed!"
    echo "After installation, you can customize your .zshrc file and run 'p10k configure' to set up Powerlevel10k."
  fi
fi

echo "\nAll done!"
