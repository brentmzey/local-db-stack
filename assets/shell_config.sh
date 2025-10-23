# START LOCAL DB STACK
export LOCAL_DB_STACK_DIR="$HOME/.local-db-stack"
export LOCAL_DB_DATA_DIR="${LOCAL_DB_DATA_DIR:-$HOME/.local-db-stack/data}"

localdb-help() {
    cat << 'EOF'
Local DB Stack - CLI Commands
==============================

Core Commands:
  localdb-help              Show this help message
  localdb-init              Initialize data directories and connection files
  localdb-up                Start all database containers
  localdb-down              Stop all database containers
  localdb-status            Show status of all containers
  localdb-logs [service]    Show logs (optionally for specific service)
  localdb-wipe              Stop containers and remove volumes (alias for localdb-down -v)

Configuration:
  localdb-edit              Edit environment variables (.env file)
  localdb-connect           Display connection information for all databases
  localdb-data-dir          Show data directory location and contents

Database Client Helpers:
  localdb-psql [args]       Connect to PostgreSQL with psql
  localdb-mysql [args]      Connect to MySQL with mysql client
  localdb-mongo [args]      Connect to MongoDB with mongosh
  localdb-redis [args]      Connect to Redis with redis-cli

Available Services:
  - postgres (port ${LOCAL_POSTGRES_PORT:-15432})
  - mysql (port ${LOCAL_MYSQL_PORT:-13306})
  - mongodb (port ${LOCAL_MONGODB_PORT:-17017})
  - redis (port ${LOCAL_REDIS_PORT:-16379})
  - oracle (port ${LOCAL_ORACLE_PORT:-11521})

Examples:
  localdb-up                Start all databases
  localdb-logs postgres     View PostgreSQL logs
  localdb-psql              Connect to PostgreSQL
  localdb-down -v           Stop and wipe all data

Configuration file: $LOCAL_DB_STACK_DIR/.env
Data directory: $LOCAL_DB_DATA_DIR
EOF
}

localdb-up() { 
    docker-compose --project-directory "$LOCAL_DB_STACK_DIR" -f "$LOCAL_DB_STACK_DIR/docker-compose.yml" up -d
}

localdb-down() { 
    docker-compose --project-directory "$LOCAL_DB_STACK_DIR" -f "$LOCAL_DB_STACK_DIR/docker-compose.yml" down "$@"
}

localdb-logs() { 
    docker-compose --project-directory "$LOCAL_DB_STACK_DIR" -f "$LOCAL_DB_STACK_DIR/docker-compose.yml" logs -f "$@"
}

localdb-status() { 
    docker-compose --project-directory "$LOCAL_DB_STACK_DIR" -f "$LOCAL_DB_STACK_DIR/docker-compose.yml" ps
}

localdb-edit() { 
    ${EDITOR:-vim} "$LOCAL_DB_STACK_DIR/.env"
}

localdb-connect() {
    echo "Database Connection Information:"
    echo "================================"
    cat "$LOCAL_DB_STACK_DIR/CONNECTION_INFO.txt" 2>/dev/null || echo "Run 'localdb-setup-connections' first to generate connection info"
}

localdb-setup-connections() {
    bash "$LOCAL_DB_STACK_DIR/setup-connection-files.sh"
}

localdb-data-dir() {
    echo "Data directory: $LOCAL_DB_DATA_DIR"
    ls -lh "$LOCAL_DB_DATA_DIR" 2>/dev/null || echo "Data directory not initialized. Run 'localdb-init' first."
}

localdb-init() {
    bash "$LOCAL_DB_STACK_DIR/init-data-dirs.sh"
    localdb-setup-connections
}

# PostgreSQL connection helper
localdb-psql() {
    psql -h localhost -p "${LOCAL_POSTGRES_PORT:-15432}" -U "${LOCAL_POSTGRES_USER:-local_user}" -d "${LOCAL_POSTGRES_DB:-local_database}" "$@"
}

# MySQL connection helper
localdb-mysql() {
    mysql --defaults-group-suffix=-local-db-stack "$@"
}

# MongoDB connection helper
localdb-mongo() {
    local port="${LOCAL_MONGODB_PORT:-17017}"
    local user="${LOCAL_MONGO_USER:-local_root}"
    local pass="${LOCAL_MONGO_PASS:-local_rootpassword}"
    mongosh "mongodb://${user}:${pass}@localhost:${port}/admin?authSource=admin" "$@"
}

# Redis connection helper
localdb-redis() {
    redis-cli -p "${LOCAL_REDIS_PORT:-16379}" "$@"
}

alias localdb-wipe='localdb-down -v'
# END LOCAL DB STACK
