*This project was created as part of the 42 curriculum by tobaba.*

## 1. Description

This project aims to broaden my knowledge of system administration by using Docker. 
Using Docker Compose on a Virtual Machine (VM), I built a small-scale infrastructure consisting of three independent services: **NGINX**, **WordPress**, and **MariaDB**.

Instead of relying on pre-built Docker images or automated build tools, writing custom Dockerfiles from scratch deepened my practical understanding of containerization, service orchestration, network isolation, and data persistence.

## 2. Instructions

For detailed usage, technical design, and setup procedures, please refer to the following documentation:

* **[USER_DOC.md](./USER_DOC.md)**
    * Basic operations for end-users and administrators.
    * Accessing the site (public/admin panel) and managing credentials.
    * Basic testing procedures for expected behavior.

* **[DEV_DOC.md](./DEV_DOC.md)**
    * Environment setup guide for developers and reviewers.
    * Prerequisites (e.g., `/etc/hosts` configuration) and setup steps.
    * Details of Makefile commands (`make all`, `make fclean`, etc.).
    * Mechanics of data persistence (Bind Mounts).

**[Quick Start]**
To launch the project, run the following command in the root directory of the repository:
`make all`

## 3. Resources

The following resources were utilized during the development of this project:

* Official Docker Documentation
* Official NGINX, WordPress, and MariaDB Documentation
* **AI Usage**: Generative AI (LLM) was primarily used for analyzing error logs, debugging configuration files (such as NGINX routing and Docker volume mount paths), and assisting with the structuring and translation of the Markdown documentation required for the evaluation. All generated code and configurations were manually reviewed, tested, and fully understood before implementation.

---

## Technical Comparisons

Based on the project requirements, below is a comparison of the adopted technologies versus their alternatives.

### 1. Virtual Machine (VM) vs Docker (Container)


* **Virtual Machine (VM):**
    Virtualizes the entire hardware (CPU, memory, disk, etc.) and runs a guest OS on top of it. It operates on VirtualBox and is completely isolated, but because it boots a full OS, it consumes significant resources and takes time to start.
* **Docker (Container):**
    Shares the host OS's kernel and runs applications as isolated processes. Since it does not include a full OS, it is extremely lightweight and starts in seconds.
* **Setup in this Project:**
    Adopts an "Inception" (nested) architecture where Docker runs *inside* a VM.

| Feature | Virtual Machine | Docker Container |
| :--- | :--- | :--- |
| **Target of Virtualization** | Hardware | OS |
| **Guest OS** | Requires a full OS (Heavy) | Shares host OS kernel (Light) |
| **Size** | Several GBs to tens of GBs | Several MBs to hundreds of MBs |
| **Boot Speed** | Minutes (Slow) | Seconds/Milliseconds (Fast) |
| **Isolation Level** | Complete isolation (High security) | Process-level isolation |
| **Portability** | Dependent on the hypervisor | Runs anywhere with Docker Engine |

### 2. Secrets vs Environment Variables

* **Environment Variables:**
    Values are set in plain text within a `.env` file or `docker-compose.yml`. It is convenient, but carries the risk that third parties might view the values using commands like `docker inspect`.
* **Docker Secrets:**
    A mechanism to manage sensitive information securely by encrypting it and mounting it as files only inside necessary containers. It offers high security but requires a slightly more complex setup.
* **Adoption in this Project:**
    Following the assignment requirements and prioritizing configuration simplicity, **Environment Variables (.env)** were adopted. However, basic leakage countermeasures were implemented, such as excluding the `.env` file from Git tracking.

| Feature | Environment Variables | Docker Secrets |
| :--- | :--- | :--- |
| **Data State** | Plain text | Encrypted or file-mounted |
| **Visibility** | Visible via logs or `docker inspect` | Only accessible inside required containers |
| **Security** | Low (Risk of leakage) | High (Recommended method) |
| **Setup Complexity**| Simple (e.g., `.env` file) | Moderately complex (may require Swarm mode) |
| **Primary Use Cases**| Development environments, non-sensitive config | Production environments, passwords, API keys |

### 3. Docker Network vs Host Network


* **Host Network:**
    Containers share the host machine's IP address and ports. There is no network isolation, making port conflicts common (e.g., fails if the host is already using port 3306).
* **Docker Network (Bridge):**
    Creates a virtual private network within Docker. Containers are assigned internal IPs and can communicate with each other using container names (DNS). Only explicitly specified ports are exposed to the outside.
* **Adoption in this Project:**
    A custom bridge network `inception_network` (or the default project network) was created. This achieves a secure configuration where MariaDB is hidden from the outside and is only accessible from WordPress.

| Feature | Host Network | Docker Network (Bridge) |
| :--- | :--- | :--- |
| **IP Address** | Shares the host's IP | Has internal IPs per container |
| **Port Management**| Prone to conflicts (First-come, first-served) | Controlled via mapping (No conflicts) |
| **Isolation** | None (Same level as the host) | Yes (Independent network space) |
| **Name Resolution**| localhost / IP specification | Communicates via container/service names |
| **Performance** | High (No overhead) | Slight NAT overhead |

### 4. Docker Volumes vs Bind Mounts


* **Bind Mounts:**
    Directly mounts a file path from the host machine (e.g., `./data`) into the container. The location is clear, but since it is outside Docker's management, it can cause portability and permission issues.
* **Docker Volumes:**
    Uses a storage area managed by Docker (typically `/var/lib/docker/volumes`). It is safe, but it is not recommended for users to directly manipulate the physical location of the data.
* **Adoption in this Project:**
    To satisfy the requirement of "No Bind Mounts" while simultaneously "storing data in a specific host path (`/home/user/data`)", **Docker Named Volumes** were used alongside driver options (`driver_opts`) to bind the storage destination to the host directory.

| Feature | Bind Mounts | Docker Volumes |
| :--- | :--- | :--- |
| **Storage Location**| Any path on the host | Docker-managed area (`/var/lib/docker/volumes`) |
| **Managed By** | User (OS file system) | Docker CLI (`docker volume ...`) |
| **Portability** | Low (Depends on host's path structure) | High (Easy to move across Docker environments) |
| **Permissions** | Depends on host user permissions | Managed by Docker |
| **Primary Use Cases**| Config files, source code (Development) | Databases, persistent data (Production) |

---

## Directory Structure

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs
    ├── .env
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        │   ├── Dockerfile
        │   ├── conf/
        │   └── setting/
        ├── nginx
        │   ├── Dockerfile
        │   ├── conf/
        │   └── setting/
        └── wordpress
            ├── Dockerfile
            ├── conf/
            └── setting/