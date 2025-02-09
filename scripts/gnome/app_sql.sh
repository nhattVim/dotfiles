#!/bin/bash
# config arch

# source library
# . <(curl -sSL https://is.gd/nhattVim_lib)
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/lib.sh)

PKGMN=$(command -v nala || command -v apt)

choose "Choose your databases" "mysql" "sql" db

if [ "$db" == "mysql" ]; then

    note "Updating package list..."
    if sudo $PKGMN update; then
        ok "Package list updated successfully"
    else
        err "Failed to update package list"
        exit 1
    fi

    note "Installing MySQL Server..."
    if sudo $PKGMN install -y mysql-server; then
        ok "MySQL Server installed successfully"
    else
        err "Failed to install MySQL Server"
        exit 1
    fi

    note "Securing MySQL installation..."
    if sudo mysql_secure_installation; then
        ok "MySQL secured successfully"
    else
        err "Failed to secure MySQL installation"
    fi

    note "Checking MySQL Server status..."
    if systemctl status mysql --no-pager; then
        ok "MySQL Server is running successfully"
    else
        err "MySQL Server is not running. Check the status for more details"
        exit 1
    fi

    ok "MySQL Server is installed and configured"

elif [ "$db" == "sql" ]; then

    # Check Ubuntu version
    ubuntu_version=$(lsb_release -r | awk '{print $2}')

    if [[ "$ubuntu_version" != "20.04" && "$ubuntu_version" != "22.04" ]]; then
        err "SQL Server is only supported on Ubuntu 20.04 or 22.04. Your version is ${ubuntu_version}"
        exit 1
    fi

    note "Adding Microsoft GPG key..."
    if curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc; then
        ok "Microsoft GPG key added successfully"
    else
        err "Failed to add Microsoft GPG key"
        exit 1
    fi

    note "Adding Microsoft SQL Server repository..."
    if curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list; then
        ok "Microsoft SQL Server repository added successfully"
    else
        err "Failed to add Microsoft SQL Server repository"
        exit 1
    fi

    note "Updating package list..."
    if sudo $PKGMN update; then
        ok "Package list updated successfully"
    else
        err "Failed to update package list"
        exit 1
    fi

    note "Installing SQL Server..."
    if sudo $PKGMN install -y mssql-server; then
        ok "SQL Server installed successfully"
    else
        err "Failed to install SQL Server"
        exit 1
    fi

    note "Running SQL Server setup..."
    if sudo /opt/mssql/bin/mssql-conf setup; then
        ok "SQL Server setup completed successfully"
    else
        err "Failed to complete SQL Server setup"
        exit 1
    fi

    note "Checking SQL Server status..."
    if systemctl status mssql-server --no-pager; then
        ok "SQl Server is running"
    else
        err "SQL Server is not running. Check the status for more details"
        exit 1
    fi

    ok "SQL Server is installed and configured"
    ok "You can use IP address $(ifconfig | grep 'broadcast' | awk '{print $2}') to connect remote to SQL Server"
fi
