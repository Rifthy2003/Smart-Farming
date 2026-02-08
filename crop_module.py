# crop_module.py
import math

# Crop Database (expand as needed)
CROP_DATA = [
    {
        "name": "Tomato",
        "pH_range": (6.0, 6.8),
        "moisture_range": (60, 80),
        "soil_temp_range": (18, 30),
        "ec_range": (1.2, 2.5),
        "ideal_temp_range": (18, 30),
        "ideal_rain_mm": (0, 10),
        "ideal_planting_months": {2,3,4}
    },
    {
        "name": "Rice",
        "pH_range": (5.5, 7.0),
        "moisture_range": (70, 90),
        "soil_temp_range": (22, 32),
        "ec_range": (0.8, 2.0),
        "ideal_temp_range": (22, 32),
        "ideal_rain_mm": (10, 30),
        "ideal_planting_months": {6,7,8}
    },
    {
        "name": "Carrot",
        "pH_range": (6.0, 7.0),
        "moisture_range": (50, 70),
        "soil_temp_range": (16, 24),
        "ec_range": (1.0, 2.0),
        "ideal_temp_range": (16, 24),
        "ideal_rain_mm": (0, 15),
        "ideal_planting_months": {3,4,5}
    }
]

def calculate_suitability(sensor, weather_summary, crop):
    """
    Score crop suitability based on soil + weather conditions
    """
    score = 0

    # Soil suitability
    if crop["pH_range"][0] <= sensor["pH"] <= crop["pH_range"][1]:
        score += 1
    if crop["moisture_range"][0] <= sensor["moisture"] <= crop["moisture_range"][1]:
        score += 1
    if crop["soil_temp_range"][0] <= sensor["soil_temp"] <= crop["soil_temp_range"][1]:
        score += 1
    if crop["ec_range"][0] <= sensor["ec"] <= crop["ec_range"][1]:
        score += 1

    # Weather suitability
    temp_matches = 0
    rain_matches = 0
    future_months = set()

    for day in weather_summary:
        if crop["ideal_temp_range"][0] <= day["temp"] <= crop["ideal_temp_range"][1]:
            temp_matches += 1
        if crop["ideal_rain_mm"][0] <= day["rain"] <= crop["ideal_rain_mm"][1]:
            rain_matches += 1
        future_months.add(day["date"].month)

    score += math.floor((temp_matches / len(weather_summary)) * 2)
    score += math.floor((rain_matches / len(weather_summary)) * 2)

    if future_months.intersection(crop["ideal_planting_months"]):
        score += 1

    return score

def suggest_crops(sensor_readings, weather_summary, crop_data=CROP_DATA):
    """
    Return crops sorted by suitability score
    """
    results = []
    for crop in crop_data:
        score = calculate_suitability(sensor_readings, weather_summary, crop)
        results.append({"crop": crop["name"], "score": score})

    # Sort descending by score
    results.sort(key=lambda x: x["score"], reverse=True)
    return results
