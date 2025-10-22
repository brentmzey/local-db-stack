# Data Persistence and Location

## Overview

The Local DB Stack now uses **bind mounts** to a consistent, predictable location on your local machine. This ensures that database data persists in the same location regardless of where or how you run the docker-compose file.

## Data Location

All database data is stored in:
```
$HOME/.local-db-stack/data/
```

This directory structure is:
```
$HOME/.local-db-stack/data/
├── postgres/          # PostgreSQL data
├── mysql/             # MySQL data
├── mongodb/           # MongoDB data
├── mongodb-config/    # MongoDB configuration
├── redis/             # Redis data
└── oracle/            # Oracle database data
```

## Why Bind Mounts Instead of Docker Volumes?

Previously, the project used Docker named volumes (e.g., `local_postgres_data`). While functional, these volumes:
- Store data in Docker's internal directory (`/var/lib/docker/volumes/`)
- Can be difficult to locate and backup
- May cause confusion when running docker-compose from different directories
- Are tied to Docker's volume namespace (prefixed with project name)

**Bind mounts** solve these issues by:
- ✅ Storing data in a **known, predictable location** (`~/.local-db-stack/data/`)
- ✅ Making backups and data inspection easy
- ✅ Ensuring **consistency** regardless of where docker-compose is executed
- ✅ Allowing direct file system access for advanced operations
- ✅ Making it clear where your data lives

## Configuration

The data directory can be customized via the `LOCAL_DB_DATA_DIR` environment variable in `.env`:

```bash
# Default location
LOCAL_DB_DATA_DIR=$HOME/.local-db-stack/data

# Custom location (if needed)
LOCAL_DB_DATA_DIR=/path/to/custom/location
```

## Initialization

Run the initialization script to set up data directories:

```bash
cd assets
./init-data-dirs.sh
```

Or use the shell helper (after installation):
```bash
localdb-init
```

This script will:
1. Create all necessary data directories
2. Detect existing Docker volumes from previous installations
3. Offer to migrate data from Docker volumes to bind mounts
4. Optionally remove old Docker volumes after migration

## Migration from Docker Volumes

If you have existing data in Docker volumes, the `init-data-dirs.sh` script can automatically migrate it:

1. Stop running containers: `localdb-down`
2. Run: `./init-data-dirs.sh` (or `localdb-init`)
3. Follow the prompts to migrate data
4. Optionally remove old volumes

The migration safely copies all data from Docker volumes to the new bind mount location.

## Backup and Restore

### Backup

Since data is in a known location, backups are straightforward:

```bash
# Full backup
tar -czf localdb-backup-$(date +%Y%m%d).tar.gz ~/.local-db-stack/data/

# Individual database backup
tar -czf postgres-backup-$(date +%Y%m%d).tar.gz ~/.local-db-stack/data/postgres/

# Or use rsync for incremental backups
rsync -av ~/.local-db-stack/data/ /path/to/backup/location/
```

### Restore

```bash
# Stop databases
localdb-down

# Restore from backup
tar -xzf localdb-backup-20250122.tar.gz -C ~/

# Start databases
localdb-up
```

## Data Inspection

You can directly inspect database files:

```bash
# List PostgreSQL data
ls -lh ~/.local-db-stack/data/postgres/

# Check MySQL data size
du -sh ~/.local-db-stack/data/mysql/

# View all database data sizes
du -sh ~/.local-db-stack/data/*/
```

## Security Note

Database data directories contain sensitive information. The initialization script sets appropriate permissions, but ensure:
- The `~/.local-db-stack/data/` directory is **not** world-readable
- Backup files are stored securely
- Access is restricted to your user account

```bash
# Verify permissions (should be 755 or 700)
ls -ld ~/.local-db-stack/data/
```

## Troubleshooting

### Permission Errors

If you encounter permission errors:

```bash
# Check ownership
ls -l ~/.local-db-stack/data/

# Fix permissions (be careful!)
sudo chown -R $USER:$USER ~/.local-db-stack/data/
chmod -R 755 ~/.local-db-stack/data/
```

### Data Not Persisting

1. Verify the data directory exists: `ls -la ~/.local-db-stack/data/`
2. Check docker-compose is using the correct environment: `docker-compose config`
3. Ensure `.env` file has correct `LOCAL_DB_DATA_DIR` value

### Moving Data Location

To change the data directory:

1. Stop databases: `localdb-down`
2. Move data: `mv ~/.local-db-stack/data /new/location/`
3. Update `.env`: `LOCAL_DB_DATA_DIR=/new/location/data`
4. Start databases: `localdb-up`

## Best Practices

1. **Regular Backups**: Set up automated backups of `~/.local-db-stack/data/`
2. **Disk Space**: Monitor disk space, especially for Oracle (can grow large)
3. **Clean Unused Data**: Periodically review and clean up test databases
4. **Version Control**: Never commit the `data/` directory to git (already in `.gitignore`)
5. **Separate Development Data**: Consider using different data directories for different projects if needed
