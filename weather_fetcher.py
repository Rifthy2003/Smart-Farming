# weather_fetcher.py
import requests
import datetime
from collections import defaultdict

class WeatherFetcher:
    """
    Real-time weather + FREE forecast + AI-estimated 7-day extension
    """
    def __init__(self, api_key):
        self.api_key = api_key

    # -------- REAL-TIME WEATHER (FREE) --------
    def get_current_weather(self, lat, lon, units="metric"):
        url = (
            f"https://api.openweathermap.org/data/2.5/weather?"
            f"lat={lat}&lon={lon}&units={units}&appid={self.api_key}"
        )
        response = requests.get(url)
        response.raise_for_status()
        return response.json()

    # -------- 5-DAY FORECAST (FREE) --------
    def get_forecast(self, lat, lon, units="metric"):
        url = (
            f"https://api.openweathermap.org/data/2.5/forecast?"
            f"lat={lat}&lon={lon}&units={units}&appid={self.api_key}"
        )
        response = requests.get(url)
        response.raise_for_status()
        return response.json()

    # -------- DAILY SUMMARY (FROM 5-DAY DATA) --------
    def summarize_weather(self, forecast):
        daily_data = defaultdict(list)

        for item in forecast["list"]:
            date = datetime.datetime.fromtimestamp(item["dt"]).date()
            daily_data[date].append(item)

        summary = []
        for date, items in daily_data.items():
            temps = [i["main"]["temp"] for i in items]
            rain = sum(i.get("rain", {}).get("3h", 0) for i in items)
            humidity = sum(i["main"]["humidity"] for i in items) / len(items)

            summary.append({
                "date": date,
                "temp": round(sum(temps) / len(temps), 1),
                "min_temp": round(min(temps), 1),
                "max_temp": round(max(temps), 1),
                "humidity": round(humidity, 1),
                "rain": round(rain, 1)
            })

        return summary

    # -------- AI-ESTIMATED EXTENDED FORECAST (7+ DAYS) --------
    def extend_forecast(self, daily_summary, extra_days=7):
        avg_temp = sum(d["temp"] for d in daily_summary) / len(daily_summary)
        avg_rain = sum(d["rain"] for d in daily_summary) / len(daily_summary)

        last_date = daily_summary[-1]["date"]
        extended = []

        for i in range(1, extra_days + 1):
            extended.append({
                "date": last_date + datetime.timedelta(days=i),
                "temp": round(avg_temp, 1),
                "min_temp": round(avg_temp - 2, 1),
                "max_temp": round(avg_temp + 2, 1),
                "humidity": daily_summary[-1]["humidity"],
                "rain": round(avg_rain, 1),
                "note": "Estimated"
            })

        return extended

    # -------- INTEGRATED REAL-TIME + 7-DAY FORECAST --------
    def get_integrated_forecast(self, lat, lon):
        current = self.get_current_weather(lat, lon)
        forecast = self.get_forecast(lat, lon)

        daily_summary = self.summarize_weather(forecast)
        extended = self.extend_forecast(daily_summary, extra_days=7)

        return {
            "current": {
                "date": datetime.date.today(),
                "temp": current["main"]["temp"],
                "humidity": current["main"]["humidity"],
                "rain": current.get("rain", {}).get("1h", 0)
            },
            "7_day_forecast": daily_summary[:7],
            "extended_forecast": extended
        }
