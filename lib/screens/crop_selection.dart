import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropSelectionPage extends StatefulWidget {
  const CropSelectionPage({super.key});

  @override
  State<CropSelectionPage> createState() => _CropSelectionPageState();
}

class _CropSelectionPageState extends State<CropSelectionPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController tempController = TextEditingController();
  final TextEditingController moistureController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController ecController = TextEditingController();

  String soilType = 'Loamy';
  String recommendedCrop = '';
  bool isLoadingWeather = true;

  double humidity = 0;
  double windSpeed = 0;

  final String apiKey = "a45cc9612248502e3a5fe5930242e57b";

  late AnimationController _btnAnimationController;
  late Animation<double> _btnAnimation;

  @override
  void initState() {
    super.initState();
    fetchWeather();

    _btnAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _btnAnimation = Tween<double>(begin: 1, end: 0.95)
        .animate(CurvedAnimation(parent: _btnAnimationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _btnAnimationController.dispose();
    super.dispose();
  }

  Future<void> fetchWeather() async {
    try {
      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final lat = position.latitude;
      final lon = position.longitude;

      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          humidity = data['main']['humidity'].toDouble();
          windSpeed = data['wind']['speed'].toDouble();
          isLoadingWeather = false;
        });
      } else {
        throw "Failed to load weather";
      }
    } catch (e) {
      setState(() {
        isLoadingWeather = false;
      });
      debugPrint("Weather Error: $e");
    }
  }

  void recommendCrop() {
    double temp = double.tryParse(tempController.text) ?? 0;
    double moisture = double.tryParse(moistureController.text) ?? 0;
    double ph = double.tryParse(phController.text) ?? 0;
    double ec = double.tryParse(ecController.text) ?? 0;

    List<Crop> suitableCrops = crops.where((crop) {
      return temp >= crop.minTemp &&
          temp <= crop.maxTemp &&
          moisture >= crop.minMoisture &&
          moisture <= crop.maxMoisture &&
          ph >= crop.minPH &&
          ph <= crop.maxPH &&
          ec >= crop.minEC &&
          ec <= crop.maxEC &&
          crop.soilTypes.contains(soilType) &&
          humidity >= crop.minHumidity &&
          humidity <= crop.maxHumidity &&
          windSpeed >= crop.minWindSpeed &&
          windSpeed <= crop.maxWindSpeed;
    }).toList();

    setState(() {
      recommendedCrop =
          suitableCrops.isEmpty ? 'No suitable crop found' : suitableCrops.first.name;
    });
  }

  Widget _inputField(String label, TextEditingController controller, Icon icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: icon,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white38),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Full screen gradient background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ===== Header =====
                _glassBubble(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Crop Advisor",
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

                const SizedBox(height: 20),

                // ===== Weather Card =====
                _glassBubble(
                  child: isLoadingWeather
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Column(
                          children: [
                            const Text("Current Weather",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.water_drop, color: Colors.white),
                                    const SizedBox(height: 4),
                                    Text("${humidity.toStringAsFixed(0)}%",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    const Text("Humidity",
                                        style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.air, color: Colors.white),
                                    const SizedBox(height: 4),
                                    Text("${windSpeed.toStringAsFixed(1)} m/s",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    const Text("Wind Speed",
                                        style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                  padding: const EdgeInsets.all(20),
                ),

                const SizedBox(height: 20),

                // ===== Soil Inputs =====
                _glassBubble(
                  child: Column(
                    children: [
                      const Text('Enter Soil Data',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      _inputField("Soil Temperature (°C)", tempController,
                          const Icon(Icons.thermostat, color: Colors.white)),
                      _inputField("Soil Moisture (%)", moistureController,
                          const Icon(Icons.water, color: Colors.white)),
                      _inputField("Soil pH", phController,
                          const Icon(Icons.science, color: Colors.white)),
                      _inputField("Soil EC (dS/m)", ecController,
                          const Icon(Icons.grass, color: Colors.white)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: soilType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withAlpha((0.1 * 255).round()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none),
                        ),
                        dropdownColor: Colors.blue.withAlpha((0.8 * 255).round()),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            soilType = value!;
                          });
                        },
                        items: <String>['Loamy', 'Sandy', 'Clay']
                            .map<DropdownMenuItem<String>>(
                                (type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                ),

                const SizedBox(height: 16),

                // ===== Recommend Button =====
                GestureDetector(
                  onTapDown: (_) => _btnAnimationController.forward(),
                  onTapUp: (_) {
                    _btnAnimationController.reverse();
                    recommendCrop();
                  },
                  child: ScaleTransition(
                    scale: _btnAnimation,
                    child: _glassBubble(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.agriculture, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Recommend Crop',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ===== Recommendation Result =====
                _glassBubble(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      recommendedCrop.isEmpty
                          ? 'Your recommended crop will appear here'
                          : 'Recommended Crop: $recommendedCrop',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================== Glass Bubble Widget ===================
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
        height: height,
        padding: padding,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.15 * 255).round()),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
          ],
        ),
        child: child,
      ),
    ),
  );
}

// =================== Crop Model ===================
class Crop {
  final String name;
  final double minTemp;
  final double maxTemp;
  final double minMoisture;
  final double maxMoisture;
  final double minPH;
  final double maxPH;
  final double minEC;
  final double maxEC;
  final List<String> soilTypes;
  final double minHumidity;
  final double maxHumidity;
  final double minWindSpeed;
  final double maxWindSpeed;

  Crop({
    required this.name,
    required this.minTemp,
    required this.maxTemp,
    required this.minMoisture,
    required this.maxMoisture,
    required this.minPH,
    required this.maxPH,
    required this.minEC,
    required this.maxEC,
    required this.soilTypes,
    required this.minHumidity,
    required this.maxHumidity,
    required this.minWindSpeed,
    required this.maxWindSpeed,
  });
}

// Sample crops
final List<Crop> crops = [
  Crop(
    name: 'Rice',
    minTemp: 20,
    maxTemp: 35,
    minMoisture: 60,
    maxMoisture: 90,
    minPH: 5.5,
    maxPH: 7,
    minEC: 0,
    maxEC: 2,
    soilTypes: ['Clay', 'Loamy'],
    minHumidity: 60,
    maxHumidity: 100,
    minWindSpeed: 0,
    maxWindSpeed: 5,
  ),
  Crop(
    name: 'Wheat',
    minTemp: 12,
    maxTemp: 25,
    minMoisture: 40,
    maxMoisture: 60,
    minPH: 6,
    maxPH: 8,
    minEC: 0,
    maxEC: 1.5,
    soilTypes: ['Loamy', 'Sandy'],
    minHumidity: 40,
    maxHumidity: 70,
    minWindSpeed: 0,
    maxWindSpeed: 10,
  ),
  Crop(
    name: 'Chili',
    minTemp: 18,
    maxTemp: 30,
    minMoisture: 50,
    maxMoisture: 70,
    minPH: 5.8,
    maxPH: 7.2,
    minEC: 0,
    maxEC: 2,
    soilTypes: ['Loamy', 'Sandy'],
    minHumidity: 50,
    maxHumidity: 80,
    minWindSpeed: 0,
    maxWindSpeed: 7,
  ),
  Crop(
    name: 'Tomato',
    minTemp: 20,
    maxTemp: 30,
    minMoisture: 50,
    maxMoisture: 70,
    minPH: 6,
    maxPH: 7.5,
    minEC: 0,
    maxEC: 1.8,
    soilTypes: ['Loamy'],
    minHumidity: 50,
    maxHumidity: 80,
    minWindSpeed: 0,
    maxWindSpeed: 6,
  ),
];
