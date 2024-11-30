#!/bin/bash
# config arch

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

ask_custom_option "Choose your databases" "mysql" "sql" db

if [ "$db" == "mysql" ]; then

    echo "
${NOTE} - Updating package list..."
    if sudo apt update; then
        echo "${OK} - Package list updated successfully"
    else
        echo "${ERROR} - Failed to update package list"
        exit 1
    fi

    echo "
${NOTE} - Installing MySQL Server..."
    if sudo apt install -y mysql-server; then
        echo "${OK} - MySQL Server installed successfully"
    else
        echo "${ERROR} - Failed to install MySQL Server"
        exit 1
    fi

    echo "
${NOTE} - Securing MySQL installation..."
    if sudo mysql_secure_installation; then
        echo "${OK} - MySQL secured successfully"
    else
        echo "${ERROR} - Failed to secure MySQL installation"
    fi

    echo "
${NOTE} - Checking MySQL Server status..."
    if systemctl status mysql --no-pager; then
        echo "${OK} - MySQL Server is running"
    else
        echo "${ERROR} - MySQL Server is not running. Check the status for more details"
        exit 1
    fi

    echo "
${OK} - MySQL Server is installed and configured"

elif [ "$db" == "sql" ]; then

    # Check Ubuntu version
    ubuntu_version=$(lsb_release -r | awk '{print $2}')

    if [[ "$ubuntu_version" != "20.04" && "$ubuntu_version" != "22.04" ]]; then
        echo "${ERROR} - SQL Server is only supported on Ubuntu 20.04 or 22.04. Your version is ${ubuntu_version}."
        exit 1
    fi

    echo "
${NOTE} - Adding Microsoft GPG key..."
    if curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc; then
        echo "${OK} - Microsoft GPG key added successfully"
    else
        echo "${ERROR} - Failed to add Microsoft GPG key"
        exit 1
    fi

    echo "
${NOTE} - Adding Microsoft SQL Server repository..."
    if curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list; then
        echo "${OK} - Microsoft SQL Server repository added successfully"
    else
        echo "${ERROR} - Failed to add Microsoft SQL Server repository"
        exit 1
    fi

    echo "
${NOTE} - Updating package list..."
    if sudo apt update; then
        echo "${OK} - Package list updated successfully"
    else
        echo "${ERROR} - Failed to update package list"
        exit 1
    fi

    echo "
${NOTE} - Installing SQL Server..."
    if sudo $(command -v nala || command -v apt) install -y mssql-server; then
        echo "${OK} - SQL Server installed successfully"
    else
        echo "${ERROR} - Failed to install SQL Server"
        exit 1
    fi

    echo "
${NOTE} - Running SQL Server setup..."
    if sudo /opt/mssql/bin/mssql-conf setup; then
        echo "${OK} - SQL Server setup completed successfully"
    else
        echo "${ERROR} - Failed to complete SQL Server setup"
        exit 1
    fi

    echo "
${NOTE} - Checking SQL Server status..."
    if systemctl status mssql-server --no-pager; then
        echo "${OK} - SQL Server is running"
    else
        echo "${ERROR} - SQL Server is not running. Check the status for more details"
        exit 1
    fi

    echo "
${OK} - SQL Server is installed and configured"
    echo "${OK} - You can use IP address $(ifconfig | grep 'broadcast' | awk '{print $2}') to connect to SQL Server"
fi
