import 'package:flutter/material.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Function to handle bottom bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation for Bottom Bar items
    if (index == 1) Navigator.pushNamed(context, '/notifications');
    if (index == 2) Navigator.pushNamed(context, '/chatbot');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'SMART FARMING',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent[400],
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png'), // Ensure this exists in your assets
        ),
      ),
      body: Stack(
        children: [
          // Fullscreen background image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          // Light blur + subtle dark overlay so foreground remains readable
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(color: Colors.black.withOpacity(0.10)),
            ),
          ),

          // The existing content over the blurred background
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true, // Allows GridView to work inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), 
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildFeatureCard(context, 'Weather', Icons.wb_sunny_outlined, '/weather', Colors.orangeAccent),
                      _buildFeatureCard(context, 'Soil Health', Icons.agriculture, '/soil', Colors.brown),
                      _buildFeatureCard(context, 'Market Price', Icons.show_chart, '/price', Colors.blueAccent),
                      _buildFeatureCard(context, 'Crop Advisor', Icons.eco_outlined, '/crop', Colors.green),
                      
                      // --- NEW DOCTOR CARD ADDED HERE ---
                      _buildFeatureCard(context, 'Plant Doctor', Icons.medical_services_outlined, '/doctor', Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.greenAccent[100],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI Bot'),
        ],
      ),
    );
  }

  // Helper Widget to build the cards
  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, String route, Color iconColor) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.greenAccent[100]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                fontFamily: 'Serif'
              ),
            ),
          ],
        ),
      ),
    );
  }
}