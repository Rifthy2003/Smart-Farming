import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_database/firebase_database.dart';

class CropSelectionPage extends StatelessWidget {
  const CropSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Header
                _glassBubble(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Crop Selection",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 REALTIME DATABASE STREAM
                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance
                        .ref('SensorData')
                        .onValue,
                    builder: (context, snapshot) {
                      // ignore: avoid_print
                      print('CropSelection RTDB connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}, error=${snapshot.error}');

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                        return const Center(
                          child: Text(
                            "No Soil Data Available",
                            style: TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        );
                      }

                      final value = snapshot.data!.snapshot.value;
                      // ignore: avoid_print
                      print('RTDB SensorData value -> $value');

                      if (value is! Map) {
                        return Center(
                          child: Text(
                            'Unexpected data: $value',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        );
                      }

                      final raw = value as Map<dynamic, dynamic>;
                      final data = Map<String, dynamic>.from(raw);

                      double parse(dynamic w) {
                        if (w == null) return 0.0;
                        if (w is num) return w.toDouble();
                        return double.tryParse(w.toString()) ?? 0.0;
                      }

                      double ph = parse(data['ph'] ?? data['pH']);
                      double ec = parse(data['ec'] ?? data['ec_value']);
                      double sm = parse(data['sm'] ?? data['humidity']);
                      double st = parse(data['st'] ?? data['temperature']);

                      // ignore: avoid_print
                      print('parsed -> ph:$ph ec:$ec sm:$sm st:$st');

                      return GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          _buildGauge("PH", ph),
                          _buildGauge("EC", ec),
                          _buildGauge("SM", sm),
                          _buildGauge("ST", st),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ===== CROP OPTIONS =====
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select a crop',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildCropCard(context, 'Rice'),
                      _buildCropCard(context, 'Wheat'),
                      _buildCropCard(context, 'Tomato'),
                      _buildCropCard(context, 'Chili'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildActionButton(context, "START", Colors.greenAccent),
                    const SizedBox(width: 16),
                    _buildActionButton(context, "RESET", Colors.redAccent),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGauge(String label, double value) {
    return _glassBubble(
      padding: const EdgeInsets.all(8),
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.2,
              cornerStyle: CornerStyle.bothCurve,
              thicknessUnit: GaugeSizeUnit.factor,
              color: Colors.white30,
            ),
            pointers: <GaugePointer>[
              NeedlePointer(
                value: value,
                needleLength: 0.6,
                needleColor: Colors.greenAccent,
              )
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                angle: 90,
                positionFactor: 0.8,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (label == "START") {
            // START button: trigger sensor sampling
            print('START button pressed');
            await FirebaseDatabase.instance
                .ref('SensorData')
                .update({
              "sampling": true,
              "timestamp": DateTime.now().millisecondsSinceEpoch,
            }).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sensor sampling started')),
              );
            }).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            });
          } else if (label == "RESET") {
            // RESET button: clear all sensor values
            print('RESET button pressed');
            await FirebaseDatabase.instance
                .ref('SensorData')
                .set({
              "pH": 0.0,
              "ec_value": 0.0,
              "humidity": 0.0,
              "temperature": 0.0,
              "sampling": false,
            }).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sensor data reset')),
              );
            }).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            });
          }
        },
        child: _glassBubble(
          padding:
              const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, String crop) {
    return GestureDetector(
      onTap: () {
        // navigate to crop detail page or handle selection
      },
      child: _glassBubble(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture, size: 40, color: Colors.greenAccent),
            const SizedBox(height: 8),
            Text(
              crop,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withAlpha((0.15 * 255).round()),
              Colors.white.withAlpha((0.05 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withAlpha(
                (0.2 * 255).round()),
          ),
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
