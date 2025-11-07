#!/bin/bash

# Define the list of packages to install
packages=(
  # Web Browsers
  torbrowser-launcher
  
  # Media
  vlc
  vlc-plugin-ffmpeg
  vlc-plugin-mpeg2
  vlc-plugin-x264
  vlc-plugin-x265
  vlc-plugin-ass
  vlc-plugin-matroska
  vlc-plugin-dvd
  vlc-plugin-bluray
  vlc-plugin-srt
  vlc-plugin-soxr
  libdvdcss
  libbluray
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
  sddm-silent-theme
  
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

# System Configuration
echo -e "\nConfiguring system settings..."

# Configure SDDM with silent theme and virtual keyboard
echo -e "\nConfiguring SDDM..."

# Check if SDDM is installed
if ! command -v sddm &> /dev/null; then
    echo "SDDM is not installed. Installing SDDM..."
    sudo pacman -S --noconfirm sddm
    echo "SDDM installed successfully!"
fi

# Ensure SDDM service is enabled
if ! systemctl is-enabled sddm &> /dev/null; then
    echo "Enabling SDDM service..."
    sudo systemctl enable sddm
    echo "SDDM service enabled!"
fi

# Configure SDDM theme
if [ -d /etc/sddm.conf.d/ ]; then
    echo "Configuring SDDM with silent theme..."
    
    # Create theme directory if it doesn't exist
    sudo mkdir -p /usr/share/sddm/themes/silent
    
    # Create SDDM configuration
    sudo bash -c 'cat > /etc/sddm.conf.d/10-silent-theme.conf << EOL
# SDDM configuration for silent theme with virtual keyboard
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=silent
CursorTheme=breeze_cursors
Font="Noto Sans,10,-1,0,50,0,0,0,0,0"

[Users]
MaximumUid=65000
MinimumUid=1000

[Autologin]
Relogin=false
Session=

[General]
HaltCommand=
RebootCommand=
EOL'
    
    # Set correct permissions
    sudo chmod 644 /etc/sddm.conf.d/10-silent-theme.conf
    
    echo "SDDM configuration updated successfully!"
    echo "Note: You may need to restart your system for all changes to take effect."
else
    echo "Warning: /etc/sddm.conf.d/ directory not found. SDDM might not be properly installed."
    echo "Please install SDDM and try again."
fi

# Set GRUB timeout to -1 (no timeout)
if [ -f /etc/default/grub ]; then
    echo "Setting GRUB timeout to -1..."
    sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=-1/' /etc/default/grub
    echo "Updating GRUB configuration..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    echo "GRUB configuration updated successfully!"
else
    echo "Warning: /etc/default/grub not found. Skipping GRUB configuration."
fi

# Install Sekiro GRUB theme
echo -e "\nInstalling Sekiro GRUB theme..."
if [ -d "/boot/grub" ] || [ -d "/boot/grub2" ]; then
    THEME_DIR="/usr/share/grub/themes"
    THEME_NAME="sekiro"
    
    echo "Cloning Sekiro GRUB theme..."
    if [ ! -d "${THEME_DIR}/${THEME_NAME}" ]; then
        sudo mkdir -p "${THEME_DIR}"
        sudo git clone https://github.com/semimqmo/sekiro_grub_theme.git "${THEME_DIR}/${THEME_NAME}"
        
        # Update GRUB configuration to use the new theme
        if [ -f "/etc/default/grub" ]; then
            echo "Configuring GRUB to use Sekiro theme..."
            # Backup original GRUB config
            sudo cp /etc/default/grub /etc/default/grub.bak
            
            # Update GRUB config
            sudo sed -i 's/^GRUB_THEME=.*/GRUB_THEME="'${THEME_DIR//\/\/}/\/themes\/${THEME_NAME//\/\/}/theme/'"/' /etc/default/grub
            
            # Update GRUB
            if command -v update-grub &> /dev/null; then
                sudo update-grub
            elif command -v grub-mkconfig &> /dev/null; then
                sudo grub-mkconfig -o /boot/grub/grub.cfg
            elif command -v grub2-mkconfig &> /dev/null; then
                sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            fi
            
            echo "Sekiro GRUB theme installed and configured successfully!"
        else
            echo "Warning: Could not find GRUB configuration. Theme installation may be incomplete."
        fi
    else
        echo "Sekiro GRUB theme is already installed."
    fi
else
    echo "Warning: GRUB directory not found. Skipping Sekiro GRUB theme installation."
fi

echo -e "\nAll done!"
