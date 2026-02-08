import 'package:flutter/material.dart';
import 'dart:ui';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Header glass bubble
                _glassBubble(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Alerts & Notifications",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Notification list with glass bubbles
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: const [
                      _NotifyItem(
                          title: "Low Moisture",
                          msg: "Soil moisture in Sector A is 20%",
                          type: "alert"),
                      _NotifyItem(
                          title: "Market Update",
                          msg: "Tomato prices increased by 10%",
                          type: "info"),
                      _NotifyItem(
                          title: "Weather Warning",
                          msg: "Heavy rain expected tomorrow",
                          type: "warning"),
                    ],
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

// Glass bubble wrapper (matching chatbot_page style)
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

// Individual notification item with glass bubble
class _NotifyItem extends StatelessWidget {
  final String title, msg, type;
  const _NotifyItem(
      {required this.title, required this.msg, required this.type});

  @override
  Widget build(BuildContext context) {
    // Set color based on type
    Color iconColor;
    IconData iconData;

    if (type == "alert") {
      iconColor = Colors.redAccent;
      iconData = Icons.warning;
    } else if (type == "info") {
      iconColor = Colors.blueAccent;
      iconData = Icons.info;
    } else {
      iconColor = Colors.orangeAccent;
      iconData = Icons.report;
    }

    return _glassBubble(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(iconData, color: iconColor, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          msg,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: const Text(
          "2m ago",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }
}
