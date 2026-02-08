import 'package:flutter/material.dart';
import 'dart:ui';

class PricePage extends StatelessWidget {
  const PricePage({super.key});

  final List<Map<String, dynamic>> marketData = const [
    {"crop": "Rice", "price": "145.00", "trend": "up", "unit": "kg"},
    {"crop": "Corn", "price": "98.50", "trend": "down", "unit": "kg"},
    {"crop": "Tomato", "price": "210.00", "trend": "up", "unit": "kg"},
    {"crop": "Potato", "price": "120.00", "trend": "stable", "unit": "kg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background
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

                // Glass-style header
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
                        "Market Prices",
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

                // Price list area with glass bubbles
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: marketData.length,
                    itemBuilder: (context, index) {
                      final item = marketData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _glassBubble(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              // Crop icon
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withAlpha((0.3 * 255).round()),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.shopping_basket,
                                    color: Colors.greenAccent, size: 28),
                              ),
                              const SizedBox(width: 16),
                              // Crop name and unit
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['crop'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Per ${item['unit']}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Price and trend
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Rs. ${item['price']}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    item['trend'] == 'up'
                                        ? Icons.trending_up
                                        : item['trend'] == 'down'
                                            ? Icons.trending_down
                                            : Icons.trending_flat,
                                    color: item['trend'] == 'up'
                                        ? Colors.red
                                        : item['trend'] == 'down'
                                            ? Colors.greenAccent
                                            : Colors.white70,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

// Glass bubble widget (matching chatbot_page style)
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
