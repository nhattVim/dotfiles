#!/usr/bin/env python3

import json
import os

import requests
from pyquery import PyQuery

# Weather icons
ICONS = {
    "sunnyDay": "󰖙",
    "clearNight": "󰖔",
    "cloudyFoggyDay": "",
    "cloudyFoggyNight": "",
    "rainyDay": "",
    "rainyNight": "",
    "snowyIcyDay": "",
    "snowyIcyNight": "",
    "severe": "",
    "default": "",
}


def get_location():
    """Get current location (lat, lon) using IP."""
    try:
        data = requests.get("https://ipinfo.io", timeout=5).json()
        lat, lon = data["loc"].split(",")
        return float(lat), float(lon)
    except Exception:
        # fallback: Manila
        return 14.5995, 120.9842


def fetch_weather_html(lat, lon):
    url = f"https://weather.com/en-PH/weather/today/l/{lat},{lon}"
    return PyQuery(url=url)


def safe_text(query, idx=0):
    """Return text from query, safe for missing nodes."""
    try:
        return query.eq(idx).text()
    except Exception:
        return ""


def main():
    lat, lon = get_location()
    html = fetch_weather_html(lat, lon)

    temp = safe_text(html("span[data-testid='TemperatureValue']"))
    status = html("div[data-testid='wxPhrase']").text()
    status = f"{status[:16]}.." if len(status) > 17 else status

    # extract status code from CSS class
    status_class = html("#regionHeader").attr("class") or ""
    status_code = (
        status_class.split(" ")[2].split("-")[2] if "-" in status_class else "default"
    )
    icon = ICONS.get(status_code, ICONS["default"])

    temp_feel = safe_text(
        html("div[data-testid='FeelsLikeSection'] span[data-testid='TemperatureValue']")
    )
    temp_feel_text = f"Feels like {temp_feel}c" if temp_feel else ""

    # min/max temp
    wx_data = html("div[data-testid='wxData'] span[data-testid='TemperatureValue']")
    temp_max, temp_min = safe_text(wx_data, 0), safe_text(wx_data, 1)
    temp_min_max = f" {temp_min}\t {temp_max}"

    wind = html("span[data-testid='Wind'] > span").text()
    humidity = html("span[data-testid='PercentageValue']").text()
    visibility = html("span[data-testid='VisibilityValue']").text()
    aqi = html("text[data-testid='DonutChartValue']").text()

    # hourly rain prediction
    prediction = html(
        "section[aria-label='Hourly Forecast'] div[data-testid='SegmentPrecipPercentage'] > span"
    ).text()
    prediction = (
        f"\n\n (hourly) {prediction.replace('Chance of Rain', '')}"
        if prediction
        else ""
    )

    # Tooltip (Pango markup)
    tooltip = (
        f"\t\t<span size='xx-large'>{temp}</span>\t\t\n"
        f"<big>{icon}</big>\n"
        f"<b>{status}</b>\n"
        f"<small>{temp_feel_text}</small>\n\n"
        f"<b>{temp_min_max}</b>\n"
        f" {wind}\t {humidity}\n"
        f" {visibility}\tAQI {aqi}\n"
        f"<i>{prediction}</i>"
    )

    # Output for Waybar
    out = {
        "text": f"{icon} {temp}",
        "alt": status,
        "tooltip": tooltip,
        "class": status_code,
    }
    print(json.dumps(out))

    # Simple cache text
    simple_weather = (
        f"{icon} {status}\n"
        f" {temp} ({temp_feel_text})\n"
        f" {wind}\n"
        f" {humidity}\n"
        f" {visibility} AQI {aqi}\n"
    )
    try:
        with open(os.path.expanduser("~/.cache/.weather_cache"), "w") as f:
            f.write(simple_weather)
    except OSError as e:
        print(f"Error writing cache: {e}")


if __name__ == "__main__":
    main()
