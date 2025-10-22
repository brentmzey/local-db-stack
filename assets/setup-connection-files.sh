#!/usr/bin/env bash
# Setup connection configuration files for seamless database access
# This script configures ~/.pgpass, ~/.my.cnf, ~/.mongorc.js and other connection files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-${SCRIPT_DIR}/.env}"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "Warning: .env file not found at $ENV_FILE, using defaults"
fi

# Set defaults
POSTGRES_PORT="${LOCAL_POSTGRES_PORT:-15432}"
POSTGRES_USER="${LOCAL_POSTGRES_USER:-local_user}"
POSTGRES_PASS="${LOCAL_POSTGRES_PASS:-local_password}"
POSTGRES_DB="${LOCAL_POSTGRES_DB:-local_database}"

MYSQL_PORT="${LOCAL_MYSQL_PORT:-13306}"
MYSQL_USER="${LOCAL_MYSQL_USER:-local_user}"
MYSQL_PASS="${LOCAL_MYSQL_PASS:-local_password}"
MYSQL_DB="${LOCAL_MYSQL_DB:-local_database}"

MONGODB_PORT="${LOCAL_MONGODB_PORT:-17017}"
MONGO_USER="${LOCAL_MONGO_USER:-local_root}"
MONGO_PASS="${LOCAL_MONGO_PASS:-local_rootpassword}"

REDIS_PORT="${LOCAL_REDIS_PORT:-16379}"

ORACLE_PORT="${LOCAL_ORACLE_PORT:-11521}"
ORACLE_PASS="${LOCAL_ORACLE_PASS:-local_password}"

echo "Setting up database connection files..."

# PostgreSQL - ~/.pgpass
PGPASS_FILE="$HOME/.pgpass"
PGPASS_ENTRY="localhost:${POSTGRES_PORT}:${POSTGRES_DB}:${POSTGRES_USER}:${POSTGRES_PASS}"
PGPASS_WILDCARD="localhost:${POSTGRES_PORT}:*:${POSTGRES_USER}:${POSTGRES_PASS}"

if [ -f "$PGPASS_FILE" ]; then
    # Remove existing entries for this port
    grep -v "localhost:${POSTGRES_PORT}:" "$PGPASS_FILE" > "${PGPASS_FILE}.tmp" || true
    mv "${PGPASS_FILE}.tmp" "$PGPASS_FILE"
fi

echo "$PGPASS_ENTRY" >> "$PGPASS_FILE"
echo "$PGPASS_WILDCARD" >> "$PGPASS_FILE"
chmod 600 "$PGPASS_FILE"
echo "✓ PostgreSQL connection configured in ~/.pgpass"

# MySQL - ~/.my.cnf
MYCNF_FILE="$HOME/.my.cnf"
MYCNF_SECTION="[client-local-db-stack]"

# Create or update the local-db-stack section
if [ -f "$MYCNF_FILE" ]; then
    # Remove existing local-db-stack section
    sed -i.bak '/\[client-local-db-stack\]/,/^$/d' "$MYCNF_FILE"
fi

cat >> "$MYCNF_FILE" << EOF

$MYCNF_SECTION
host=localhost
port=${MYSQL_PORT}
user=${MYSQL_USER}
password=${MYSQL_PASS}
database=${MYSQL_DB}

EOF
chmod 600 "$MYCNF_FILE"
echo "✓ MySQL connection configured in ~/.my.cnf (use: mysql --defaults-group-suffix=-local-db-stack)"

# MongoDB - ~/.mongorc.js
MONGORC_FILE="$HOME/.mongorc.js"
MONGO_CONN_STRING="mongodb://${MONGO_USER}:${MONGO_PASS}@localhost:${MONGODB_PORT}/admin?authSource=admin"

# Add connection helper to mongorc
if ! grep -q "localDbStack" "$MONGORC_FILE" 2>/dev/null; then
    cat >> "$MONGORC_FILE" << 'EOF'

// Local DB Stack connection helper
var localDbStack = {
    connect: function() {
        return new Mongo("mongodb://${MONGO_USER}:${MONGO_PASS}@localhost:${MONGODB_PORT}/admin?authSource=admin");
    },
    connectionString: "mongodb://${MONGO_USER}:${MONGO_PASS}@localhost:${MONGODB_PORT}/admin?authSource=admin"
};

// Usage: db = localDbStack.connect().getDB("your_database_name")
EOF
    # Replace placeholders
    sed -i.bak "s/\${MONGO_USER}/${MONGO_USER}/g; s/\${MONGO_PASS}/${MONGO_PASS}/g; s/\${MONGODB_PORT}/${MONGODB_PORT}/g" "$MONGORC_FILE"
    rm -f "${MONGORC_FILE}.bak"
fi
echo "✓ MongoDB connection helpers configured in ~/.mongorc.js"

# Redis - ~/.redisclirc
REDISCLIRC_FILE="$HOME/.redisclirc"
if ! grep -q "# Local DB Stack" "$REDISCLIRC_FILE" 2>/dev/null; then
    cat >> "$REDISCLIRC_FILE" << EOF

# Local DB Stack Redis connection
# Connect with: redis-cli -p ${REDIS_PORT}
EOF
fi
echo "✓ Redis connection info added to ~/.redisclirc"

# Create connection info file
CONN_INFO_FILE="${SCRIPT_DIR}/CONNECTION_INFO.txt"
cat > "$CONN_INFO_FILE" << EOF
# DATABASE CONNECTION INFORMATION
# Generated: $(date)

All databases are configured for seamless connection from local tools and GUIs.

## PostgreSQL
Host: localhost
Port: ${POSTGRES_PORT}
User: ${POSTGRES_USER}
Password: ${POSTGRES_PASS}
Database: ${POSTGRES_DB}

Connection string: postgresql://${POSTGRES_USER}:${POSTGRES_PASS}@localhost:${POSTGRES_PORT}/${POSTGRES_DB}
CLI: psql -h localhost -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d ${POSTGRES_DB}
     (password configured in ~/.pgpass - no password prompt needed)

## MySQL
Host: localhost
Port: ${MYSQL_PORT}
User: ${MYSQL_USER}
Password: ${MYSQL_PASS}
Database: ${MYSQL_DB}

Connection string: mysql://${MYSQL_USER}:${MYSQL_PASS}@localhost:${MYSQL_PORT}/${MYSQL_DB}
CLI: mysql --defaults-group-suffix=-local-db-stack
     (credentials configured in ~/.my.cnf)

## MongoDB
Host: localhost
Port: ${MONGODB_PORT}
User: ${MONGO_USER}
Password: ${MONGO_PASS}
Auth Database: admin

Connection string: ${MONGO_CONN_STRING}
CLI: mongosh "${MONGO_CONN_STRING}"

## Redis
Host: localhost
Port: ${REDIS_PORT}
No authentication required

CLI: redis-cli -p ${REDIS_PORT}

## Oracle Database
Host: localhost
Port: ${ORACLE_PORT}
SID: FREE
User: system
Password: ${ORACLE_PASS}

Connection string: system/${ORACLE_PASS}@localhost:${ORACLE_PORT}/FREE
CLI: sqlplus system/${ORACLE_PASS}@localhost:${ORACLE_PORT}/FREE

## Data Persistence
All database data is stored in: ${LOCAL_DB_DATA_DIR:-$HOME/.local-db-stack/data}
This location is consistent regardless of where docker-compose is run.

## GUI Applications
Most database GUI applications (DBeaver, TablePlus, pgAdmin, etc.) can use the
connection information above. For PostgreSQL, the ~/.pgpass file enables
password-free connections in psql and many GUI tools.

EOF

echo "✓ Connection information saved to ${CONN_INFO_FILE}"
echo ""
echo "Setup complete! Connection files configured:"
echo "  - ~/.pgpass (PostgreSQL)"
echo "  - ~/.my.cnf (MySQL)"
echo "  - ~/.mongorc.js (MongoDB)"
echo "  - ~/.redisclirc (Redis)"
echo ""
echo "You can now connect to databases without password prompts using:"
echo "  PostgreSQL: psql -h localhost -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
echo "  MySQL: mysql --defaults-group-suffix=-local-db-stack"
echo "  MongoDB: mongosh '${MONGO_CONN_STRING}'"
echo "  Redis: redis-cli -p ${REDIS_PORT}"
