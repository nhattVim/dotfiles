#!/bin/bash
# Online Music Toggle Menu

iDIR="$HOME/.config/swaync/icons"

declare -A menu_options=(
	["1.Lofi Girl"]="https://play.streamafrica.net/lofiradio"
	["2.Easy Rock"]="https://radio-stations-philippines.com/easy-rock"
	["3.Ghibli Music"]="https://youtube.com/playlist?list=PLNi74S754EXbrzw-IzVhpeAaMISNrzfUy&si=rqnXCZU5xoFhxfOl"
	["4.Top Youtube Music 2023"]="https://youtube.com/playlist?list=PLDIoUOhQQPlXr63I_vwF9GD8sAKh77dWU&si=y7qNeEVFNgA-XxKy"
	["5.Chillhop"]="http://stream.zeno.fm/fyn8eh3h5f8uv"
	["6.SmoothChill"]="https://media-ssl.musicradio.com/SmoothChill"
	["7.Relaxing Music"]="https://youtube.com/playlist?list=PLMIbmfP_9vb8BCxRoraJpoo4q1yMFg4CE"
	["8.Youtube Remix"]="https://youtube.com/playlist?list=PLeqTkIUlrZXlSNn3tcXAa-zbo95j0iN-0"
	["9.Korean Drama OST"]="https://youtube.com/playlist?list=PLUge_o9AIFp4HuA-A3e3ZqENh63LuRRlQ"
	["10.Hope Muzik"]="https://youtube.com/playlist?list=PLANV2QUPmwZ2wNXa5bNkwRgNGNmSt8xQz&si=Oy7BzjNN9TCMOe3q"
)

notification() {
	notify-send -u normal -i "$iDIR/music.png" "Playing now: $@"
}

main() {
	choice=$(printf "%s\n" "${!menu_options[@]}" | sort -n | rofi -dmenu -config ~/.config/rofi/config-beats.rasi -i -p "")

	# Exit if nothing is selected
	[ -z "$choice" ] && exit 0

	link="${menu_options[$choice]}"
	notification "$choice"

	# Check if the link is a playlist
	if [[ $link == *playlist* ]]; then
		mpv --shuffle --vid=no "$link"
	else
		mpv --vid=no "$link"
	fi
}

# --- Toggle logic ---
if pidof rofi >/dev/null; then
	# If rofi is running, kill it
	pkill rofi
	exit 0
elif pidof mpv >/dev/null; then
	# If mpv is running, kill it
	pkill mpv
	notify-send -u low -i "$iDIR/music.png" "Online Music stopped"
	exit 0
else
	main
fi
