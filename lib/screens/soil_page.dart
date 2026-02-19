import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_database/firebase_database.dart';

class SoilPage extends StatelessWidget {
  const SoilPage({super.key});

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
                        "Soil Analysis",
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

                // 🔥 REALTIME DATABASE LIVE DATA
                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance
                        .ref('SensorData')
                        .onValue,
                    builder: (context, snapshot) {
                      // log connection state and any errors
                      // ignore: avoid_print
                      print('RTDB connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}, error=${snapshot.error}');

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                        return const Center(
                          child: Text(
                            "No Soil Data Available",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        );
                      }

                      // debug: print raw value to console so developer can inspect
                      final value = snapshot.data!.snapshot.value;
                      // ignore: avoid_print
                      print('RTDB SensorData value -> $value');

                      if (value is! Map) {
                        // show the raw data if it's not a map
                        return Center(
                          child: Text(
                            'Unexpected data: $value',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        );
                      }

                      final raw = value as Map<dynamic, dynamic>;
                      final data = Map<String, dynamic>.from(raw);

                      // try to parse all values, they may come as strings
                      double parse(dynamic w) {
                        if (w == null) return 0.0;
                        if (w is num) return w.toDouble();
                        return double.tryParse(w.toString()) ?? 0.0;
                      }

                      // fields coming from ESP32 may use different names;
                      // try several possibilities during parsing
                      double ph = parse(data['ph'] ?? data['pH']);
                      double ec = parse(data['ec'] ?? data['ec_value']);
                      double sm = parse(data['sm'] ?? data['humidity']);
                      double st = parse(data['st'] ?? data['temperature']);

                      // debug each reading
                      // ignore: avoid_print
                      print('parsed -> ph:$ph ec:$ec sm:$sm st:$st');

                      return GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          _buildSmallGauge("PH", ph),
                          _buildSmallGauge("EC", ec),
                          _buildSmallGauge("SM", sm),
                          _buildSmallGauge("ST", st),
                        ],
                      );
                    },
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

  Widget _buildSmallGauge(String label, double value) {
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
            // START button: write a flag to database to trigger sensor read
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
          padding: const EdgeInsets.symmetric(vertical: 16),
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
}

// Glass bubble widget
Widget _glassBubble({
  required Widget child,
  double? height,
  EdgeInsetsGeometry? padding,
  List<Color>? gradientColors,
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
            colors: gradientColors ??
                [
                  Colors.white.withAlpha((0.15 * 255).round()),
                  Colors.white.withAlpha((0.05 * 255).round()),
                ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withAlpha((0.2 * 255).round()),
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
