<div align="center">

# 📦 Local Database Stack

### *The Complete Local Development Database Solution*

**A distributable, namespaced database environment for macOS, Linux, and WSL2**  
*Install once. Run anywhere. Never conflicts with your projects.*

[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20WSL2-lightgrey.svg)](https://github.com/brentmzey/local-db-stack)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Databases](https://img.shields.io/badge/databases-5-green.svg)](https://github.com/brentmzey/local-db-stack)

*Manage PostgreSQL, MySQL, MongoDB, Redis, and Oracle from anywhere in your terminal with simple commands*

[Installation](#-installation) • [Quick Start](#-usage) • [Features](#-core-features) • [Documentation](#-additional-documentation)

</div>

---

## ✨ Core Features

<table>
<tr>
<td width="50%">

### 🚀 **Simple & Global**
- **One-command install** via curl or Homebrew
- **Global shell commands** work from any directory
- **No project pollution** - self-contained in `~/.local-db-stack/`

### 🔒 **Safe & Persistent**
- **Consistent data location** at `~/.local-db-stack/data/`
- **Zero data loss** with maximum durability settings
- **Easy backups** with transparent file system access

</td>
<td width="50%">

### ⚡ **Fast & Seamless**
- **Password-free CLI access** via auto-configured files
- **Health checks** ensure readiness before connections
- **Conflict-free** with non-standard ports

### 🎯 **Developer-Friendly**
- **All major databases** in one stack
- **GUI-ready** connection files
- **Simple management** with intuitive commands

</td>
</tr>
</table>

<details>
<summary><b>🎁 What Makes This Special?</b></summary>

<br>

Unlike Docker volumes that hide your data in obscure locations, this stack stores everything in a **predictable, accessible location** that persists regardless of where you run docker-compose.

**Before Local DB Stack:**
```bash
# Where's my data? 🤷
docker volume inspect some_volume_name
# Output: /var/lib/docker/volumes/some_hash/_data

# Password prompts everywhere 😫
psql -h localhost -U user
Password for user: ▮
```

**With Local DB Stack:**
```bash
# Data is always here 📍
ls ~/.local-db-stack/data/postgres
# Easy to backup, inspect, migrate

# No more passwords! 🎉
localdb-psql
# Connects instantly ⚡
```

</details>

---

## ✅ Prerequisites

<table>
<tr>
<td width="33%"><b>🐚 Shell</b><br>Bash or Zsh<br><i>(standard on macOS/Linux)</i></td>
<td width="33%"><b>🐳 Docker</b><br>Docker & Docker Compose<br><i>(Desktop or Engine)</i></td>
<td width="33%"><b>🔧 Tools</b><br>curl & git<br><i>(usually pre-installed)</i></td>
</tr>
</table>

---

## 🚀 Installation

### One-Command Setup

Copy and paste this into your terminal:

```bash
bash <(curl -s https://raw.githubusercontent.com/brentmzey/local-db-stack/main/install.sh)
```

<details>
<summary><b>What does the installer do?</b></summary>

<br>

1. ✅ Downloads configuration files to `~/.local-db-stack/`
2. ✅ Creates data directories at `~/.local-db-stack/data/`
3. ✅ Sets up connection files (`~/.pgpass`, `~/.my.cnf`, etc.)
4. ✅ Adds shell functions to your `~/.zshrc` or `~/.bashrc`
5. ✅ Generates connection information file

**Your data and configs stay in one place**, making backups and migrations simple.

</details>

### Activate the Commands

After installation, restart your terminal or run:

```bash
# For Zsh (default on macOS)
source ~/.zshrc

# For Bash (common on Linux)
source ~/.bashrc
```

### Test It Out

```bash
# Start all databases
localdb-up

# Check status (wait ~30 seconds for all to be healthy)
localdb-status

# Connect to PostgreSQL (no password needed!)
localdb-psql

# View all connection info
localdb-connect
```

---

## 🛠️ Command Reference

> **💡 All commands work from any directory in your terminal**

### 🎮 Database Control

<table>
<tr>
<th width="30%">Command</th>
<th width="70%">Description</th>
</tr>
<tr>
<td><code>localdb-up</code></td>
<td>🚀 Start all database containers in the background</td>
</tr>
<tr>
<td><code>localdb-down</code></td>
<td>🛑 Stop all database containers (data persists)</td>
</tr>
<tr>
<td><code>localdb-status</code></td>
<td>📊 Check the status and health of all containers</td>
</tr>
<tr>
<td><code>localdb-logs [service]</code></td>
<td>📜 Tail logs for a specific service<br><i>Example: <code>localdb-logs postgres</code></i></td>
</tr>
<tr>
<td><code>localdb-wipe</code></td>
<td>🗑️ <b>⚠️ Deletes everything!</b> Stops containers and removes all data</td>
</tr>
</table>

### 🔌 Instant Connections

<table>
<tr>
<th width="30%">Command</th>
<th width="70%">Description</th>
</tr>
<tr>
<td><code>localdb-connect</code></td>
<td>📋 Display connection info for all databases</td>
</tr>
<tr>
<td><code>localdb-psql</code></td>
<td>🐘 Connect to PostgreSQL instantly (no password prompt!)</td>
</tr>
<tr>
<td><code>localdb-mysql</code></td>
<td>🐬 Connect to MySQL instantly (no password prompt!)</td>
</tr>
<tr>
<td><code>localdb-mongo</code></td>
<td>🍃 Connect to MongoDB with pre-configured credentials</td>
</tr>
<tr>
<td><code>localdb-redis</code></td>
<td>⚡ Connect to Redis CLI</td>
</tr>
</table>

### 🗄️ Data Management

<table>
<tr>
<th width="30%">Command</th>
<th width="70%">Description</th>
</tr>
<tr>
<td><code>localdb-data-dir</code></td>
<td>📁 Show data directory location and contents</td>
</tr>
<tr>
<td><code>localdb-init</code></td>
<td>🔧 Initialize/migrate data directories and connection files</td>
</tr>
<tr>
<td><code>localdb-setup-connections</code></td>
<td>🔐 Regenerate connection configuration files</td>
</tr>
<tr>
<td><code>localdb-edit</code></td>
<td>✏️ Edit configuration in <code>~/.local-db-stack/.env</code></td>
</tr>
</table>

<details>
<summary><b>💻 Complete Getting Started Workflow</b></summary>

### Step 1: Start Your Databases

```bash
# Start all databases
localdb-up

# Wait ~30 seconds, then check status
localdb-status
# NAME             STATUS              HEALTH
# local_postgres   Up 30 seconds       healthy
# local_mysql      Up 30 seconds       healthy
# local_mongodb    Up 30 seconds       healthy
# local_redis      Up 30 seconds       healthy
# local_oracle     Up 30 seconds       healthy (takes 1-2 min first time)
```

### Step 2: Generate Connection Credentials

```bash
# Create connection files and display info
localdb-setup-connections

# View connection details anytime
localdb-connect
# Displays all connection strings, ports, and credentials
```

### Step 3: Connect with CLI (Password-Free!)

```bash
# PostgreSQL
localdb-psql
# local_database=# CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT);
# local_database=# \q

# MySQL
localdb-mysql
# mysql> SHOW DATABASES;
# mysql> EXIT;

# MongoDB
localdb-mongo
# test> db.version()

# Redis
localdb-redis
# 127.0.0.1:16379> PING
```

### Step 4: Connect with GUI Tools

Open your preferred database tool and use the credentials from `localdb-connect`:

**DBeaver, pgAdmin, MongoDB Compass, etc.** - See the "Connecting with GUI Tools" section below for detailed setup instructions.

### Step 5: Verify Data Persistence

```bash
# View where your data is stored
localdb-data-dir
# Data directory: /Users/you/.local-db-stack/data
# postgres/  mysql/  mongodb/  redis/  oracle/

# Stop everything (data persists!)
localdb-down

# Start again - your data is still there!
localdb-up
localdb-psql
# local_database=# SELECT * FROM users;  ✓ Your data persists!
```

</details>

---

## ⚙️ Configuration

All settings live in **`~/.local-db-stack/.env`**. Edit it anytime:

```bash
localdb-edit
```

### 🔌 Port Configuration

**All ports use a "1" prefix to avoid conflicts** with standard database ports and integration tests running on your machine.

| Database   | Standard Port | Local DB Stack Port | Customizable |
|------------|--------------|---------------------|--------------|
| PostgreSQL | 5432         | **15432**          | ✅ Yes       |
| MySQL      | 3306         | **13306**          | ✅ Yes       |
| MongoDB    | 27017        | **17017**          | ✅ Yes       |
| Redis      | 6379         | **16379**          | ✅ Yes       |
| Oracle     | 1521         | **11521**          | ✅ Yes       |

**Why non-standard ports?** This prevents conflicts with:
- Integration tests expecting standard ports
- Other database instances on your machine  
- Development servers running alongside Local DB Stack

<details>
<summary><b>🔧 Customizing Ports</b></summary>

<br>

Need different ports? Easy:

```bash
# 1. Edit configuration
localdb-edit

# 2. Change any port values, for example:
LOCAL_POSTGRES_PORT=25432
LOCAL_MYSQL_PORT=23306

# 3. Regenerate connection files
localdb-setup-connections

# 4. Restart databases
localdb-down && localdb-up

# 5. Verify new ports
localdb-connect
```

**Pro Tips:**
- Choose ports above 1024 to avoid requiring sudo
- Avoid common ports like 8080, 3000, etc.
- Check if port is available: `lsof -i :[port_number]`
- Document custom ports in your project README

</details>

### Default Configuration

```bash
# Data directory for all database volumes
LOCAL_DB_DATA_DIR=$HOME/.local-db-stack/data

# PostgreSQL
LOCAL_POSTGRES_PORT=15432
LOCAL_POSTGRES_USER=local_user
LOCAL_POSTGRES_PASS=local_password
LOCAL_POSTGRES_DB=local_database

# MySQL
LOCAL_MYSQL_PORT=13306
LOCAL_MYSQL_USER=local_user
LOCAL_MYSQL_PASS=local_password
LOCAL_MYSQL_DB=local_database

# MongoDB
LOCAL_MONGODB_PORT=17017
LOCAL_MONGO_USER=local_root
LOCAL_MONGO_PASS=local_rootpassword

# Redis
LOCAL_REDIS_PORT=16379

# Oracle
LOCAL_ORACLE_PORT=11521
LOCAL_ORACLE_PASS=LocalOraclePass123
```

> **💡 Pro Tip:** After changing ports or credentials, run `localdb-setup-connections` to update your connection files, then restart the databases with `localdb-down && localdb-up`.

---

## 🔌 Database Connections

### 🎯 Connection At a Glance

<table>
<tr>
<th>Database</th>
<th>Port</th>
<th>Quick Connect</th>
<th>Connection String</th>
</tr>
<tr>
<td>🐘 <b>PostgreSQL</b></td>
<td><code>15432</code></td>
<td><code>localdb-psql</code></td>
<td><code>postgresql://local_user:local_password@localhost:15432/local_database</code></td>
</tr>
<tr>
<td>🐬 <b>MySQL</b></td>
<td><code>13306</code></td>
<td><code>localdb-mysql</code></td>
<td><code>mysql://local_user:local_password@localhost:13306/local_database</code></td>
</tr>
<tr>
<td>🍃 <b>MongoDB</b></td>
<td><code>17017</code></td>
<td><code>localdb-mongo</code></td>
<td><code>mongodb://local_root:local_rootpassword@localhost:17017/admin</code></td>
</tr>
<tr>
<td>⚡ <b>Redis</b></td>
<td><code>16379</code></td>
<td><code>localdb-redis</code></td>
<td><code>redis://localhost:16379</code></td>
</tr>
<tr>
<td>🔶 <b>Oracle</b></td>
<td><code>11521</code></td>
<td><i>Use GUI/client</i></td>
<td><code>localhost:11521/FREEPDB1</code> (user: <code>system</code>)</td>
</tr>
</table>

### 🚀 Seamless Connectivity Features

The installer automatically configures these files for **password-free access**:

<table>
<tr>
<th width="25%">File</th>
<th width="35%">Purpose</th>
<th width="40%">Benefit</th>
</tr>
<tr>
<td><code>~/.pgpass</code></td>
<td>PostgreSQL password storage</td>
<td>✅ <code>psql</code> connects without prompts</td>
</tr>
<tr>
<td><code>~/.my.cnf</code></td>
<td>MySQL credentials</td>
<td>✅ <code>mysql</code> connects without prompts</td>
</tr>
<tr>
<td><code>~/.mongorc.js</code></td>
<td>MongoDB connection helpers</td>
<td>✅ Quick connection functions</td>
</tr>
<tr>
<td><code>~/.redisclirc</code></td>
<td>Redis connection notes</td>
<td>✅ Port configuration reminder</td>
</tr>
<tr>
<td><code>~/.local-db-stack/CONNECTION_INFO.txt</code></td>
<td>All connection details</td>
<td>✅ One-stop reference for all DBs</td>
</tr>
</table>

<details>
<summary><b>🔧 Connecting with GUI Tools (DBeaver, Compass, etc.)</b></summary>

<br>

After starting your databases with `localdb-up`, you can connect using any GUI tool. First, generate your connection credentials:

```bash
localdb-setup-connections
```

This creates `~/.local-db-stack/CONNECTION_INFO.txt` with all your connection details. Now configure your GUI tools:

### DBeaver (Universal SQL Client)

**PostgreSQL Connection:**
1. Create New Connection → PostgreSQL
2. Configure:
   ```
   Host:     localhost
   Port:     15432
   Database: local_database
   Username: local_user
   Password: local_password
   ```
3. Test Connection → Finish

**MySQL Connection:**
1. Create New Connection → MySQL
2. Configure:
   ```
   Host:     localhost
   Port:     13306
   Database: local_database
   Username: local_user
   Password: local_password
   ```
3. Test Connection → Finish

**Oracle Connection:**
1. Create New Connection → Oracle
2. Configure:
   ```
   Host:        localhost
   Port:        11521
   Database:    FREEPDB1
   Service name: FREEPDB1
   Username:    system
   Password:    LocalOraclePass123
   ```
3. Test Connection → Finish
   
   > **Note:** Oracle takes 1-2 minutes on first startup. Check `localdb-status` before connecting.

### MongoDB Compass

1. Click "New Connection"
2. Paste the connection string:
   ```
   mongodb://local_root:local_rootpassword@localhost:17017/admin?authSource=admin
   ```
3. Click "Connect"

### PostgreSQL-Specific Tools

**pgAdmin / Postico / TablePlus:**
```
Host:     localhost
Port:     15432
Database: local_database
Username: local_user
Password: local_password
```

### MySQL-Specific Tools

**MySQL Workbench / Sequel Ace:**
```
Host:     localhost
Port:     13306
Database: local_database
Username: local_user
Password: local_password
```

### Redis Tools

**RedisInsight / Another Redis Desktop Manager:**
```
Host: localhost
Port: 16379
Name: Local DB Stack (optional)
```
No password required.

### Quick CLI Connections

For command-line access without entering passwords:

```bash
localdb-psql      # PostgreSQL
localdb-mysql     # MySQL
localdb-mongo     # MongoDB
localdb-redis     # Redis
```

**💡 Pro Tips:**
- Run `localdb-connect` anytime to display all connection details
- Run `localdb-status` to verify all databases are healthy before connecting
- Connection info is always available in `~/.local-db-stack/CONNECTION_INFO.txt`

</details>

<details>
<summary><b>🔐 How Password-Free Access Works</b></summary>

<br>

When you run the installer or `localdb-setup-connections`, it creates secure credential files in your home directory:

**PostgreSQL (~/.pgpass)**
```
localhost:15432:*:local_user:local_password
```
- Permissions automatically set to `600` (owner read/write only)
- Standard PostgreSQL credential storage method
- Works with `psql`, `pg_dump`, and all PostgreSQL tools

**MySQL (~/.my.cnf)**
```
[client-local-db-stack]
host=localhost
port=13306
user=local_user
password=local_password
database=local_database
```
- Group suffix prevents conflicts with other MySQL configs
- `localdb-mysql` command uses `--defaults-group-suffix=-local-db-stack`
- Standard MySQL options file format

**MongoDB (~/.mongorc.js)**
```javascript
// Helper function automatically available in mongosh
localDBConnect = function() {
  return db.getSiblingDB('admin').auth('local_root', 'local_rootpassword');
}
```

These files follow industry-standard security practices and are used by professional database administrators worldwide.

</details>

---

## 💾 Data Persistence

### 📍 Where Your Data Lives

```
~/.local-db-stack/
├── data/                       # All database data here!
│   ├── postgres/              # PostgreSQL data
│   ├── mysql/                 # MySQL data
│   ├── mongodb/               # MongoDB data
│   ├── mongodb-config/        # MongoDB config
│   ├── redis/                 # Redis data
│   └── oracle/                # Oracle data
├── .env                       # Configuration
├── docker-compose.yml         # Database definitions
└── CONNECTION_INFO.txt        # Connection reference
```

### ✨ Why This Matters

**Traditional Docker Volumes:**
```bash
docker volume inspect my_volume
# {
#   "Mountpoint": "/var/lib/docker/volumes/hash/_data"
# }
# 😞 Hidden, hard to backup, unclear ownership
```

**Local DB Stack Bind Mounts:**
```bash
ls ~/.local-db-stack/data/
# postgres/  mysql/  mongodb/  redis/  oracle/
# 😊 Transparent, easy backups, portable
```

### 🎁 Benefits

<table>
<tr>
<td width="50%">

**🎯 Predictable Location**
- Same path on every machine
- Survives docker-compose location changes
- Easy to find and inspect

**💼 Simple Backups**
```bash
# Backup all databases
tar -czf db-backup.tar.gz \
  ~/.local-db-stack/data/

# Restore
tar -xzf db-backup.tar.gz -C ~/
```

</td>
<td width="50%">

**🚚 Easy Migration**
```bash
# Old machine
scp -r ~/.local-db-stack/data/ \
  newmachine:~/

# New machine
localdb-up  # Just works!
```

**🔍 Transparent Access**
- See your data files directly
- Use standard filesystem tools
- No Docker volume mysteries

</td>
</tr>
</table>

> **📖 Deep Dive:** See [DATA_PERSISTENCE.md](DATA_PERSISTENCE.md) for migration guides, backup strategies, and advanced topics.

---

## 🛡️ Data Consistency & Safety

All databases are configured with **maximum durability settings** to ensure zero data loss:

### Database-Specific Guarantees

<table>
<tr>
<td width="50%">

**🐘 PostgreSQL**
- ✅ Full page writes enabled
- ✅ Synchronous commits
- ✅ fsync on every transaction
- ✅ WAL archiving configured
- ✅ Checkpoint consistency

**🐬 MySQL**
- ✅ InnoDB doublewrite buffer
- ✅ Binary logging enabled
- ✅ Sync on transaction commit
- ✅ Crash recovery safe

**🍃 MongoDB**
- ✅ WiredTiger journaling
- ✅ Snappy compression
- ✅ Checkpoint consistency
- ✅ Durable writes

</td>
<td width="50%">

**⚡ Redis**
- ✅ AOF persistence enabled
- ✅ appendfsync everysec
- ✅ RDB snapshots
- ✅ Checksum validation
- ✅ Write verification

**🔶 Oracle**
- ✅ Standard durability settings
- ✅ Redo logging enabled
- ✅ Proper shutdown handling
- ✅ Crash recovery

</td>
</tr>
</table>

### Health Checks Ensure Readiness

Each database has health checks that verify:
- ✅ Process is running
- ✅ Accepting connections
- ✅ Initialization complete
- ✅ Ready for queries

```bash
localdb-status
# NAME      STATUS    HEALTH
# postgres  Up 2m     healthy
# mysql     Up 2m     healthy
# mongodb   Up 2m     healthy
# redis     Up 2m     healthy
# oracle    Up 2m     healthy (takes 1-2 min on first start)
```

> **📖 Technical Details:** See [DATA_CONSISTENCY.md](DATA_CONSISTENCY.md) for configuration details and durability guarantees.

---

## 🏗️ Platform Compatibility

<table>
<tr>
<th width="25%">Platform</th>
<th width="25%">Status</th>
<th width="50%">Notes</th>
</tr>
<tr>
<td>🍎 <b>macOS</b></td>
<td>✅ Fully Supported</td>
<td>Intel and Apple Silicon (M1/M2/M3)</td>
</tr>
<tr>
<td>🐧 <b>Linux</b></td>
<td>✅ Fully Supported</td>
<td>x86_64 and ARM64</td>
</tr>
<tr>
<td>🪟 <b>WSL2</b></td>
<td>✅ Fully Supported</td>
<td>Windows Subsystem for Linux 2</td>
</tr>
</table>

All database images support multi-platform architectures. Note: On ARM-based machines (like Apple Silicon), the Oracle Database image requires explicit `platform: linux/amd64` in `docker-compose.yml` to run correctly.

### Quick Local Test

Want to try before installing globally? Test locally:

```bash
# Clone the repository
git clone https://github.com/brentmzey/local-db-stack.git
cd local-db-stack

# Start all databases
cd assets
docker-compose up -d

# Check status
docker-compose ps

# Test persistence
cd ..
./test_persistence.sh

# Clean up
cd assets
docker-compose down -v
```

---

## 🤔 Troubleshooting

### Common Issues

<details>
<summary><b>❓ Installation completed but commands don't work</b></summary>

<br>

**Problem:** After running the installer, `localdb-up` command not found.

**Solution:**
```bash
# You must restart your terminal OR run:
source ~/.zshrc    # for Zsh
source ~/.bashrc   # for Bash

# Then try again:
localdb-up
```

The installation adds commands to your shell config, which only loads on terminal startup.

</details>

<details>
<summary><b>❓ Database won't start or shows as unhealthy</b></summary>

<br>

**Check the logs:**
```bash
localdb-logs postgres  # or mysql, mongodb, redis, oracle
```

**Common causes:**
1. **Port already in use** - Check if another service is using the port
   ```bash
   lsof -i :15432  # Check PostgreSQL port
   ```
   Solution: Edit `~/.local-db-stack/.env` to use a different port

2. **Insufficient memory** - Databases need adequate resources
   - PostgreSQL: ~256MB
   - MySQL: ~512MB
   - MongoDB: ~512MB
   - Oracle: ~2GB (first start may take 1-2 minutes)

3. **Corrupted data** - Rare, but possible after system crash
   ```bash
   # Backup first if data is important
   mv ~/.local-db-stack/data/postgres ~/.local-db-stack/data/postgres.backup
   
   # Create fresh directory
   mkdir ~/.local-db-stack/data/postgres
   
   # Restart
   localdb-down
   localdb-up
   ```

</details>

<details>
<summary><b>❓ Oracle takes forever to start</b></summary>

<br>

**This is normal!** Oracle Database initialization takes 1-2 minutes on first startup.

```bash
# Monitor progress:
localdb-logs oracle

# Wait for this message:
# "DATABASE IS READY TO USE!"

# Then check status:
localdb-status
# oracle  Up 2m  healthy
```

On subsequent starts, Oracle starts much faster (~10-20 seconds).

</details>

<details>
<summary><b>❓ Can't connect with GUI tool</b></summary>

<br>

**Verify databases are running:**
```bash
localdb-status
# All should show "healthy"
```

**Get connection details:**
```bash
localdb-connect
```

**Common mistakes:**
- ❌ Using standard ports (3306, 5432, etc.)  
  ✅ Use the custom ports (13306, 15432, etc.)
  
- ❌ Wrong credentials  
  ✅ Check `~/.local-db-stack/.env` for current values

- ❌ Connecting to wrong host  
  ✅ Always use `localhost` or `127.0.0.1`

**Test from command line first:**
```bash
localdb-psql   # PostgreSQL
localdb-mysql  # MySQL
localdb-mongo  # MongoDB
localdb-redis  # Redis
```

</details>

<details>
<summary><b>❓ How do I change passwords or ports?</b></summary>

<br>

```bash
# 1. Edit configuration
localdb-edit

# 2. Make your changes (save and exit)

# 3. Regenerate connection files
localdb-setup-connections

# 4. Restart databases
localdb-down
localdb-up

# 5. Test connection
localdb-connect
```

**Note:** Changing passwords doesn't affect existing data, but you may need to update the database's internal users depending on what you change.

</details>

<details>
<summary><b>❓ Where exactly is my data stored?</b></summary>

<br>

```bash
# View data directory
localdb-data-dir

# Direct path:
ls -lh ~/.local-db-stack/data/
# postgres/
# mysql/
# mongodb/
# redis/
# oracle/

# Each folder contains that database's data files
```

This location is **consistent** regardless of where you run docker-compose from.

</details>

### Getting More Help

1. **Check logs:** `localdb-logs [service-name]`
2. **Verify Docker:** `docker ps` (should show containers if running)
3. **Review docs:** 
   - [DATA_PERSISTENCE.md](DATA_PERSISTENCE.md) - Data storage and backups
   - [SEAMLESS_CONNECTIVITY.md](SEAMLESS_CONNECTIVITY.md) - Connection guides
   - [DATA_CONSISTENCY.md](DATA_CONSISTENCY.md) - Durability settings
   - [DEVELOPMENT.md](DEVELOPMENT.md) - Development and testing

---

## 📚 Additional Documentation

<table>
<tr>
<td width="50%">

### 📖 User Guides

**[DATA_PERSISTENCE.md](DATA_PERSISTENCE.md)**
- Data storage architecture
- Backup and restore procedures
- Migration from Docker volumes
- Cross-platform compatibility

**[SEAMLESS_CONNECTIVITY.md](SEAMLESS_CONNECTIVITY.md)**
- Password-free setup explained
- GUI tool configurations
- Connection troubleshooting
- Security best practices

</td>
<td width="50%">

### 🔧 Technical Docs

**[DATA_CONSISTENCY.md](DATA_CONSISTENCY.md)**
- Durability settings for each DB
- Transaction safety guarantees
- Recovery procedures
- Performance considerations

**[DEVELOPMENT.md](DEVELOPMENT.md)**
- Build instructions
- Testing procedures
- Contributing guidelines
- Architecture overview

</td>
</tr>
</table>

---

## 🗑️ Uninstalling

If you need to remove Local DB Stack:

### Complete Removal

```bash
# 1. Stop and remove all containers and data
localdb-wipe

# 2. Remove installation files
rm -rf ~/.local-db-stack

# 3. Remove connection files (optional)
rm ~/.pgpass
rm ~/.my.cnf
rm ~/.mongorc.js
rm ~/.redisclirc

# 4. Remove shell configuration
# Edit ~/.zshrc or ~/.bashrc and delete lines between:
# # START LOCAL DB STACK
# ...
# # END LOCAL DB STACK

# 5. Restart terminal
```

### Keeping Data for Later

If you want to keep your data but remove the commands:

```bash
# 1. Stop containers (keeps data)
localdb-down

# 2. Keep: ~/.local-db-stack/data/
# 3. Remove shell config (step 4 above)
# 4. Restart terminal
```

Later, you can reinstall and your data will still be there!

---

## 🤝 Contributing

Contributions are welcome! We appreciate:

- 🐛 Bug reports and fixes
- 📖 Documentation improvements
- ✨ New features and enhancements
- 🧪 Additional tests

See [DEVELOPMENT.md](DEVELOPMENT.md) for guidelines on building, testing, and contributing to this project.

---

## 📄 License

MIT License - See repository for full license text.

---

<div align="center">

**Made with ❤️ for developers who need reliable local databases**

[⬆ Back to Top](#-local-database-stack)

</div>

