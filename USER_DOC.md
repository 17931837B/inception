# Inception - User Documentation

This document explains the basic usage procedures for end-users and administrators of the system built in the Inception project.

## 1. Stack Architecture Overview
This system consists of three independent containers built using Docker Compose:
* **NGINX**: An HTTPS-only web server utilizing TLSv1.2 / TLSv1.3 (accessible only via port 443).
* **WordPress + php-fpm**: An application server that processes and generates site content.
* **MariaDB**: A relational database that securely stores WordPress data.

## 2. Starting and Stopping the Project
To start or stop the containers of this system, run the following commands in the root directory of the repository:

* **Start the project**: Run `make all` (or `make`). The system will build and start in the background.
* **Stop the project**: Run `make down`. This will safely stop the system while preserving saved data (database and site files).

## 3. Accessing the Site and Admin Panel
You can use the system by accessing the following URLs from your web browser:

* **Website (Public Page)**: `https://tobaba.42.fr`
* **Admin Panel (Dashboard)**: `https://tobaba.42.fr/wp-admin`

*Note: Because this system uses a self-signed certificate, your browser may display a security warning upon your first visit. This is the expected behavior in a safe local environment, so please bypass the warning to continue accessing the site.*

## 4. Credential Management
The system is initially configured with the following two accounts. Authentication information, such as passwords, is managed securely via environment variables (in the `.env` file).

* **Administrator Account**: Has privileges to manage overall site settings and edit pages (due to security requirements, the username does not contain "admin").
* **Regular User Account**: An account with restricted privileges, capable of actions such as posting comments on articles.

**Password Change Procedure:**
1. Log in to the Admin Panel (`/wp-admin`).
2. Open "Users" > "Profile" from the left menu.
3. In the "Account Management" section at the bottom of the screen, click "Set New Password", change it to a password of your choice, and click "Update Profile".

## 5. Basic Checks
To ensure the system is operating correctly, please perform the following tests regularly:

* **HTTP Access Blocked**: Access `http://tobaba.42.fr` (port 80) and confirm that the connection is refused.
* **Comment Functionality Check**: Log in with the regular user account, add a comment to an article, and confirm that it is successfully published.
* **Content Editing Check**: Log in with the administrator account, edit a page from the dashboard, and confirm that the changes are correctly reflected on the public website.