# Inception - Developer Documentation

This document explains the environment setup, management commands, and data structure for developers and reviewers (evaluators) of the Inception project.

## 1. Prerequisites

Before setting up the project, ensure that the following environment requirements are met:

* **OS**: Debian-based Linux distribution (or a Docker execution environment such as macOS).
* **Docker & Docker Compose**: The latest versions must be installed.
* **Domain Configuration**: To access the local environment, add the following routing to the `/etc/hosts` file on your host machine:
  `127.0.0.1 tobaba.42.fr`

## 2. Setup

Follow these steps to configure environment variables and start the containers:

1. Create a `.env` file inside the `srcs` folder located in the root directory of the repository.
2. Define the necessary environment variables in the `.env` file, such as database passwords and WordPress administrator information (this file is not committed to the Git repository for security reasons).
3. Run the `make` or `make all` command in the root directory.

## 3. Makefile Usage

Manage the container lifecycle using the `Makefile` located in the root directory.

* **`make` / `make all`**: Automatically creates directories on the host machine for data persistence (`/home/tobaba/data/mariadb` and `/home/tobaba/data/wordpress`). It then builds images using `docker compose` and starts the containers in the background (detached mode).
* **`make down`**: Safely stops and removes running containers and created networks. Data volumes are preserved.
* **`make clean`**: In addition to the `make down` process, this command also removes data volumes within Docker.
* **`make fclean`**: A powerful command to completely reset the environment. It runs `make clean`, followed by `docker system prune -af` to remove all unused images and caches. Furthermore, it physically deletes the host machine's data storage directory (`/home/tobaba/data`) using `sudo rm -rf`. *Warning: Use with caution as all data will be permanently deleted.*
* **`make re`**: Executes `make fclean` to completely clear the environment, then runs `make all` to rebuild and start from a clean state.

## 4. Useful Commands

Here is a useful command for development and debugging:

* **Check container status**: 
  `cd srcs && docker compose ps`

## 5. Data Persistence

In this project, data is persisted using Docker Named Volumes (configured with local driver binding to the host machine) to the host machine, ensuring that no data is lost even if containers are restarted or destroyed. The actual data is stored in the following paths on the host machine:

* **Database (MariaDB) data**: `/home/tobaba/data/mariadb` (Synchronized with `/var/lib/mysql` inside the container).
* **Website (WordPress) data**: `/home/tobaba/data/wordpress` (Synchronized with `/var/www/html` inside the container).

Because of this setup, existing post data and account settings will be fully restored upon the next startup, even after a VM reboot or running `make down`.