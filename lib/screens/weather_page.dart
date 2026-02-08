import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? currentWeather;
  List<dynamic>? forecastData;
  bool isLoading = true;
  String errorMessage = '';

  final String apiKey = "a45cc9612248502e3a5fe5930242e57b";

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    fetchWeatherWithLocation();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw "Location services disabled";

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw "Location permission permanently denied";
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> fetchWeatherWithLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final position = await getCurrentLocation();
      final lat = position.latitude;
      final lon = position.longitude;

      final currentUrl =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey";

      final forecastUrl =
          "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey";

      final currentRes = await http.get(Uri.parse(currentUrl));
      final forecastRes = await http.get(Uri.parse(forecastUrl));

      if (currentRes.statusCode == 200 && forecastRes.statusCode == 200) {
        setState(() {
          currentWeather = json.decode(currentRes.body);
          forecastData = json.decode(forecastRes.body)['list'];
          isLoading = false;
        });
        _controller.forward(from: 0);
      } else {
        throw "Weather API error";
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  bool _isDayTime(String icon) => icon.contains('d');

  double _rainPercent(dynamic item) {
    if (item != null && item['pop'] != null) {
      return item['pop'] * 100;
    }
    return 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Text(errorMessage,
                          style: const TextStyle(color: Colors.white)),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // ===== Header =====
                              _glassBubble(
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back,
                                          color: Colors.white),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        "Weather",
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                              ),

                              const SizedBox(height: 25),

                              // ===== City & Description =====
                              Text(
                                currentWeather!['name'],
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                currentWeather!['weather'][0]['description'],
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white70),
                              ),

                              const SizedBox(height: 25),

                              // ===== Current Weather Card =====
                              _glassCard(_currentWeatherCard()),

                              const SizedBox(height: 35),

                              // ===== Forecast Card =====
                              _glassCard(_forecastCenterCard()),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  /// ======================
  /// GLASS BUBBLE WIDGET
  /// ======================
  Widget _glassBubble({
    required Widget child,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          height: height,
          padding:
              padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.15 * 255).round()),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassCard(Widget child) {
    return _glassBubble(child: child, padding: const EdgeInsets.all(16));
  }

  Widget _currentWeatherCard() {
    final iconCode = currentWeather!['weather'][0]['icon'];
    final isDay = _isDayTime(iconCode);

    return Column(
      children: [
        Icon(
          isDay ? Icons.wb_sunny : Icons.nights_stay,
          size: 64,
          color: isDay ? Colors.yellow : Colors.white,
        ),
        const SizedBox(height: 10),
        Text(
          "${currentWeather!['main']['temp'].toDouble().toStringAsFixed(1)} °C",
          style: const TextStyle(
              fontSize: 46, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _infoTile(Icons.water_drop,
                "${currentWeather!['main']['humidity']}%", "Humidity"),
            _infoTile(Icons.air,
                "${currentWeather!['wind']['speed']} m/s", "Wind"),
            _infoTile(Icons.umbrella,
                "${_rainPercent(currentWeather).toStringAsFixed(0)}%", "Rain"),
          ],
        ),
      ],
    );
  }

  Widget _forecastCenterCard() {
    return Column(
      children: [
        const Text("5-Day Outlook",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 15),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecastData!.length,
            itemBuilder: (context, index) {
              if (index % 8 != 0) return const SizedBox();
              final item = forecastData![index];
              final isDay = _isDayTime(item['weather'][0]['icon']);

              return Container(
                width: 110,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.25 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['dt_txt'].substring(5, 10),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Icon(
                      isDay ? Icons.wb_sunny : Icons.nights_stay,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${item['main']['temp'].toDouble().toStringAsFixed(1)} °C",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
