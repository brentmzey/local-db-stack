# 🚀 Local DB Stack - Quick Reference

## Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/brentmzey/local-db-stack/main/install.sh)
# Restart terminal after installation
```

**Note:** The installer attempts to install database **client tools** (like `psql`, `redis-cli`) which are used to connect to the databases. The actual database **servers** run in Docker containers via `localdb-up`.

## Commands

| Command | Description |
|---------|-------------|
| `localdb-up` | Start all databases |
| `localdb-down` | Stop all databases (data preserved) |
| `localdb-status` | Show container status |
| `localdb-logs [service]` | View logs (e.g., `localdb-logs postgres`) |
| `localdb-edit` | Edit configuration (.env file) |
| `localdb-wipe` | ⚠️ Stop and DELETE ALL DATA |

## Connection Info

**🔌 All ports use a "1" prefix** to avoid conflicts with standard ports and integration tests.

| Database | Port | Standard Port | URI Template |
|----------|------|---------------|--------------|
| **PostgreSQL** | 15432 | 5432 | `postgresql://local_user:local_password@localhost:15432/local_database` |
| **MySQL** | 13306 | 3306 | `mysql://local_user:local_password@localhost:13306/local_database` |
| **MongoDB** | 17017 | 27017 | `mongodb://local_root:local_rootpassword@localhost:17017/` |
| **Redis** | 16379 | 6379 | `redis://localhost:16379` |
| **Oracle** | 11521 | 1521 | `jdbc:oracle:thin:@//localhost:11521/FREEPDB1` (user: system) |

> To customize ports, run `localdb-edit`, change the port values, then restart with `localdb-down && localdb-up`

## Quick Tests

### PostgreSQL
```bash
docker exec local_postgres psql -U local_user -d local_database -c "SELECT version();"
```

### MySQL
```bash
docker exec local_mysql mysql -ulocal_user -plocal_password -e "SELECT VERSION();"
```

### MongoDB
```bash
docker exec local_mongodb mongosh -u local_root -p local_rootpassword --eval "db.version()"
```

### Redis
```bash
docker exec local_redis redis-cli PING
```

### Oracle
```bash
docker exec local_oracle sqlplus -L system/local_password@//localhost:1521/FREEPDB1 <<< "SELECT 'OK' FROM DUAL;"
```

## Development

```bash
# Clone repo
git clone https://github.com/brentmzey/local-db-stack.git
cd local-db-stack

# Test locally
docker-compose -f assets/docker-compose.yml --env-file assets/.env.example up -d

# Run persistence tests
./test_persistence.sh

# Run connectivity tests
./test_connectivity.sh

# Clean up
docker-compose -f assets/docker-compose.yml --env-file assets/.env.example down -v
```

## Documentation

- **README.md** - User guide and installation instructions
- **DATA_CONSISTENCY.md** - Durability settings and data safety details
- **DEVELOPMENT.md** - Build instructions and contribution guidelines
- **test_persistence.sh** - Automated data persistence testing

## Platform Support

✅ macOS (Intel & Apple Silicon)  
✅ Linux (x86_64 & ARM64)  
✅ WSL2

**Note:** The `docker-compose.yml` has been updated to explicitly set `platform: linux/amd64` for Oracle on ARM-based machines. If you still see platform warnings, the container should generally function correctly.

## Troubleshooting

**Commands don't work after installation:**
```bash
# Reload your shell configuration
source ~/.zshrc    # macOS/Zsh
source ~/.bashrc   # Linux/Bash
```

**Client vs Server Confusion:**
- **Servers** = Database instances running in Docker (via `localdb-up`)
- **Clients** = Tools like `psql`, `mysql` to connect TO servers
- You DON'T need to install PostgreSQL, MySQL servers separately
- You only need client tools (installer tries to install these)

**Containers won't start:**
```bash
docker ps -a  # Check container status
docker logs local_postgres  # Check logs
```

**Port conflicts:**
```bash
# Edit ~/.local-db-stack/.env to change ports
localdb-edit
```

**Reset everything:**
```bash
localdb-wipe  # Deletes all data and volumes
localdb-up    # Fresh start
```

## Data Safety

All databases configured with maximum durability:
- ✅ fsync enabled (PostgreSQL)
- ✅ InnoDB flush-on-commit (MySQL)
- ✅ WiredTiger journaling (MongoDB)
- ✅ AOF + RDB persistence (Redis)
- ✅ Standard durability (Oracle)

See DATA_CONSISTENCY.md for details.

## Support

- GitHub Issues: https://github.com/brentmzey/local-db-stack/issues
- Documentation: https://github.com/brentmzey/local-db-stack
