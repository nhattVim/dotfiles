#!/bin/bash

# This script installs and configures Microsoft SQL Server on an Ubuntu 22.04 system, including setting up the repository, installing the necessary packages, configuring the firewall, and displaying the server's IP address for connecting to SQL Server from window

source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

printf "\n%s - Adding Microsoft GPG key ... \n" "${NOTE}"
if curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc; then
    printf "\n%s - Microsoft GPG key added successfully \n" "${OK}"
else
    printf "\n%s - Failed to add Microsoft GPG key \n" "${ERROR}"
    exit 1
fi

printf "\n%s - Adding Microsoft SQL Server repository ... \n" "${NOTE}"
if curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list; then
    printf "\n%s - Microsoft SQL Server repository added successfully \n" "${OK}"
else
    printf "\n%s - Failed to add Microsoft SQL Server repository \n" "${ERROR}"
    exit 1
fi

printf "\n%s - Updating package list ... \n" "${NOTE}"
if sudo apt update; then
    printf "\n%s - Package list updated successfully \n" "${OK}"
else
    printf "\n%s - Failed to update package list \n" "${ERROR}"
    exit 1
fi

printf "\n%s - Installing SQL Server ... \n" "${NOTE}"
if sudo $(command -v nala || command -v apt) install -y mssql-server; then
    printf "\n%s - SQL Server installed successfully \n" "${OK}"
else
    printf "\n%s - Failed to install SQL Server \n" "${ERROR}"
    exit 1
fi

printf "\n%s - Running SQL Server setup ... \n" "${NOTE}"
if sudo /opt/mssql/bin/mssql-conf setup; then
    printf "\n%s - SQL Server setup completed successfully \n" "${OK}"
else
    printf "\n%s - Failed to complete SQL Server setup \n" "${ERROR}"
    exit 1
fi

printf "\n%s - Checking SQL Server status ... \n" "${NOTE}"
if systemctl status mssql-server --no-pager; then
    printf "\n%s - SQL Server is running \n" "${OK}"
else
    printf "\n%s - SQL Server is not running. Check the status for more details \n" "${ERROR}"
    exit 1
fi

if hostnamectl | grep -q 'wsl'; then
    printf "\n%s - Configuring firewall to allow SQL Server traffic on port 1433 ... \n" "${NOTE}"
    if sudo ufw allow 1433/tcp; then
        printf "\n%s - Firewall configured successfully \n" "${OK}"
    else
        printf "\n%s - Failed to configure firewall \n" "${ERROR}"
    fi
fi

printf "\n%s - SQL Server is installed and configured \n" "${OK}"
printf "\n%s - You can use IP address %s to connect to SQL Server \n" "${OK}" "$(ifconfig | grep 'broadcast' | awk '{print $2}')"
