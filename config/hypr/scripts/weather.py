#!/usr/bin/env python3

import json
import os
from datetime import datetime, timedelta

import requests

# Weather icons mapping
weather_icons = {
    "clear-day": "󰖙",
    "clear-night": "󰖔",
    "partly-cloudy-day": "",
    "partly-cloudy-night": "",
    "cloudy": "",
    "fog": "",
    "rain": "",
    "drizzle": "",
    "thunderstorm": "",
    "snow": "",
    "sleet": "",
    "wind": "",
    "default": "",
}

CACHE_FILE = os.path.expanduser("~/.cache/weather_cache.json")
CACHE_TIME = 30  # Cache expiration time (minutes)


def get_location():
    """Retrieve latitude and longitude based on IP address."""
    try:
        response = requests.get("https://ipinfo.io/json")
        data = response.json()
        lat, lon = map(float, data["loc"].split(","))
        return lat, lon
    except Exception as e:
        print(f"⚠️ Error fetching location: {e}")
        return None, None


def fetch_weather(lat, lon):
    """Fetch weather data from Open-Meteo API."""
    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true"
    try:
        response = requests.get(url, timeout=5)
        return response.json() if response.status_code == 200 else None
    except Exception as e:
        print(f"⚠️ Error fetching weather data: {e}")
        return None


def get_cached_weather():
    """Read cached weather data if it's still valid."""
    if os.path.exists(CACHE_FILE):
        with open(CACHE_FILE, "r") as f:
            data = json.load(f)
        if "timestamp" in data and datetime.now() - datetime.fromisoformat(
            data["timestamp"]
        ) < timedelta(minutes=CACHE_TIME):
            return data
    return None


def save_cache(data):
    """Save weather data to cache."""
    data["timestamp"] = datetime.now().isoformat()
    with open(CACHE_FILE, "w") as f:
        json.dump(data, f)


def format_weather(data):
    """Format weather data for output."""
    temp = data["current_weather"]["temperature"]
    wind_speed = data["current_weather"]["windspeed"]
    status_code = data["current_weather"].get("weathercode", "default")
    icon = weather_icons.get(status_code, weather_icons["default"])

    return {
        "text": f"{icon} {temp}°C",
        "tooltip": f"<b>{icon} {temp}°C</b>\n💨 Wind: {wind_speed} km/h",
        "alt": f"Temp: {temp}°C, Wind: {wind_speed} km/h",
    }


def main():
    """Main function to fetch and display weather data."""
    lat, lon = get_location()
    if not lat or not lon:
        print(
            json.dumps(
                {"text": "⚠️ Error: No location", "tooltip": "Could not get location"}
            )
        )
        return

    data = get_cached_weather()
    if not data:
        data = fetch_weather(lat, lon)
        if data:
            save_cache(data)

    if data:
        output = format_weather(data)
        print(json.dumps(output))
    else:
        print(json.dumps({"text": "⚠️ No data", "tooltip": "Weather data unavailable"}))


if __name__ == "__main__":
    main()
