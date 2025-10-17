# 📦 Local Database Stack

A distributable, namespaced local database environment for macOS, designed to run without conflicting with other development projects.

Install it once, and manage a suite of common databases (PostgreSQL, MySQL, MongoDB, Redis, etc.) from anywhere in your terminal using simple commands.

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

---

## ✨ Core Features

* **Simple Install**: Get started with a single command via Homebrew or `curl`.
* **Global Commands**: Adds simple shell commands like `localdb-up` and `localdb-down` that work from any directory.
* **Conflict-Free**: Uses non-standard ports and `LOCAL_` prefixed environment variables to prevent clashes with your other projects.
* **Self-Contained**: Manages all configuration and data in a dedicated `~/.local-db-stack` directory, keeping your project folders clean.
* **Persistent Data**: All database data is safely stored on your machine between restarts.

---

## 🚀 Installation

You only need to do this once.

> **Important**: After installing, you **must restart your terminal** or source your profile (e.g., `source ~/.zshrc`) to activate the new commands.

### Option 1: Homebrew (Recommended)

1.  **Tap the Repository**:
    ```bash
    brew tap brentmzey/local-db-stack
    ```

2.  **Install the Package**:
    ```bash
    brew install local-db-stack
    ```

3.  **Run the One-Time Setup**:
    ```bash
    $(brew --prefix)/opt/local-db-stack/bin/localdb-setup
    ```

### Option 2: Curl to Bash

```bash
bash <(curl -s https://raw.githubusercontent.com/brentmzey/local-db-stack/main/install.sh)
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

## 🔌 Connection Details

Use the following details to connect from your applications or a database client.

| Database | Host | Port (Default) | Username (Default) | Password (Default) |
| :--- | :--- | :--- | :--- | :--- |
| **PostgreSQL** | `localhost` | `15432` | `local_user` | `local_password` |
| **MySQL** | `localhost` | `13306` | `local_user` | `local_password` |
| **MongoDB** | `localhost` | `17017` | `local_root` | `local_rootpassword`|
| **Redis** | `localhost` | `16379` | (none) | (none) |
| **Oracle XE**| `localhost` | `11521` | `system` | `local_password` |

---

## 🗑️ Uninstalling

1.  Remove the shell configuration by deleting the block between `# START LOCAL DB STACK` and `# END LOCAL DB STACK` from your `~/.zshrc` or `~/.bashrc`.
2.  Remove the installation files: `rm -rf ~/.local-db-stack`.
3.  If you used Homebrew, run: `brew uninstall local-db-stack && brew untap brentmzey/local-db-stack`.
4.  Restart your terminal.

