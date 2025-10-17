# 📦 Local Database Stack

A distributable, namespaced local database environment for macOS, Linux, and WSL2, designed to run without conflicting with other development projects.

Install it once, and manage a suite of common databases (PostgreSQL, MySQL, MongoDB, Redis, Oracle) from anywhere in your terminal using simple commands.

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20WSL2-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

---

## ✨ Core Features

* **Simple Install**: Get started with a single command via Homebrew or `curl`.
* **Global Commands**: Adds simple shell commands like `localdb-up` and `localdb-down` that work from any directory.
* **Conflict-Free**: Uses non-standard ports and `LOCAL_` prefixed environment variables to prevent clashes with your other projects.
* **Self-Contained**: Manages all configuration and data in a dedicated `~/.local-db-stack` directory, keeping your project folders clean.
* **Data Consistency First**: All databases configured with maximum durability settings (fsync, write-ahead logging, journaling) to ensure zero data loss.
* **Persistent Storage**: Docker named volumes with automatic health checks ensure reliable state preservation across restarts.

---

## ✅ Prerequisites

Before you begin, ensure you have the following installed and running:

* A **POSIX-compliant shell** (like `bash` or `zsh`, which are standard on macOS and most Linux distros).
* **Docker** and **Docker Compose** (Docker Desktop for Mac/Windows or Docker Engine for Linux).
* **`curl`** and **`git`**.

---

## 🚀 Installation

You only need to do this once.

### Quick Install (One Command)

Run this command in your terminal (works on macOS, Linux, and WSL2):

```bash
bash <(curl -s https://raw.githubusercontent.com/brentmzey/local-db-stack/main/install.sh)
```

### After Installation

**You MUST restart your terminal** or run one of these commands to activate the new `localdb-*` commands:

```bash
# If you use Zsh (default on macOS)
source ~/.zshrc

# If you use Bash
source ~/.bashrc
```

Once your terminal is restarted or sourced, test the installation:

```bash
localdb-up
```

---

## 🛠️ Usage

Once installed, you can manage the database stack from **any directory** in your terminal.

| Command | Description |
| :--- | :--- |
| `localdb-up` | Starts all database containers in the background. |
| `localdb-down` | Stops all database containers. Your data is safe. |
| `localdb-status`| Checks the status of the running containers. |
| `localdb-logs [service]` | Tails the logs for a specific service (e.g., `localdb-logs postgres`). |
| `localdb-edit` | Opens your `.env` config file in your default text editor. |
| `localdb-wipe` | **Deletes everything!** Stops containers and removes all data volumes. |

---

## ⚙️ Configuration

All configuration for ports, usernames, and passwords lives in a single `.env` file located at `~/.local-db-stack/.env`. To edit it, run:

```bash
localdb-edit
```

---

## 🔌 Connection & Persistence Details

### Persistent Storage Location

This stack uses **Docker Named Volumes** for persistence. This means your data is safely managed by Docker itself, not in a simple folder in your home directory. This is the standard, cross-platform way to ensure data integrity.

* To see a list of volumes, run: `docker volume ls | grep local_`
* For advanced users: To find the physical location on your machine where Docker stores a specific volume, you can run `docker volume inspect local_postgres_data`.

### Database Connection Info

Use the following details to connect from your applications or a database client. The values are determined by your configuration in the `.env` file.

| Database | Port (Default) | Connection URI Example |
| :--- | :--- | :--- |
| **PostgreSQL** | `15432` | `postgresql://local_user:local_password@localhost:15432/local_database` |
| **MySQL** | `13306` | `mysql://local_user:local_password@localhost:13306/local_database` |
| **MongoDB** | `17017` | `mongodb://local_root:local_rootpassword@localhost:17017/` |
| **Redis** | `16379` | `redis://localhost:16379` |
| **Oracle** | `11521` | `jdbc:oracle:thin:@//localhost:11521/FREEPDB1` (user: `system`) |

---

## 🛡️ Data Consistency Guarantees

All databases are configured with maximum durability settings to ensure **zero data loss** between runs:

* **PostgreSQL**: Full page writes, synchronous commits, fsync enabled, WAL archiving
* **MySQL**: InnoDB doublewrite buffer, binary logging, sync at transaction commit
* **MongoDB**: WiredTiger journaling with compression, checkpoint consistency
* **Redis**: AOF persistence (appendfsync everysec) + RDB snapshots, checksum validation
* **Oracle**: Standard durability settings with proper shutdown handling

Health checks ensure all databases are fully initialized and ready before accepting connections.

---

## 🤔 Troubleshooting

### Installation Messages

After running the installer, you'll see:
```
[SUCCESS] Installation complete!
[INFO] Restart your terminal or run 'source ~/.zshrc' to use the new commands.
```

You may also see some additional output or error messages related to shell configuration. **This is normal!** The installation completed successfully. Just restart your terminal or run the source command shown above.

### Oracle ARM64 (Apple Silicon) Compatibility

This stack now uses the official Oracle Database Free image (`container-registry.oracle.com/database/free:latest`) which supports both Intel (amd64) and Apple Silicon (arm64) platforms natively. No emulation warnings should appear.

**Note**: Oracle takes 1-2 minutes to initialize on first startup. Use `localdb-logs oracle` to monitor progress.

### Database Won't Start After System Crash

If a database fails to start after an unexpected shutdown:

```bash
# Check the logs for the specific service
localdb-logs postgres  # or mysql, mongodb, redis, oracle

# If data corruption is suspected (rare with our durability settings)
# you may need to remove and recreate that specific volume
docker volume rm local_postgres_data  # WARNING: This deletes all data for that DB
```

---

## 🗑️ Uninstalling

1.  Remove the shell configuration by deleting the block between `# START LOCAL DB STACK` and `# END LOCAL DB STACK` from your `~/.zshrc` or `~/.bashrc`.
2.  Stop and remove all containers and volumes: `localdb-wipe`
3.  Remove the installation files: `rm -rf ~/.local-db-stack`.
4.  Restart your terminal.

