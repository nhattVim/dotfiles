pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string city: "Ho Chi Minh City"
    property real latitude: 10.8231
    property real longitude: 106.6297
    property string timezone: "auto"
    property bool locating: false
    property bool locationReady: false
    property bool hasLocatedThisSession: false
    property bool geoParsed: false
    property int geoProviderIndex: 0
    property var geoFailures: []
    readonly property var geoProviders: [
        {
            name: "ipwho.is",
            url: "https://ipwho.is/"
        },
        {
            name: "ip-api.com",
            url: "http://ip-api.com/json/?fields=status,message,city,regionName,country,lat,lon,timezone"
        },
        {
            name: "ipapi.co",
            url: "https://ipapi.co/json/"
        }
    ]

    property bool loading: false
    property bool ready: false
    property string error: ""

    property real temperature: 0
    property real feelsLike: 0
    property int humidity: 0
    property real windSpeed: 0
    property int weatherCode: 0
    property string sunrise: "--:--"
    property string sunset: "--:--"
    property var forecast: []

    readonly property string condition: conditionForCode(weatherCode)
    readonly property string icon: iconForCode(weatherCode)
    readonly property string todayLabel: Qt.formatDate(new Date(), "dddd, MMM d")
    readonly property string cachePath: Quickshell.env("HOME") + "/.cache/ei/weather.json"

    function refresh() {
        if (!hasLocatedThisSession) {
            if (locationReady) {
                hasLocatedThisSession = true;
                fetchWeather();
                return;
            }
            locate();
            return;
        }
        fetchWeather();
    }

    function locate() {
        if (geoProcess.running || weatherProcess.running) return;

        locating = true;
        loading = true;
        error = "";
        geoProviderIndex = 0;
        geoFailures = [];
        startGeoRequest();
    }

    function startGeoRequest() {
        geoParsed = false;
        const provider = geoProviders[geoProviderIndex];
        if (!provider) {
            finishLocationFallback();
            return;
        }

        geoProcess.command = [
            "curl",
            "-sSL",
            "--max-time",
            "6",
            provider.url
        ];
        geoProcess.running = true;
    }

    function fetchWeather() {
        if (weatherProcess.running) return;

        loading = true;
        error = "";
        weatherProcess.command = [
            "curl",
            "-fsSL",
            "--max-time",
            "8",
            "https://api.open-meteo.com/v1/forecast?latitude=" + latitude
                + "&longitude=" + longitude
                + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m"
                + "&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset"
                + "&timezone=" + encodeURIComponent(timezone) + "&forecast_days=7"
        ];
        weatherProcess.running = true;
    }

    function parseGeoPayload(text) {
        const provider = geoProviders[geoProviderIndex] || { name: "unknown" };
        try {
            if (!text || text.trim().charAt(0) !== "{") throw "empty or non-json response";

            const data = JSON.parse(text);
            if (data.error === true) throw (data.reason || data.message || "provider rejected request");
            if (data.success === false || data.status === "fail") throw (data.message || "provider rejected request");

            const lat = Number(data.latitude !== undefined ? data.latitude : data.lat);
            const lon = Number(data.longitude !== undefined ? data.longitude : data.lon);

            if (!isFinite(lat) || !isFinite(lon)) throw "invalid coordinates";

            latitude = lat;
            longitude = lon;
            timezone = timezoneFromGeo(data);
            city = data.city || data.region || data.regionName || data.country_name || data.country || "Current Location";
            locationReady = true;
            hasLocatedThisSession = true;
            locating = false;
            geoParsed = true;
            fetchWeather();
        } catch (e) {
            geoFailures = geoFailures.concat([provider.name + ": " + e]);
        }
    }

    function timezoneFromGeo(data) {
        if (typeof data.timezone === "string") return data.timezone;
        if (data.timezone && typeof data.timezone.id === "string") return data.timezone.id;
        return "auto";
    }

    function finishLocationFallback() {
        locating = false;
        locationReady = true;
        hasLocatedThisSession = true;
        const details = geoFailures.length > 0 ? " (" + geoFailures.join("; ") + ")" : "";
        console.log("[WeatherService] location failed, using fallback coordinates" + details);
        fetchWeather();
    }

    function parsePayload(text, persist) {
        try {
            const data = JSON.parse(text);
            const current = data.current || {};
            const daily = data.daily || {};

            temperature = Math.round(Number(current.temperature_2m || 0));
            feelsLike = Math.round(Number(current.apparent_temperature || 0));
            humidity = Math.round(Number(current.relative_humidity_2m || 0));
            windSpeed = Math.round(Number(current.wind_speed_10m || 0) * 10) / 10;
            weatherCode = Number(current.weather_code || 0);
            sunrise = formatTime((daily.sunrise || [])[0] || "");
            sunset = formatTime((daily.sunset || [])[0] || "");

            let items = [];
            const times = daily.time || [];
            const codes = daily.weather_code || [];
            const maxTemps = daily.temperature_2m_max || [];
            const minTemps = daily.temperature_2m_min || [];
            for (let i = 0; i < Math.min(7, times.length); i++) {
                items.push({
                    day: i === 0 ? "Today" : dayName(times[i]),
                    date: shortDate(times[i]),
                    code: Number(codes[i] || 0),
                    icon: iconForCode(Number(codes[i] || 0)),
                    high: Math.round(Number(maxTemps[i] || 0)),
                    low: Math.round(Number(minTemps[i] || 0))
                });
            }
            forecast = items;
            ready = true;
            loading = false;
            error = "";

            if (persist) saveCache(text);
        } catch (e) {
            loading = false;
            error = "Weather unavailable";
            console.log("[WeatherService] parse failed:", e);
        }
    }

    function loadCache() {
        try {
            const text = cacheFile.text();
            if (!text || text.trim().length === 0) return;

            const cache = JSON.parse(text);
            if (cache.location) {
                city = cache.location.city || city;
                latitude = Number(cache.location.latitude || latitude);
                longitude = Number(cache.location.longitude || longitude);
                timezone = cache.location.timezone || timezone;
                locationReady = true;
                hasLocatedThisSession = true;
            }
            if (cache.weather) parsePayload(JSON.stringify(cache.weather), false);
        } catch (e) {
            try {
                const legacyText = cacheFile.text();
                if (legacyText && legacyText.trim().length > 0) parsePayload(legacyText, false);
            } catch (ignored) {
            }
        }
    }

    function saveCache(weatherText) {
        try {
            cacheFile.setText(JSON.stringify({
                location: {
                    city: city,
                    latitude: latitude,
                    longitude: longitude,
                    timezone: timezone
                },
                weather: JSON.parse(weatherText)
            }, null, 2));
        } catch (e) {
            console.log("[WeatherService] cache save failed:", e);
        }
    }

    function formatTime(value) {
        if (!value || value.indexOf("T") === -1) return "--:--";
        const parts = value.split("T")[1].split(":");
        let hour = Number(parts[0]);
        const minute = parts[1] || "00";
        const suffix = hour >= 12 ? "PM" : "AM";
        hour = hour % 12;
        if (hour === 0) hour = 12;
        return hour + ":" + minute + " " + suffix;
    }

    function dayName(value) {
        const date = new Date(value + "T00:00:00");
        return Qt.formatDate(date, "ddd");
    }

    function shortDate(value) {
        const date = new Date(value + "T00:00:00");
        return Qt.formatDate(date, "MMM d");
    }

    function conditionForCode(code) {
        if (code === 0) return "Clear";
        if (code === 1 || code === 2) return "Partly Cloudy";
        if (code === 3) return "Overcast";
        if (code === 45 || code === 48) return "Fog";
        if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return "Rain";
        if (code >= 71 && code <= 77) return "Snow";
        if (code >= 95) return "Thunderstorm";
        return "Cloudy";
    }

    function iconForCode(code) {
        if (code === 0) return "󰖙";
        if (code === 1 || code === 2) return "󰖕";
        if (code === 3) return "󰖐";
        if (code === 45 || code === 48) return "󰖑";
        if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return "󰖗";
        if (code >= 71 && code <= 77) return "󰖘";
        if (code >= 95) return "󰖓";
        return "󰖐";
    }

    FileView {
        id: cacheFile
        path: root.cachePath
        onLoaded: root.loadCache()
    }

    Process {
        id: weatherProcess
        running: false

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.parsePayload(text, true)
        }

        onExited: {
            root.loading = false;
            if (!root.ready && root.error === "") root.error = "Weather unavailable";
        }
    }

    Process {
        id: geoProcess
        running: false

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.parseGeoPayload(text)
        }

        onExited: {
            if (root.geoParsed) return;
            if (root.locating) {
                root.geoProviderIndex++;
                if (root.geoProviderIndex < root.geoProviders.length) {
                    root.startGeoRequest();
                } else {
                    root.finishLocationFallback();
                }
            }
        }
    }

    Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
