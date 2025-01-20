#!/bin/bash

# source library
source <(curl -sSL https://is.gd/nhattVim_lib) && clear

cleanup_backups() {
    CONFIG_DIR=$HOME/.config
    BACKUP_PREFIX="-backup"

    act "Performing clean up backup folders"

    for DIR in "$CONFIG_DIR"/*; do
        if [ -d "$DIR" ]; then
            BACKUP_DIRS=($(ls -dt "$DIR"$BACKUP_PREFIX* 2>/dev/null))

            if [ ${#BACKUP_DIRS[@]} -gt 1 ]; then

                if gum confirm "Found multiple backups for: ${DIR##*/}. Keep only the latest backup?" --affirmative "Yes" --negative "Delete all"; then
                    latest_backup="${BACKUP_DIRS[0]}"
                    for BACKUP in "${BACKUP_DIRS[@]}"; do
                        [ "$BACKUP" != "$latest_backup" ] && rm -rf "$BACKUP"
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

# for DIR in "${folder[@]}"; do
#     BACKUP_GLOB="$CONFIG_DIR/$DIR$BACKUP_PREFIX*"
#     BACKUP_DIRS=($(ls -dt $BACKUP_GLOB 2>/dev/null))
#
#     if [ ${#BACKUP_DIRS[@]} -gt 0 ]; then
#         if gum confirm "Found multiple backups for: $DIR. Keep only the latest backup?" --affirmative "Yes" --negative "Delete all"; then
#             latest_backup="${BACKUP_DIRS[0]}"
#             for BACKUP in "${BACKUP_DIRS[@]}"; do
#                 [ "$BACKUP" != "$latest_backup" ] && rm -rf "$BACKUP"
#             done
#             ok "Keeping: ${latest_backup##*/}"
#         else
#             for BACKUP in "${BACKUP_DIRS[@]}"; do
#                 rm -rf "$BACKUP"
#             done
#             ok "All backups deleted for: $DIR"
#         fi
#     fi
# done

cleanup_backups
