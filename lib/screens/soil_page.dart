import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SoilPage extends StatelessWidget {
  const SoilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOIL"), backgroundColor: Colors.greenAccent[400], centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildSmallGauge("PH", 6.5),
                _buildSmallGauge("EC", 1.2),
                _buildSmallGauge("SM", 45.0),
                _buildSmallGauge("ST", 24.0),
              ],
            ),
          ),
          _buildActionButton("START", Colors.greenAccent[100]!),
          const SizedBox(height: 10),
          _buildActionButton("RESET", Colors.redAccent[100]!),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSmallGauge(String label, double value) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0, maximum: 100, showLabels: false, showTicks: false,
          axisLineStyle: const AxisLineStyle(thickness: 0.2, cornerStyle: CornerStyle.bothCurve, thicknessUnit: GaugeSizeUnit.factor),
          pointers: <GaugePointer>[NeedlePointer(value: value, needleLength: 0.6)],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(widget: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), angle: 90, positionFactor: 0.8)
          ],
        )
      ],
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4))],
      ),
      child: Center(child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    );
  }
}