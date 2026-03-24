import 'package:flutter/material.dart';
import 'dart:ui';

class ChiliDetailPage extends StatelessWidget {
  const ChiliDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Full height gradient background
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 0,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back button + title
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
                              "Chili Planting Guide",
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
                  
                      // Chili icon
                      const Icon(Icons.local_fire_department, size: 100, color: Colors.redAccent),
                      const SizedBox(height: 20),
                  
                      // Glass content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _glassBubble(
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            "• Prefers warm climate (20–30°C)\n\n"
                            "• Well-drained sandy loam soil\n\n"
                            "• Transplant seedlings after 4–6 weeks\n\n"
                            "• Regular watering but avoid waterlogging\n\n"
                            "• Harvest when fruits turn red or green as needed",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 16, height: 1.5),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                  
                      const Spacer(), // pushes content up to fill bottom
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Glass bubble effect
Widget _glassBubble({required Widget child, EdgeInsetsGeometry? padding}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
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
