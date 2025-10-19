# 🚀 Local DB Stack - Quick Reference

## Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/brentmzey/local-db-stack/main/install.sh)
# Restart terminal after installation
```

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

| Database | Port | URI Template |
|----------|------|--------------|
| **PostgreSQL** | 15432 | `postgresql://local_user:local_password@localhost:15432/local_database` |
| **MySQL** | 13306 | `mysql://local_user:local_password@localhost:13306/local_database` |
| **MongoDB** | 17017 | `mongodb://local_root:local_rootpassword@localhost:17017/` |
| **Redis** | 16379 | `redis://localhost:16379` |
| **Oracle** | 11521 | `jdbc:oracle:thin:@//localhost:11521/FREEPDB1` (user: system) |

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

**Note:** Oracle may show platform warning on Apple Silicon - this is harmless.

## Troubleshooting

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
