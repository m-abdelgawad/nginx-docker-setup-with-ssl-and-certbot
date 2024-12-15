# Nginx Docker Setup with SSL and Certbot

## Table of Contents
- [Description](#description)
- [Features](#features)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Contact Information](#contact-information)

## Description
This project provides a robust and scalable Nginx setup using Docker. It is configured to serve multiple domains with SSL encryption managed by Let's Encrypt's Certbot. The setup ensures secure and efficient handling of web traffic, with automatic certificate renewal to maintain uninterrupted HTTPS services. This configuration is ideal for deploying web applications that require secure, reliable, and maintainable server infrastructure.

## Features
- **Dockerized Nginx Server**: Easily deploy Nginx within a Docker container for consistent environments across development and production.
- **SSL/TLS Encryption**: Secure your domains with SSL certificates obtained from Let's Encrypt.
- **Automatic Certificate Renewal**: Cron jobs are set up to automatically renew SSL certificates every 12 hours, ensuring continuous security without manual intervention.
- **Reverse Proxy Configuration**: Supports multiple server blocks to handle different subdomains and applications seamlessly.
- **Gzip Compression**: Optimizes web traffic by enabling Gzip compression for faster load times.
- **Static File Caching**: Efficiently serves static assets with appropriate caching headers to improve performance.
- **Scalable Networking**: Configured to work within a Docker network, allowing easy integration with other services.

## Project Structure
- **Dockerfile**: Defines the Docker image setup, including the installation of Nginx, Certbot, and Cron.
- **docker-compose.yml**: Manages the Docker service configurations, ports, volumes, and network settings.
- **default.conf**: Nginx configuration file that sets up server blocks for HTTP to HTTPS redirection and handles HTTPS requests for specified domains.
- **entrypoint.sh**: Entrypoint script that initializes SSL certificates if they do not exist and starts the Nginx server along with the Cron service for certificate renewal.
- **certs/**: Directory to store SSL certificates.

## Usage
To deploy the Nginx setup with SSL and automatic certificate renewal, ensure that your domain DNS settings are correctly configured and that the necessary ports (80 and 443) are open. The Docker configuration handles the setup and management of the Nginx server, SSL certificates, and automatic renewals, providing a secure and efficient web server environment.

## Contact Information
For any questions, issues, or contributions, please reach out to:

**Mohamed AbdelGawad**  
Email: [muhammadabdelgawwad@gmail.com](mailto:muhammadabdelgawwad@gmail.com)

