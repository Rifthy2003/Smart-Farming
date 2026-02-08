from flask import Flask, request, jsonify
import requests
import json

app = Flask(__name__)

# 🔴 PUT YOUR REAL OPENWEATHER API KEY HERE
API_KEY = "a45cc9612248502e3a5fe5930242e57b"

@app.route("/recommend_crops")
def recommend_crops():
    lat = request.args.get("lat")
    lon = request.args.get("lon")

    weather_url = (
        "https://api.openweathermap.org/data/2.5/weather"
        f"?lat={lat}&lon={lon}&appid={API_KEY}&units=metric"
    )

    response = requests.get(weather_url)
    weather_data = response.json()

    # ❌ If weather API fails
    if response.status_code != 200 or "main" not in weather_data:
        print("❌ Weather API Error:")
        print(weather_data)

        return jsonify({
            "error": "Weather API failed",
            "details": weather_data
        }), 500

    # ✅ Extract weather data
    temperature = weather_data["main"]["temp"]
    humidity = weather_data["main"]["humidity"]
    condition = weather_data["weather"][0]["description"]

    # ✅ Simple AI crop logic
    if humidity > 60 and temperature > 25:
        crop = "Rice"
    else:
        crop = "Maize"

    # ✅ Final output object
    result = {
        "lat": lat,
        "lon": lon,
        "temperature": temperature,
        "humidity": humidity,
        "weather": condition,
        "recommended_crop": crop
    }

    # 🔵 PRINT OUTPUT TO CONSOLE (THIS IS WHAT YOU ASKED)
    print("\n===== AI WEATHER & CROP OUTPUT =====")
    print(json.dumps(result, indent=4))
    print("===================================\n")

    # 🔵 SEND SAME OUTPUT TO FLUTTER
    return jsonify(result)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
