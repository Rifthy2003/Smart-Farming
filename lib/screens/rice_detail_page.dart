import 'package:flutter/material.dart';
import 'dart:ui';

class RiceDetailPage extends StatelessWidget {
  const RiceDetailPage({super.key});

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

                _glassBubble(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () =>
                            Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Rice Planting Guide",
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

                Expanded(
                  child: SingleChildScrollView(
                    child: _glassBubble(
                      padding: const EdgeInsets.all(16),
                      child: const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Climate Requirements",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Rice grows best in temperatures between 20°C–35°C with high humidity and full sunlight.",
                            style:
                                TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Soil Preparation",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Clay or loamy soil with good water retention is ideal. Plough and level properly before planting.",
                            style:
                                TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Water Management",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Maintain shallow water (2–5 cm) during early growth and increase as plants mature.",
                            style:
                                TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Harvesting",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Harvest when grains turn golden yellow and moisture content is around 20–25%.",
                            style:
                                TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SAME glass bubble
Widget _glassBubble({
  required Widget child,
  EdgeInsetsGeometry? padding,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        padding: padding,
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
              color:
                  Colors.white.withAlpha((0.2 * 255).round())),
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
