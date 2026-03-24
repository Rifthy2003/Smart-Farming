import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class CropSelectionPage extends StatefulWidget {
  const CropSelectionPage({super.key});

  @override
  State<CropSelectionPage> createState() => _CropSelectionPageState();
}

class _CropSelectionPageState extends State<CropSelectionPage>
    with SingleTickerProviderStateMixin {

  // Firebase
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('SensorData');
  StreamSubscription<DatabaseEvent>? _sensorSubscription;

  // Sensor values from Firebase
  double sensorTemp = 0;
  double sensorMoisture = 0;
  double sensorPH = 0;
  double sensorEC = 0;
  bool sensorSampling = false;
  bool isLoadingSensor = true;

  // Manual override
  bool isManualMode = false;
  final TextEditingController manualTempController = TextEditingController();
  final TextEditingController manualMoistureController = TextEditingController();
  final TextEditingController manualPHController = TextEditingController();
  final TextEditingController manualECController = TextEditingController();

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
    _listenToSensorData();

    _btnAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _btnAnimation = Tween<double>(begin: 1, end: 0.95).animate(
        CurvedAnimation(
            parent: _btnAnimationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel(); // ✅ cancel Firebase listener
    _btnAnimationController.dispose();
    manualTempController.dispose();
    manualMoistureController.dispose();
    manualPHController.dispose();
    manualECController.dispose();
    super.dispose();
  }

  // ✅ Real-time Firebase listener with proper subscription
  void _listenToSensorData() {
    _sensorSubscription = _dbRef.onValue.listen((DatabaseEvent event) {
      if (!mounted) return; // ✅ guard
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          sensorTemp = (data['temperature'] ?? 0).toDouble();
          sensorMoisture = (data['humidity'] ?? 0).toDouble();
          sensorPH = (data['pH'] ?? 0).toDouble();
          sensorEC = (data['ec_value'] ?? 0).toDouble();
          sensorSampling = data['sampling'] ?? false;
          isLoadingSensor = false;
        });
      }
    }, onError: (error) {
      if (!mounted) return; // ✅ guard
      setState(() => isLoadingSensor = false);
      debugPrint("Firebase Error: $error");
    });
  }

  Future<void> fetchWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final lat = position.latitude;
      final lon = position.longitude;

      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey";

      final res = await http.get(Uri.parse(url));

      if (!mounted) return; // ✅ guard

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
      if (!mounted) return; // ✅ guard
      setState(() => isLoadingWeather = false);
      debugPrint("Weather Error: $e");
    }
  }

  void recommendCrop() {
    double temp = isManualMode
        ? (double.tryParse(manualTempController.text) ?? sensorTemp)
        : sensorTemp;
    double moisture = isManualMode
        ? (double.tryParse(manualMoistureController.text) ?? sensorMoisture)
        : sensorMoisture;
    double ph = isManualMode
        ? (double.tryParse(manualPHController.text) ?? sensorPH)
        : sensorPH;
    double ec = isManualMode
        ? (double.tryParse(manualECController.text) ?? sensorEC)
        : sensorEC;

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
      recommendedCrop = suitableCrops.isEmpty
          ? 'No suitable crop found'
          : suitableCrops.first.name;
    });
  }

  Widget _inputField(
      String label, TextEditingController controller, Icon icon,
      {String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
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

  Widget _sensorRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
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
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white))
                      : Column(
                          children: [
                            const Text("Current Weather",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(children: [
                                  const Icon(Icons.water_drop,
                                      color: Colors.white),
                                  const SizedBox(height: 4),
                                  Text("${humidity.toStringAsFixed(0)}%",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  const Text("Humidity",
                                      style:
                                          TextStyle(color: Colors.white70)),
                                ]),
                                Column(children: [
                                  const Icon(Icons.air, color: Colors.white),
                                  const SizedBox(height: 4),
                                  Text(
                                      "${windSpeed.toStringAsFixed(1)} m/s",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  const Text("Wind Speed",
                                      style:
                                          TextStyle(color: Colors.white70)),
                                ]),
                              ],
                            ),
                          ],
                        ),
                  padding: const EdgeInsets.all(20),
                ),

                const SizedBox(height: 20),

                // ===== Live Sensor Data Card =====
                _glassBubble(
                  child: isLoadingSensor
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.sensors, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text("Live Sensor Data",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: sensorSampling
                                        ? Colors.green.withOpacity(0.4)
                                        : Colors.red.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: sensorSampling
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        sensorSampling
                                            ? Icons.circle
                                            : Icons.circle_outlined,
                                        color: sensorSampling
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        sensorSampling ? "Sampling" : "Idle",
                                        style: TextStyle(
                                          color: sensorSampling
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 20),
                            _sensorRow(
                                "Temperature",
                                "${sensorTemp.toStringAsFixed(1)} °C",
                                Icons.thermostat),
                            _sensorRow(
                                "Soil Moisture",
                                "${sensorMoisture.toStringAsFixed(1)} %",
                                Icons.water),
                            _sensorRow(
                                "Soil pH",
                                sensorPH.toStringAsFixed(2),
                                Icons.science),
                            _sensorRow(
                                "EC Value",
                                "${sensorEC.toStringAsFixed(2)} dS/m",
                                Icons.electrical_services),
                          ],
                        ),
                  padding: const EdgeInsets.all(20),
                ),

                const SizedBox(height: 20),

                // ===== Manual Override Toggle =====
                _glassBubble(
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Manual Override",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text("Enter values manually",
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ),
                      Switch(
                        value: isManualMode,
                        activeColor: Colors.greenAccent,
                        onChanged: (val) =>
                            setState(() => isManualMode = val),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                ),

                // ===== Manual Input Fields =====
                if (isManualMode)
                  _glassBubble(
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.edit_note, color: Colors.white),
                            SizedBox(width: 8),
                            Text("Enter Values Manually",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _inputField(
                          "Temperature (°C)",
                          manualTempController,
                          const Icon(Icons.thermostat, color: Colors.white),
                          hint: "Firebase: ${sensorTemp.toStringAsFixed(1)}",
                        ),
                        _inputField(
                          "Soil Moisture (%)",
                          manualMoistureController,
                          const Icon(Icons.water, color: Colors.white),
                          hint:
                              "Firebase: ${sensorMoisture.toStringAsFixed(1)}",
                        ),
                        _inputField(
                          "Soil pH",
                          manualPHController,
                          const Icon(Icons.science, color: Colors.white),
                          hint: "Firebase: ${sensorPH.toStringAsFixed(2)}",
                        ),
                        _inputField(
                          "Soil EC (dS/m)",
                          manualECController,
                          const Icon(Icons.electrical_services,
                              color: Colors.white),
                          hint: "Firebase: ${sensorEC.toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.white60, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Leave a field empty to use the live Firebase value instead.",
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                  ),

                const SizedBox(height: 20),

                // ===== Soil Type Selector =====
                _glassBubble(
                  child: Column(
                    children: [
                      const Text('Select Soil Type',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: soilType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              Colors.white.withAlpha((0.1 * 255).round()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none),
                        ),
                        dropdownColor:
                            Colors.blue.withAlpha((0.8 * 255).round()),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) =>
                            setState(() => soilType = value!),
                        items: <String>['Loamy', 'Sandy', 'Clay']
                            .map<DropdownMenuItem<String>>((type) =>
                                DropdownMenuItem(
                                    value: type, child: Text(type)))
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(recommendedCrop.isEmpty
                            ? 'No suitable crop found'
                            : 'Recommended: $recommendedCrop'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  onTapCancel: () => _btnAnimationController.reverse(),
                  child: ScaleTransition(
                    scale: _btnAnimation,
                    child: _glassBubble(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
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
                    child: Column(
                      children: [
                        const Icon(Icons.eco, color: Colors.white, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          recommendedCrop.isEmpty
                              ? 'Your recommended crop will appear here'
                              : 'Recommended Crop:\n$recommendedCrop',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        if (isManualMode && recommendedCrop.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "(Based on manual values)",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12),
                            ),
                          ),
                        if (!isManualMode && recommendedCrop.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "(Based on live sensor data)",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                ),

                const SizedBox(height: 20),
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
          border:
              Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
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
  final double minTemp, maxTemp;
  final double minMoisture, maxMoisture;
  final double minPH, maxPH;
  final double minEC, maxEC;
  final List<String> soilTypes;
  final double minHumidity, maxHumidity;
  final double minWindSpeed, maxWindSpeed;

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

final List<Crop> crops = [
  Crop(
      name: 'Rice',
      minTemp: 20, maxTemp: 35,
      minMoisture: 60, maxMoisture: 90,
      minPH: 5.5, maxPH: 7,
      minEC: 0, maxEC: 2,
      soilTypes: ['Clay', 'Loamy'],
      minHumidity: 60, maxHumidity: 100,
      minWindSpeed: 0, maxWindSpeed: 5),
  Crop(
      name: 'Wheat',
      minTemp: 12, maxTemp: 25,
      minMoisture: 40, maxMoisture: 60,
      minPH: 6, maxPH: 8,
      minEC: 0, maxEC: 1.5,
      soilTypes: ['Loamy', 'Sandy'],
      minHumidity: 40, maxHumidity: 70,
      minWindSpeed: 0, maxWindSpeed: 10),
  Crop(
      name: 'Chili',
      minTemp: 18, maxTemp: 30,
      minMoisture: 50, maxMoisture: 70,
      minPH: 5.8, maxPH: 7.2,
      minEC: 0, maxEC: 2,
      soilTypes: ['Loamy', 'Sandy'],
      minHumidity: 50, maxHumidity: 80,
      minWindSpeed: 0, maxWindSpeed: 7),
  Crop(
      name: 'Tomato',
      minTemp: 20, maxTemp: 30,
      minMoisture: 50, maxMoisture: 70,
      minPH: 6, maxPH: 7.5,
      minEC: 0, maxEC: 1.8,
      soilTypes: ['Loamy'],
      minHumidity: 50, maxHumidity: 80,
      minWindSpeed: 0, maxWindSpeed: 6),
];