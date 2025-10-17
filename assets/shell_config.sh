# START LOCAL DB STACK
export LOCAL_DB_STACK_DIR="$HOME/.local-db-stack"
localdb-up() { docker-compose --project-directory "$LOCAL_DB_STACK_DIR" -f "$LOCAL_DB_STACK_DIR/docker-compose.yml" up -d; }
localdb-down() { docker-compose --project-directory "$LOCAL_DB_STACK_DIR" -f "$LOCAL_DB_STACK_DIR/docker-compose.yml" down "$@"; }
localdb-logs() { docker-compose --project-directory "$LOCAL_DB_STACK_DIR" -f "$LOCAL_DB_STACK_DIR/docker-compose.yml" logs -f "$@"; }
localdb-status() { docker-compose --project-directory "$LOCAL_DB_STACK_DIR" -f "$LOCAL_DB_STACK_DIR/docker-compose.yml" ps; }
localdb-edit() { ${EDITOR:-vim} "$LOCAL_DB_STACK_DIR/.env"; }
alias localdb-wipe='localdb-down -v'
# END LOCAL DB STACK
