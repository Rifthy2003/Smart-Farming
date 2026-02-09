import 'package:flutter/material.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) Navigator.pushNamed(context, '/notifications');
    if (index == 2) Navigator.pushNamed(context, '/chatbot');
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Weather',
        'icon': Icons.wb_sunny_outlined,
        'route': '/weather',
        'color': Colors.orangeAccent
      },
      {
        'title': 'Crop Selector',
        'icon': Icons.grass,
        'route': '/crop-selection',
        'color': Colors.greenAccent
      },
      {
        'title': 'Soil Health',
        'icon': Icons.agriculture,
        'route': '/soil',
        'color': Colors.brown
      },
      {
        'title': 'Market Price',
        'icon': Icons.show_chart,
        'route': '/price',
        'color': Colors.blueAccent
      },
      {
        'title': 'Crop Advisor',
        'icon': Icons.eco_outlined,
        'route': '/crop',
        'color': Colors.redAccent
      },
      {
        'title': 'Plant Doctor',
        'icon': Icons.medical_services_outlined,
        'route': '/doctor',
        'color': Colors.purpleAccent
      },
    ];

    final screenHeight = MediaQuery.of(context).size.height;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== WELCOME HEADER =====
                _glassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${widget.username}!',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Manage your farm smarter today 🌱',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // ===== FEATURE CARDS RESPONSIVE =====
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          constraints.maxWidth > 600 ? 3 : 2; // 3 columns on large screens
                      final childAspectRatio =
                          constraints.maxWidth / constraints.maxHeight * 1.5;

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: features.length,
                        itemBuilder: (context, index) {
                          final f = features[index];
                          return _glassContainer(
                            gradient: LinearGradient(
                              colors: [
                                (f['color'] as Color)
                                    .withAlpha((0.5 * 255).round()),
                                (f['color'] as Color)
                                    .withAlpha((0.25 * 255).round()),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            child: InkWell(
                              onTap: () =>
                                  Navigator.pushNamed(context, f['route'] as String),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: f['color'] as Color,
                                    ),
                                    child: Icon(f['icon'] as IconData,
                                        color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      f['title'] as String,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios,
                                      color: Colors.white70, size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ================= BOTTOM BAR =================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF185A9D).withAlpha((0.9 * 255).round()),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none), label: 'Alerts'),
            BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy_outlined), label: 'AI Bot'),
          ],
        ),
      ),
    );
  }

  // ================= GLASS CONTAINER =================
  Widget _glassContainer({
    required Widget child,
    double? height,
    EdgeInsetsGeometry? padding,
    Gradient? gradient,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          height: height,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? Colors.white.withAlpha((0.15 * 255).round()) : null,
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
}
