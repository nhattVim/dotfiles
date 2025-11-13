#!/bin/bash

MY_PASS="nhattVim2*"
APP_COMMAND="$@"

if [ -z "$APP_COMMAND" ]; then
    notify-send "Error" "No app specified"
    exit 1
fi

INPUT_PASS=$(zenity --password --title="App locked")

if [ "$INPUT_PASS" == "$MY_PASS" ]; then
    exec $APP_COMMAND
else
    notify-send -u critical "Access Denied" "Wrong password!"
    exit 1
fi
