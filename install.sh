#!/usr/bin/env bash
# Installer for the Local Database Stack

GITHUB_USER="brentmzey"
GITHUB_REPO="local-db-stack"
INSTALL_DIR="$HOME/.local-db-stack"
SOURCE_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/main"

info() { echo -e "\033[34m[INFO]\033[0m $1"; }
success() { echo -e "\033[32m[SUCCESS]\033[0m $1"; }
error() { echo -e "\033[31m[ERROR]\033[0m $1"; exit 1; }

if ! command -v docker &> /dev/null; then error "Docker is not installed."; fi
if ! command -v docker-compose &> /dev/null; then error "Docker Compose is not installed."; fi

mkdir -p "$INSTALL_DIR"
curl -sL "$SOURCE_URL/assets/docker-compose.yml" -o "$INSTALL_DIR/docker-compose.yml" || error "Failed to download docker-compose.yml"
curl -sL "$SOURCE_URL/assets/.env.example" -o "$INSTALL_DIR/.env.example" || error "Failed to download .env.example"

if [ ! -f "$INSTALL_DIR/.env" ]; then
  cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
fi

PROFILE_FILE=""
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then PROFILE_FILE="$HOME/.zshrc";
elif [ -n "$BASH_VERSION" ] || [ -f "$HOME/.bashrc" ]; then PROFILE_FILE="$HOME/.bashrc";
elif [ -f "$HOME/.profile" ]; then PROFILE_FILE="$HOME/.profile";
else error "Could not find .zshrc, .bashrc, or .profile."; fi

CONFIG_CONTENT=$(curl -sL "$SOURCE_URL/assets/shell_config.sh")
sed -i.bak '/# START LOCAL DB STACK/,/# END LOCAL DB STACK/d' "$PROFILE_FILE"
echo -e "\n$CONFIG_CONTENT" >> "$PROFILE_FILE"

success "Installation complete!"
info "Restart your terminal or run 'source $PROFILE_FILE' to use the new commands."
