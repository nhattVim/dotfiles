#!/usr/bin/env python3
# Weather widget for Waybar / Hyprland
# Weather provider: Open-Meteo (https://open-meteo.com/)

import json
import os

import requests

# Weather icons mapped from Open-Meteo weather codes
ICONS = {
    0: "󰖙",  # Clear sky
    1: "󰖙",  # Mainly clear
    2: "",  # Partly cloudy
    3: "",  # Overcast
    45: "",  # Fog
    48: "",  # Depositing rime fog
    51: "",  # Light drizzle
    53: "",  # Moderate drizzle
    55: "",  # Dense drizzle
    61: "",  # Slight rain
    63: "",  # Moderate rain
    65: "",  # Heavy rain
    66: "",  # Freezing rain (light)
    67: "",  # Freezing rain (heavy)
    71: "󰼴",  # Slight snow fall
    73: "󰼴",  # Moderate snow fall
    75: "󰼴",  # Heavy snow fall
    77: "",  # Snow grains
    80: "",  # Rain showers (slight)
    81: "",  # Rain showers (moderate)
    82: "",  # Rain showers (violent)
    85: "󰼴",  # Snow showers (slight)
    86: "󰼴",  # Snow showers (heavy)
    95: "",  # Thunderstorm
    96: "",  # Thunderstorm with hail
    99: "",  # Thunderstorm with heavy hail
    "default": "",
}


def get_location():
    """Get current location (lat, lon) using IP."""
    try:
        data = requests.get("https://ipinfo.io", timeout=5).json()
        lat, lon = data["loc"].split(",")
        return float(lat), float(lon)
    except Exception:
        # fallback: Hanoi
        return 21.0285, 105.8542


def fetch_weather(lat, lon):
    """Fetch current weather from Open-Meteo API."""
    url = (
        f"https://api.open-meteo.com/v1/forecast"
        f"?latitude={lat}&longitude={lon}"
        f"&current=temperature_2m,apparent_temperature,weathercode,"
        f"relative_humidity_2m,wind_speed_10m,visibility"
    )
    return requests.get(url, timeout=5).json()["current"]


def main():
    lat, lon = get_location()
    current = fetch_weather(lat, lon)

    temp = f"{current['temperature_2m']}°C"
    temp_feel = f"Feels like {current['apparent_temperature']}°C"
    humidity = f"{current['relative_humidity_2m']}%"
    wind = f"{current['wind_speed_10m']} km/h"
    visibility = f"{round(current['visibility']/1000,1)} km"

    code = current["weathercode"]
    icon = ICONS.get(code, ICONS["default"])

    # Tooltip with Pango markup
    tooltip = (
        f"<span size='xx-large'>{temp}</span>\n"
        f"<big>{icon}</big>\n"
        f"<small>{temp_feel}</small>\n\n"
        f" {wind}\t {humidity}\n"
        f" {visibility}\n"
    )

    # Waybar output
    out = {
        "text": f"{icon} {temp}",
        "alt": str(code),
        "tooltip": tooltip,
        "class": str(code),
    }
    print(json.dumps(out))

    # Cache text
    simple_weather = (
        f"{icon} {temp}\n"
        f"{temp_feel}\n"
        f" {wind}\n"
        f" {humidity}\n"
        f" {visibility}\n"
    )
    try:
        with open(os.path.expanduser("~/.cache/.weather_cache"), "w") as f:
            f.write(simple_weather)
    except OSError as e:
        print(f"Error writing cache: {e}")


if __name__ == "__main__":
    main()
