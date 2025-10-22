# Seamless Database Connectivity

## Overview

The Local DB Stack automatically configures connection files on your system so that database clients and GUIs can connect seamlessly without repetitive password entry or configuration.

## Configured Connection Files

### PostgreSQL - `~/.pgpass`

The `.pgpass` file stores PostgreSQL connection credentials in a secure format.

**Format:**
```
localhost:15432:local_database:local_user:local_password
localhost:15432:*:local_user:local_password
```

**Benefits:**
- ✅ No password prompts when using `psql`
- ✅ Supported by most PostgreSQL GUI tools (pgAdmin, DBeaver, TablePlus)
- ✅ Secure file permissions (600) automatically set

**Usage:**
```bash
# Connect without password prompt
psql -h localhost -p 15432 -U local_user -d local_database

# Or use the helper
localdb-psql
```

### MySQL - `~/.my.cnf`

The `.my.cnf` file contains MySQL client configuration with credentials.

**Format:**
```ini
[client-local-db-stack]
host=localhost
port=13306
user=local_user
password=local_password
database=local_database
```

**Benefits:**
- ✅ No password prompts when using `mysql` CLI
- ✅ Can be used by MySQL Workbench and other tools
- ✅ Isolated section prevents conflicts with other MySQL instances

**Usage:**
```bash
# Connect using the configuration
mysql --defaults-group-suffix=-local-db-stack

# Or use the helper
localdb-mysql
```

### MongoDB - `~/.mongorc.js`

The `.mongorc.js` file contains JavaScript helpers loaded automatically by `mongosh`.

**Content:**
```javascript
var localDbStack = {
    connect: function() {
        return new Mongo("mongodb://local_root:local_rootpassword@localhost:17017/admin?authSource=admin");
    },
    connectionString: "mongodb://local_root:local_rootpassword@localhost:17017/admin?authSource=admin"
};
```

**Benefits:**
- ✅ Quick connection helpers in mongosh
- ✅ Stored connection strings for easy reference
- ✅ Works with MongoDB Compass and other GUI tools

**Usage:**
```bash
# Connect using the connection string
mongosh "mongodb://local_root:local_rootpassword@localhost:17017/admin?authSource=admin"

# Or use the helper
localdb-mongo

# In mongosh, use the helper
db = localDbStack.connect().getDB("mydb")
```

### Redis - `~/.redisclirc`

The `.redisclirc` file contains Redis CLI configuration and notes.

**Content:**
```
# Local DB Stack Redis connection
# Connect with: redis-cli -p 16379
```

**Usage:**
```bash
# Connect to Redis
redis-cli -p 16379

# Or use the helper
localdb-redis
```

## Setup

The connection files are automatically configured during installation. To manually set up or update:

```bash
cd assets
./setup-connection-files.sh

# Or use the shell helper
localdb-setup-connections
```

## GUI Application Configuration

### PostgreSQL GUIs

Most PostgreSQL GUIs respect `~/.pgpass`:

**pgAdmin:**
- Server: localhost
- Port: 15432
- Database: local_database
- Username: local_user
- Password: (leave empty or enter password)
- Save password: Yes

**DBeaver:**
- Connection: PostgreSQL
- Host: localhost
- Port: 15432
- Database: local_database
- Username: local_user
- Password: local_password
- ✓ Save password

**TablePlus:**
- Connection: PostgreSQL
- Host: localhost
- Port: 15432
- User: local_user
- Password: local_password
- Database: local_database

### MySQL GUIs

**MySQL Workbench:**
- Connection Name: Local DB Stack
- Hostname: 127.0.0.1
- Port: 13306
- Username: local_user
- Password: local_password (store in keychain)
- Default Schema: local_database

**DBeaver:**
- Connection: MySQL
- Host: localhost
- Port: 13306
- Database: local_database
- Username: local_user
- Password: local_password

### MongoDB GUIs

**MongoDB Compass:**
- Connection String: `mongodb://local_root:local_rootpassword@localhost:17017/admin?authSource=admin`
- Or use Advanced Connection:
  - Host: localhost
  - Port: 17017
  - Authentication: Username/Password
  - Username: local_root
  - Password: local_rootpassword
  - Authentication Database: admin

**Studio 3T:**
- Connection: New Connection
- Server: localhost
- Port: 17017
- Authentication Mode: Basic
- User Name: local_root
- Password: local_rootpassword
- Authentication DB: admin

### Redis GUIs

**RedisInsight:**
- Host: localhost
- Port: 16379
- Name: Local DB Stack
- No authentication required

**Medis:**
- Host: 127.0.0.1
- Port: 16379

## Connection Information Reference

View all connection information anytime:

```bash
# Show connection info
localdb-connect

# Or directly view the file
cat ~/.local-db-stack/CONNECTION_INFO.txt
```

This displays:
- Connection strings for all databases
- CLI commands to connect
- Host, port, user, password for each database
- Data persistence location

## Shell Helper Functions

The shell configuration provides convenient helpers:

```bash
# PostgreSQL
localdb-psql                    # Connect to PostgreSQL
localdb-psql -c "SELECT 1;"     # Run query

# MySQL
localdb-mysql                   # Connect to MySQL
localdb-mysql -e "SHOW DATABASES;"

# MongoDB
localdb-mongo                   # Connect to MongoDB
localdb-mongo --eval "db.version()"

# Redis
localdb-redis                   # Connect to Redis
localdb-redis PING              # Run command

# View connection info
localdb-connect                 # Show all connection details
```

## Security Considerations

### File Permissions

All connection files are automatically set with secure permissions:

```bash
# Verify permissions
ls -l ~/.pgpass        # Should be 600 (rw-------)
ls -l ~/.my.cnf        # Should be 600 (rw-------)
ls -l ~/.mongorc.js    # Default permissions OK
```

### Password Storage

- ✅ Passwords are stored locally in your home directory
- ✅ Files are readable only by your user account
- ✅ Not exposed to other users on shared systems
- ⚠️ Consider using more secure credential storage for production

### Network Security

- ✅ Databases bind only to localhost (not exposed to network)
- ✅ Custom ports reduce accidental conflicts
- ✅ No external access by default

## Environment Variables

Connection helpers use environment variables from `.env`:

```bash
LOCAL_POSTGRES_PORT=15432
LOCAL_POSTGRES_USER=local_user
LOCAL_POSTGRES_PASS=local_password
LOCAL_POSTGRES_DB=local_database

LOCAL_MYSQL_PORT=13306
LOCAL_MYSQL_USER=local_user
LOCAL_MYSQL_PASS=local_password
LOCAL_MYSQL_DB=local_database

LOCAL_MONGODB_PORT=17017
LOCAL_MONGO_USER=local_root
LOCAL_MONGO_PASS=local_rootpassword

LOCAL_REDIS_PORT=16379

LOCAL_ORACLE_PORT=11521
LOCAL_ORACLE_PASS=local_password
```

## Troubleshooting

### PostgreSQL Password Still Prompted

1. Check `.pgpass` exists: `ls -l ~/.pgpass`
2. Verify permissions: `chmod 600 ~/.pgpass`
3. Check file format (no extra spaces)
4. Ensure port/user/db match

### MySQL Configuration Not Working

1. Verify section name: `[client-local-db-stack]`
2. Check file: `cat ~/.my.cnf`
3. Test: `mysql --defaults-group-suffix=-local-db-stack --print-defaults`

### MongoDB Connection Refused

1. Verify MongoDB is running: `localdb-status`
2. Check port: `docker-compose ps mongodb`
3. Test connection: `mongosh "mongodb://localhost:17017"`

### GUI Not Using Saved Credentials

Some GUIs may require explicit credential entry even with config files. This is normal and the credentials can be saved within the GUI application.

## Best Practices

1. **Update After Credential Changes**: Run `localdb-setup-connections` after modifying `.env`
2. **Backup Config Files**: Include `~/.pgpass`, `~/.my.cnf` in your backup routine
3. **Secure Permissions**: Regularly verify file permissions remain secure
4. **Use Helpers**: Prefer `localdb-psql` over manual `psql` commands for consistency
5. **Document Custom Configs**: If you modify connection files manually, document changes

## Re-initialization

To regenerate all connection files:

```bash
# Re-run setup
localdb-setup-connections

# Or from assets directory
cd ~/.local-db-stack
./setup-connection-files.sh
```

This will:
1. Read current configuration from `.env`
2. Update `~/.pgpass`, `~/.my.cnf`, `~/.mongorc.js`, `~/.redisclirc`
3. Generate updated `CONNECTION_INFO.txt`
4. Set correct file permissions
