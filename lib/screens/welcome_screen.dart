import 'package:flutter/material.dart';
import '../widgets/custom_pill_button.dart'; // Import your reusable pill button

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Green Overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.green.withOpacity(0.6), // Green tint matching Figma
            ),
          ),
          
          Column(
            children: [
              const SizedBox(height: 80),
              // Logo and Branding
              Image.asset('assets/logo.png', height: 120),
              const Text(
                'smart farming',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ),
              ),
              const Spacer(),
              
              // Bottom White Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9), // Light mint green background
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                ),
                child: Column(
                  children: [
                    CustomPillButton(
                      text: "Login",
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                    const SizedBox(height: 30),
                    CustomPillButton(
                      text: "Register",
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}