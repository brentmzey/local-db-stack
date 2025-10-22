#!/usr/bin/env bash
# Initialize data directories and migrate from Docker volumes if needed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-${SCRIPT_DIR}/.env}"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

DATA_DIR="${LOCAL_DB_DATA_DIR:-$HOME/.local-db-stack/data}"

echo "Initializing Local DB Stack data directories..."
echo "Data location: $DATA_DIR"

# Create data directories
mkdir -p "$DATA_DIR"/{postgres,mysql,mongodb,mongodb-config,redis,oracle}

echo "✓ Data directories created"

# Check if old Docker volumes exist and offer to migrate
OLD_VOLUMES=$(docker volume ls --filter name=local_db_stack --format "{{.Name}}" 2>/dev/null || true)

if [ -n "$OLD_VOLUMES" ]; then
    echo ""
    echo "Found existing Docker volumes from previous installation:"
    echo "$OLD_VOLUMES"
    echo ""
    read -p "Do you want to migrate data from Docker volumes to $DATA_DIR? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Migrating data from Docker volumes..."
        
        # Stop containers if running
        cd "$SCRIPT_DIR"
        docker-compose down 2>/dev/null || true
        
        # Migrate each volume
        for volume in $OLD_VOLUMES; do
            case "$volume" in
                *postgres*)
                    echo "Migrating PostgreSQL data..."
                    docker run --rm -v "$volume:/from" -v "$DATA_DIR/postgres:/to" alpine sh -c "cp -av /from/. /to/" || true
                    ;;
                *mysql*)
                    echo "Migrating MySQL data..."
                    docker run --rm -v "$volume:/from" -v "$DATA_DIR/mysql:/to" alpine sh -c "cp -av /from/. /to/" || true
                    ;;
                *mongodb_data*)
                    echo "Migrating MongoDB data..."
                    docker run --rm -v "$volume:/from" -v "$DATA_DIR/mongodb:/to" alpine sh -c "cp -av /from/. /to/" || true
                    ;;
                *mongodb_config*)
                    echo "Migrating MongoDB config..."
                    docker run --rm -v "$volume:/from" -v "$DATA_DIR/mongodb-config:/to" alpine sh -c "cp -av /from/. /to/" || true
                    ;;
                *redis*)
                    echo "Migrating Redis data..."
                    docker run --rm -v "$volume:/from" -v "$DATA_DIR/redis:/to" alpine sh -c "cp -av /from/. /to/" || true
                    ;;
                *oracle*)
                    echo "Migrating Oracle data..."
                    docker run --rm -v "$volume:/from" -v "$DATA_DIR/oracle:/to" alpine sh -c "cp -av /from/. /to/" || true
                    ;;
            esac
        done
        
        echo "✓ Data migration complete"
        echo ""
        read -p "Do you want to remove old Docker volumes? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$OLD_VOLUMES" | xargs docker volume rm
            echo "✓ Old volumes removed"
        fi
    fi
fi

echo ""
echo "Data directory initialization complete!"
echo "Location: $DATA_DIR"
echo ""
echo "Directory structure:"
ls -lh "$DATA_DIR"
