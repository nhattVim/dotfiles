#!/bin/bash
# Weather widget for Waybar / Hyprland
# Weather provider: Open-Meteo (https://open-meteo.com/)

cachedir="$HOME/.cache/rbn"
cachefile="$cachedir/weather.json"
cacheage=0

mkdir -p "$cachedir"

if [[ -f "$cachefile" ]]; then
	cacheage=$(($(date +%s) - $(stat -c '%Y' "$cachefile")))
fi

# refresh every 30 mins (1800s)
if [[ $cacheage -gt 1800 ]] || [[ ! -s $cachefile ]]; then
	# get location via ipinfo
	loc=$(curl -s --max-time 5 https://ipinfo.io/loc 2>/dev/null)
	if [[ -z "$loc" ]]; then
		# fallback: Hanoi
		lat=21.0285
		lon=105.8542
	else
		lat=${loc%,*}
		lon=${loc#*,}
	fi

	curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,apparent_temperature,weathercode,relative_humidity_2m,wind_speed_10m,visibility" \
		-o "$cachefile"
fi

current=$(jq -r '.current' "$cachefile")
temp=$(jq -r '.temperature_2m' <<<"$current")
temp_feel=$(jq -r '.apparent_temperature' <<<"$current")
humidity=$(jq -r '.relative_humidity_2m' <<<"$current")
wind=$(jq -r '.wind_speed_10m' <<<"$current")
visibility=$(jq -r '.visibility' <<<"$current")
code=$(jq -r '.weathercode' <<<"$current")

# Map weathercode to icons
case $code in
51 | 53 | 55) icon="" ;;                # drizzle
0 | 1) icon="󰖙" ;;                       # clear
2) icon="" ;;                           # partly cloudy
3) icon="" ;;                           # overcast
45 | 48) icon="" ;;                     # fog
61 | 63 | 65 | 80 | 81 | 82) icon="" ;; # rain
66 | 67) icon="" ;;                     # freezing rain
71 | 73 | 75 | 77 | 85 | 86) icon="󰼴" ;; # snow
95 | 96 | 99) icon="" ;;                # thunder
*) icon="" ;;
esac

temperature="${temp}°C"
tooltip=" ${temperature} (Feels like ${temp_feel}°C)\n ${wind} km/h    ${humidity}%\n $(awk "BEGIN{print $visibility/1000}") km"

# Output for waybar
echo -e "{\"text\":\"$icon $temperature\", \"alt\":\"$code\", \"tooltip\":\"$tooltip\"}"

# Cache simple weather text
echo -e " $temperature\n$icon code:$code\n $wind km/h\n $humidity%\n $(awk "BEGIN{print $visibility/1000}") km" \
	>"$HOME/.cache/.weather_cache"
