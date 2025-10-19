# Development Guide - Local DB Stack

## 🚀 Pick Up From Here

**Current Status:** ✅ Fully functional with maximum data consistency guarantees

**Last Updated:** October 17, 2025

### What's Complete
- ✅ All 5 databases configured with durability-first settings
- ✅ Multi-platform Docker Compose configuration (macOS, Linux, WSL2)
- ✅ Health checks on all services
- ✅ Automated persistence testing (`test_persistence.sh`)
- ✅ Installation script with shell integration
- ✅ Comprehensive documentation

### Quick Start for Development

```bash
# Clone the repository
git clone https://github.com/brentmzey/local-db-stack.git
cd local-db-stack

# Test the stack locally
docker-compose -f assets/docker-compose.yml --env-file assets/.env.example up -d

# Check status
docker-compose -f assets/docker-compose.yml --env-file assets/.env.example ps

# Run persistence tests
./test_persistence.sh

# Stop and clean up
docker-compose -f assets/docker-compose.yml --env-file assets/.env.example down -v
```

### Next Steps / TODO

- [ ] Add Oracle healthcheck improvements for faster startup detection
- [ ] Create automated CI/CD testing for all platforms
- [ ] Add database backup/restore scripts
- [ ] Create docker-compose profiles for selective database startup
- [ ] Add monitoring/metrics collection (Prometheus/Grafana)
- [ ] Create migration guide from other local DB setups
- [ ] Add database seeding scripts for common test data
- [ ] Create Visual Studio Code devcontainer integration

---

## 🏗️ Building & Running Multi-Platform

### Architecture Support

This stack supports:
- **x86_64/amd64** - Intel/AMD processors (most servers and older Macs)
- **arm64/aarch64** - Apple Silicon (M1/M2/M3), ARM servers, Raspberry Pi 4+

### Platform-Specific Notes

#### Apple Silicon (M1/M2/M3 Macs)

All images in this stack support ARM64 natively:
- ✅ `postgres:16-alpine` - Native ARM64
- ✅ `mysql:8.0` - Native ARM64
- ✅ `mongo:7` - Native ARM64
- ✅ `redis:7-alpine` - Native ARM64
- ⚠️ `container-registry.oracle.com/database/free:latest` - Multi-arch (may show platform warning but works)

**Oracle Warning:** You may see `"platform (linux/amd64) does not match detected host platform (linux/arm64)"` - this is cosmetic. Oracle Database Free runs via emulation and works correctly, though initial startup takes 2-3 minutes.

#### Intel/AMD (x86_64)

All images work natively on Intel/AMD processors with no emulation or warnings.

#### Linux ARM64 (Raspberry Pi, ARM servers)

Most images work natively. Oracle Database Free may have limited support on ARM Linux - consider removing it from the stack if not needed.

### Testing Multi-Platform Locally

#### Using Docker Buildx (for testing image compatibility)

```bash
# Check available platforms
docker buildx ls

# Test pulling images for specific platform
docker pull --platform linux/amd64 postgres:16-alpine
docker pull --platform linux/arm64 postgres:16-alpine

# Verify image architecture
docker image inspect postgres:16-alpine | grep Architecture
```

#### Platform-Specific Compose Override

Create a `docker-compose.override.yml` for platform-specific tweaks:

```yaml
# docker-compose.override.yml (example for ARM64 without Oracle)
version: "3.8"
services:
  oracle:
    deploy:
      replicas: 0  # Disable Oracle on ARM if needed
```

---

## 🔧 Development Workflow

### Directory Structure

```
local-db-stack/
├── assets/
│   ├── docker-compose.yml      # Main database stack configuration
│   ├── .env.example            # Default environment variables
│   └── shell_config.sh         # Shell functions (localdb-* commands)
├── Formula/
│   └── local-db-stack.rb       # Homebrew formula (future release)
├── DATA_CONSISTENCY.md         # Durability configuration details
├── DEVELOPMENT.md              # This file
├── README.md                   # User-facing documentation
├── install.sh                  # Installation script
└── test_persistence.sh         # Automated persistence testing
```

### Making Changes

#### Modifying Database Configuration

1. Edit `assets/docker-compose.yml`
2. Validate syntax:
   ```bash
   docker-compose -f assets/docker-compose.yml config --quiet
   ```
3. Test locally with a clean state:
   ```bash
   docker-compose -f assets/docker-compose.yml --env-file assets/.env.example down -v
   docker-compose -f assets/docker-compose.yml --env-file assets/.env.example up -d
   ```
4. Run persistence tests:
   ```bash
   ./test_persistence.sh
   ```
5. Commit changes to git

#### Adding a New Database

1. Add service definition to `assets/docker-compose.yml`
2. Add corresponding volume definition
3. Add environment variables to `assets/.env.example`
4. Add health check for the service
5. Update `test_persistence.sh` to test the new database
6. Document connection details in `README.md`
7. Update `DATA_CONSISTENCY.md` with durability settings

#### Testing Installation Script

```bash
# Test the installer in a clean environment
# (Best done in a VM or Docker container)

# Option 1: Test curl installation
bash <(cat install.sh)

# Option 2: Test with actual GitHub raw URL
bash <(curl -s https://raw.githubusercontent.com/brentmzey/local-db-stack/main/install.sh)

# Verify shell functions are loaded
source ~/.zshrc  # or ~/.bashrc
localdb-up
localdb-status
localdb-down
```

---

## 🧪 Testing

### Automated Testing

Run the full persistence test suite:
```bash
./test_persistence.sh
```

### Manual Testing Checklist

- [ ] All containers start successfully
- [ ] All health checks pass within expected timeframe
- [ ] Can connect to each database from host machine
- [ ] Data persists after `docker-compose restart`
- [ ] Data persists after `docker-compose down && docker-compose up`
- [ ] Volumes are created with correct names
- [ ] Environment variables override defaults correctly
- [ ] No port conflicts with standard database ports

### Platform-Specific Testing

**macOS (Intel):**
```bash
# Should see no platform warnings
docker-compose -f assets/docker-compose.yml up 2>&1 | grep -i "platform"
```

**macOS (Apple Silicon):**
```bash
# Oracle warning is expected and harmless
docker-compose -f assets/docker-compose.yml up 2>&1 | grep -i "platform"
# Should see: "oracle: platform (linux/amd64) does not match (linux/arm64/v8)"
```

**Linux (x86_64):**
```bash
# No platform warnings expected
docker-compose -f assets/docker-compose.yml up
```

---

## 📦 Release Process

### Version Strategy

This project uses semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR:** Breaking changes to configuration or commands
- **MINOR:** New databases, new features, significant improvements
- **PATCH:** Bug fixes, documentation updates, minor tweaks

### Creating a Release

1. **Update version references**
   ```bash
   # Update Formula/local-db-stack.rb version
   # Update README.md if needed
   ```

2. **Create git tag**
   ```bash
   git tag -a v1.2.0 -m "Release 1.2.0: Add data consistency guarantees"
   git push origin v1.2.0
   ```

3. **Generate checksum for Homebrew formula**
   ```bash
   # After creating GitHub release with tarball
   curl -L https://github.com/brentmzey/local-db-stack/archive/refs/tags/v1.2.0.tar.gz | shasum -a 256
   # Update Formula/local-db-stack.rb with new sha256
   ```

4. **Update installation instructions**
   - Verify raw GitHub URLs work
   - Test installation on clean system

---

## 🐛 Troubleshooting Development Issues

### Docker Compose Version Conflicts

If you see: `the attribute 'version' is obsolete`
- This is a warning, not an error
- We've removed the version field (modern docker-compose doesn't need it)

### Volume Persistence Issues

If data doesn't persist:
```bash
# Check volumes exist
docker volume ls | grep local_

# Inspect volume
docker volume inspect local_postgres_data

# Check mount points in containers
docker inspect local_postgres | grep -A 10 Mounts
```

### Oracle Platform Warning on ARM64

Expected warning: `"platform (linux/amd64) does not match (linux/arm64)"`
- This is cosmetic and safe to ignore
- Oracle will run via Rosetta 2 emulation on macOS
- Takes 2-3 minutes for first startup
- Check logs: `docker logs local_oracle`

### Health Check Failures

```bash
# Check health status
docker inspect local_postgres | grep -A 5 Health

# View health check logs
docker inspect local_postgres --format='{{json .State.Health}}' | jq

# Manually test health check command
docker exec local_postgres pg_isready -U local_user
```

---

## 🔐 Security Notes for Development

- Default credentials are **NOT secure** - only for local development
- Never expose database ports publicly
- Use `.env` file for custom credentials
- Don't commit `.env` files with real credentials
- For production-like testing, override passwords via environment

---

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)
- [MySQL Docker Hub](https://hub.docker.com/_/mysql)
- [MongoDB Docker Hub](https://hub.docker.com/_/mongo)
- [Redis Docker Hub](https://hub.docker.com/_/redis)
- [Oracle Database Free](https://container-registry.oracle.com/ords/f?p=113:4:::::P4_REPOSITORY,AI_REPOSITORY,P4_REPOSITORY_NAME,AI_REPOSITORY_NAME:9,9,Oracle%20Database%20Free,Oracle%20Database%20Free)

---

## 🤝 Contributing

When contributing:
1. Test on both Intel and ARM64 if possible
2. Run `test_persistence.sh` before committing
3. Update documentation for any configuration changes
4. Follow existing code style and structure
5. Keep data consistency as the highest priority

---

## 📝 Notes

- All databases configured for **maximum durability** over performance
- This is intentional for local development data safety
- See `DATA_CONSISTENCY.md` for detailed rationale
- Performance impact is typically 10-40% but ensures zero data loss
