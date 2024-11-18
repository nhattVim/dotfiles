#!/bin/bash

root_folder="weapon"
destination_folder="img_weapon"

# Đảm bảo thư mục đích tồn tại
mkdir -p "$destination_folder"

# Biến đếm toàn cục cho tên file
counter=1

# Hàm để tạo tên file mới
get_new_filename() {
    local extension="${1##*.}"
    local new_name

    while true; do
        new_name="image_${counter}.${extension}"
        if [ ! -e "$destination_folder/$new_name" ]; then
            break
        fi
        ((counter++))
    done

    echo "$new_name"
}

# Tìm và xử lý các thư mục
find "$root_folder" -type d | while IFS= read -r current_folder; do
    if [ -f "$current_folder/.JASM_ModConfig.json" ]; then
        # Tìm và sao chép các file phù hợp
        find "$current_folder" -maxdepth 1 -type f \( \
            -name "*.gif" -o \
            -name "*.png" -o \
            -name "*.jpeg" -o \
            -name "*.jpg" -o \
            -name "*.JASM_Cover.*" -o \
            -name "preview.png" \
        \) -print0 | while IFS= read -r -d '' file; do
            extension="${file##*.}"
            new_filename=$(get_new_filename "$extension")
            cp -f "$file" "$destination_folder/$new_filename"
            echo "Copied: $file to $destination_folder/$new_filename"
            ((counter++))
        done
    fi
done
