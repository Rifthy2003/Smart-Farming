# main.py
from config import OPENWEATHER_API_KEY, DEFAULT_SENSOR_READINGS
from weather_fetcher import WeatherFetcher
from crop_module import suggest_crops
import sys

def main():
    print("🌱 Smart Farming AI Module")

    # Step 1: Input sensor readings (replace with real sensor data if available)
    sensor_readings = DEFAULT_SENSOR_READINGS
    print(f"Using sensor readings: {sensor_readings}")

    # Step 2: Input farm location
    try:
        lat = float(input("Enter latitude (e.g., 6.9271 for Colombo): "))
        lon = float(input("Enter longitude (e.g., 79.8612 for Colombo): "))
    except ValueError:
        print("Error: Please enter valid numeric coordinates.")
        sys.exit(1)

    # Step 3: Initialize WeatherFetcher
    fetcher = WeatherFetcher(OPENWEATHER_API_KEY)

    # Step 4: Fetch integrated weather (current + 7-day + extended)
    try:
        weather_data = fetcher.get_integrated_forecast(lat, lon)
    except Exception as e:
        print(f"Weather fetch error: {e}")
        sys.exit(1)

    # Step 5: Build daily summary for crop module (use 7-day forecast)
    daily_summary = weather_data["7_day_forecast"]

    # Step 6: Calculate crop suitability
    crop_scores = suggest_crops(sensor_readings, daily_summary)

    # Step 7: Display current weather
    print("\n🌤 Current Weather:")
    print(f"Date: {weather_data['current']['date']}")
    print(f"Temp: {weather_data['current']['temp']}°C")
    print(f"Humidity: {weather_data['current']['humidity']}%")
    print(f"Rain: {weather_data['current']['rain']}mm")

    # Step 8: Display crop recommendations
    print("\n🌱 Crop Suitability Recommendations (higher score = more suitable):")
    for r in crop_scores:
        print(f"{r['crop']}: Score {r['score']}")

    # Step 9: Display 7-day + extended forecast
    print("\n📅 7-Day Weather Forecast Summary:")
    for day in weather_data["7_day_forecast"]:
        print(f"{day['date']} - Temp: {day['temp']}°C (Min: {day['min_temp']}°C, Max: {day['max_temp']}°C) | Rain: {day['rain']}mm | Humidity: {day['humidity']}%")

    print("\n📅 AI-Estimated Extended Forecast (Next 7 Days):")
    for day in weather_data["extended_forecast"]:
        print(f"{day['date']} - Temp: {day['temp']}°C (Min: {day['min_temp']}°C, Max: {day['max_temp']}°C) | Rain: {day['rain']}mm | Humidity: {day['humidity']}% | {day['note']}")

if __name__ == "__main__":
    main()
