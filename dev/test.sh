#!/bin/bash

# Function to display the menu
show_menu() {
    echo "======================"
    echo " Main Menu "
    echo "======================"
    echo "1. Hiển thị ngày giờ hiện tại"
    echo "2. Hiển thị danh sách tệp trong thư mục hiện tại"
    echo "3. Kiểm tra dung lượng đĩa"
    echo "4. Hiển thị địa chỉ IP"
    echo "5. Thoát"
}

# Function to read user choice and execute the selected option
read_choice() {
    read -p "Vui lòng chọn một tùy chọn [1-5]: " choice
    case $choice in
    1)
        echo "Ngày giờ hiện tại: $(date)"
        ;;
    2)
        echo "Danh sách tệp trong thư mục hiện tại:"
        ls -la
        ;;
    3)
        echo "Dung lượng đĩa:"
        df -h
        ;;
    4)
        echo "Địa chỉ IP:"
        hostname -I
        ;;
    5)
        echo "Thoát khỏi chương trình"
        exit 0
        ;;
    *)
        echo "Tùy chọn không hợp lệ, vui lòng chọn lại."
        ;;
    esac
}

# Main loop to display the menu and read user's choice
while true; do
    show_menu
    read_choice
    echo "" # New line for better readability
done
