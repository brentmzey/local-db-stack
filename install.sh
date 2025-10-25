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

# Function to check and install client tools
install_client_tool() {
    local tool_name="$1"
    local check_command="$2"
    local macos_install_command="$3"
    local linux_install_command="$4"

    info "Checking for $tool_name..."
    if ! command -v $check_command &> /dev/null; then
        info "$tool_name not found. Attempting to install..."
        if [[ "$(uname)" == "Darwin" ]]; then
            if command -v brew &> /dev/null; then
                eval "$macos_install_command" || error "Failed to install $tool_name. Please install manually."
            else
                error "Homebrew not found. Please install Homebrew (https://brew.sh) and then install $tool_name manually, or install $tool_name using another method."
            fi
        elif [[ "$(uname)" == "Linux" ]]; then
            if command -v apt &> /dev/null; then
                eval "$linux_install_command" || error "Failed to install $tool_name. Please install manually."
            else
                error "apt not found. Please install $tool_name manually using your distribution's package manager."
            fi
        else
            error "Unsupported OS for automatic $tool_name installation. Please install $tool_name manually."
        fi
        success "$tool_name installed successfully."
    else
        success "$tool_name is already installed."
    fi
}

# Install PostgreSQL client (psql)
install_client_tool "PostgreSQL client (psql)" "psql" "brew install libpq" "sudo apt update && sudo apt install -y postgresql-client"

# Install Redis client (redis-cli)
install_client_tool "Redis client (redis-cli)" "redis-cli" "brew install redis" "sudo apt update && sudo apt install -y redis-tools"

info "Note: Oracle's sqlplus client is complex to install universally and is not automatically installed. You can connect via GUI tools or 'docker exec' into the Oracle container."

mkdir -p "$INSTALL_DIR"
curl -sL "$SOURCE_URL/assets/docker-compose.yml" -o "$INSTALL_DIR/docker-compose.yml" || error "Failed to download docker-compose.yml"
curl -sL "$SOURCE_URL/assets/.env.example" -o "$INSTALL_DIR/.env.example" || error "Failed to download .env.example"
curl -sL "$SOURCE_URL/assets/setup-connection-files.sh" -o "$INSTALL_DIR/setup-connection-files.sh" || error "Failed to download setup-connection-files.sh"
curl -sL "$SOURCE_URL/assets/init-data-dirs.sh" -o "$INSTALL_DIR/init-data-dirs.sh" || error "Failed to download init-data-dirs.sh"
chmod +x "$INSTALL_DIR/setup-connection-files.sh" "$INSTALL_DIR/init-data-dirs.sh"

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
info "Initializing data directories and connection files..."
bash "$INSTALL_DIR/init-data-dirs.sh"
bash "$INSTALL_DIR/setup-connection-files.sh"

echo ""
echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[33m  PORT CONFIGURATION NOTICE\033[0m"
echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "  To avoid conflicts with your integration tests and other services,"
echo "  all databases use NON-STANDARD ports with a '1' prefix:"
echo ""
echo "    PostgreSQL:  15432  (standard: 5432)"
echo "    MySQL:       13306  (standard: 3306)"
echo "    MongoDB:     17017  (standard: 27017)"
echo "    Redis:       16379  (standard: 6379)"
echo "    Oracle:      11521  (standard: 1521)"
echo ""
echo "  To customize ports, edit: $INSTALL_DIR/.env"
echo "  Then restart databases with: localdb-down && localdb-up"
echo ""
echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

info "Restart your terminal or run 'source $PROFILE_FILE' to use the new commands."
info ""
info "Available commands:"
info "  localdb-up              - Start all databases"
info "  localdb-down            - Stop all databases"
info "  localdb-status          - Check database status"
info "  localdb-connect         - Show connection information"
info "  localdb-psql            - Connect to PostgreSQL"
info "  localdb-mysql           - Connect to MySQL"
info "  localdb-mongo           - Connect to MongoDB"
info "  localdb-redis           - Connect to Redis"
info "  localdb-edit            - Edit configuration (.env file)"
info "  localdb-data-dir        - Show data directory location"
