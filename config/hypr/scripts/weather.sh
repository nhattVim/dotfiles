#!/bin/bash

set -euo pipefail

city=""
cachedir="$HOME/.cache/rbn"
cachefile="$cachedir/weather-${1:-default}"

mkdir -p "$cachedir"

# refresh every 30min
cache_ttl=1740

# Refresh cache if too old or empty
if [[ ! -s "$cachefile" || $(($(date +%s) - $(stat -c '%Y' "$cachefile" 2>/dev/null || echo 0))) -gt $cache_ttl ]]; then
	mapfile -t data < <(curl -s "https://en.wttr.in/${city}${1:-}?0qnT")
	{
		echo "${data[0]%%,*}"             # Location
		echo "${data[1]#???????????????}" # Condition
		echo "${data[2]#???????????????}" # Temperature
	} >"$cachefile"
fi

mapfile -t weather <"$cachefile"

temperature=$(echo "${weather[2]}" | sed -E 's/([[:digit:]]+)\.\./\1 to /g')
condition_text=$(echo "${weather[1]##*,}" | tr '[:upper:]' '[:lower:]')

# Weather icons mapping
case "$condition_text" in
clear | sunny) icon="" ;;
"partly cloudy") icon="󰖕" ;;
cloudy) icon="" ;;
overcast) icon="" ;;
fog | "freezing fog") icon="" ;;
"patchy rain possible" | \
	"patchy light drizzle" | "light drizzle" | \
	"patchy light rain" | "light rain" | "light rain shower" | \
	mist | rain) icon="󰼳" ;;
"moderate rain at times" | "moderate rain" | \
	"heavy rain at times" | "heavy rain" | \
	"moderate or heavy rain shower" | "torrential rain shower" | \
	"rain shower") icon="" ;;
"patchy snow possible" | "patchy sleet possible" | \
	"patchy freezing drizzle possible" | "freezing drizzle" | \
	"heavy freezing drizzle" | "light freezing rain" | \
	"moderate or heavy freezing rain" | "light sleet" | \
	"ice pellets" | "light sleet showers" | \
	"moderate or heavy sleet showers") icon="󰼴" ;;
"blowing snow" | "moderate or heavy sleet" | \
	"patchy light snow" | "light snow" | "light snow showers") icon="󰙿" ;;
"blizzard" | "patchy moderate snow" | "moderate snow" | \
	"patchy heavy snow" | "heavy snow" | \
	"moderate or heavy snow with thunder" | "moderate or heavy snow showers") icon="" ;;
"thundery outbreaks possible" | "patchy light rain with thunder" | \
	"moderate or heavy rain with thunder" | "patchy light snow with thunder") icon="" ;;
*) icon="" ;;
esac

# Waybar JSON
echo -e "{\"text\":\"${temperature} ${icon}\", \"alt\":\"${weather[0]}\", \"tooltip\":\"${weather[0]}: ${temperature} ${weather[1]}\"}"

# Simple cache text
printf " %s\n%s %s\n" "$temperature" "$icon" "${weather[1]}" >"$HOME/.cache/.weather_cache"
