import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final String apiKey = "YOUR_OPEN_WEATHER_API_KEY"; // Get from openweathermap.org
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocationAndWeather();
  }

  Future<void> _getLocationAndWeather() async {
    try {
      // 1. Check/Request Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 2. Get Coordinates
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // 3. Fetch Weather using Lat/Lon
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LOCAL WEATHER"),
        backgroundColor: Colors.greenAccent[400],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : weatherData == null
              ? const Center(child: Text("Unable to load weather data"))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        weatherData!['name'], // City name detected by GPS
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      // Main Temperature Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent[100],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.wb_cloudy_outlined, size: 80, color: Colors.blue),
                            Text(
                              "${weatherData!['main']['temp'].round()}°C",
                              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              weatherData!['weather'][0]['main'],
                              style: const TextStyle(fontSize: 20, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Detailed Info Grid
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          children: [
                            _infoTile("Humidity", "${weatherData!['main']['humidity']}%"),
                            _infoTile("Wind", "${weatherData!['wind']['speed']} km/h"),
                            _infoTile("Pressure", "${weatherData!['main']['pressure']} hPa"),
                            _infoTile("Visibility", "${(weatherData!['visibility'] / 1000).toStringAsFixed(1)} km"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}