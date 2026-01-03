import 'package:flutter/material.dart';
import '../widgets/custom_pill_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Green Header with Logo
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              color: Colors.greenAccent[400],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 120),
                  const Text('smart farming', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Form Container
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    const CustomPillButton(text: "Login here", color: Colors.greenAccent),
                    const SizedBox(height: 40),
                    const TextField(decoration: InputDecoration(hintText: 'Username')),
                    const SizedBox(height: 20),
                    const TextField(obscureText: true, decoration: InputDecoration(hintText: 'Password')),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                        child: const Text('Forgot your Password?', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      onPressed: () { /* Add Firebase Auth Logic */ },
                      child: const Text('Sign in', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text('Create new account', style: TextStyle(color: Colors.black)),
                    ),
                    const Text("Or continue with"),
                    IconButton(
                      icon: const Icon(Icons.g_mobiledata, size: 40, color: Colors.red),
                      onPressed: () { /* Google Sign In Logic */ },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}