#!/bin/bash

cleanup_backups() {
    CONFIG_DIR="$HOME/.config"
    BACKUP_PREFIX="-backup"

    act "Performing clean up backup folders"

    if [[ -n "$BASH_VERSION" ]]; then
        shopt -s nullglob
    elif [[ -n "$ZSH_VERSION" ]]; then
        setopt +o nomatch
    fi

    for DIR in "$CONFIG_DIR"/*; do
        if [[ -d "$DIR" ]]; then
            BACKUP_DIRS=()

            for BACKUP in "$DIR"$BACKUP_PREFIX*; do
                if [[ -d "$BACKUP" ]]; then
                    BACKUP_DIRS+=("$BACKUP")
                fi
            done

            if [[ ${#BACKUP_DIRS[@]} -gt 0 ]]; then
                IFS=$'\n' BACKUP_DIRS=($(printf "%s\n" "${BACKUP_DIRS[@]}" | sort -r))

                latest_backup="${BACKUP_DIRS[0]}"

                if gum confirm "Found backups for: ${DIR##*/}. Keep only the latest backup?" --affirmative "Yes" --negative "Delete all"; then
                    for ((i = 1; i < ${#BACKUP_DIRS[@]}; i++)); do
                        rm -rf "${BACKUP_DIRS[i]}"
                    done
                    ok "Keeping: ${latest_backup##*/}"
                else
                    for BACKUP in "${BACKUP_DIRS[@]}"; do
                        rm -rf "$BACKUP"
                    done
                    ok "All backups deleted for: ${DIR##*/}"
                fi
            fi
        fi
    done
}
}

cleanup_backups
