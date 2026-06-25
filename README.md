# TYPO3 v.14 LTS — DevContainer Example

A ready-to-run [TYPO3 14.3 LTS](https://typo3.org) project using the official [Camino theme](https://extensions.typo3.org/extension/theme_camino), set up as a DevContainer for VS Code or any compatible IDE.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop)
- [VS Code](https://code.visualstudio.com) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension

## Quick start

```bash
git clone <repository-url>
```

Open the cloned folder in VS Code and reopen it in the DevContainer when prompted. Then run inside the container terminal:

```bash
make init
```

That's it. TYPO3 is installed and ready.

## What `make init` does

| Step | Target | Description |
|------|--------|-------------|
| 1 | `db-cleanup` | Drops all existing tables |
| 2 | `fs-cleanup` | Removes generated files (`vendor/`, `var/`, `config/system/settings.php`) |
| 3 | `fs-prepare` | Copies `.env.dist` to `.env` |
| 4 | `composer-install` | Installs all Composer dependencies |
| 5 | `typo3-setup` | Runs the TYPO3 installer |
| 6 | `typo3-maintenance` | Updates DB schema, sets up extensions, flushes caches |

## Available make targets

```bash
make init              # Full setup from scratch
make db-auth           # Create 
make db-import         # Import a SQL dump from .resources/sql/mysqldump.sql
make db-export         # Export the current database to .resources/sql/mysqldump.sql
make composer-install  # Install/update Composer dependencies
make typo3-maintenance # DB schema update, extension setup, cache flush
```

## Credentials

| | Username | Password |
|-|----------|----------|
| TYPO3 Backend | `developer` | `P@ssw0rd` |
| Install Tool | | `P@ssw0rd` |
| MariaDB | `developer` | `P@ssw0rd` |

## Stack

| Component | Version |
|-----------|---------|
| TYPO3 | 14.3 LTS |
| Theme | [typo3/theme-camino](https://extensions.typo3.org/extension/theme_camino) |
| PHP | 8.4 |
| MariaDB | 10.11 |

## Notes

- All `make` commands must be run **inside the DevContainer** (the VS Code integrated terminal opens there automatically).
- The MariaDB service is not exposed to the host — it is only reachable from within the container at `127.0.0.1:3306`.
- The TYPO3 context is set to `Development/Docker` by default.
