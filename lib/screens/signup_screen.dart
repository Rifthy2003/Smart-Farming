import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Branding Header
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              color: const Color(0xFF2ECC71), // Vibrant Green
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  const Text(
                    'smart farming',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                  ),
                ],
              ),
            ),
            // Form Section
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    // Section Title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent[400],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4))],
                      ),
                      child: const Text('Personal Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(height: 15),
                    const Icon(Icons.person, size: 30),
                    
                    // Input Fields
                    _buildTextField('First Name', Icons.person_outline),
                    _buildTextField('Last Name', null),
                    _buildTextField('E-mail', Icons.email_outlined),
                    _buildTextField('Mobile Number', Icons.phone_outlined),
                    _buildTextField('Username', Icons.person_outline),
                    _buildTextField('Create Password', null, isPassword: true),
                    _buildTextField('Confirm Password', Icons.lock_outline, isPassword: true),
                    
                    const SizedBox(height: 30),
                    // Next Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        onPressed: () {
                          // Logic to move to next part of registration or Firebase upload
                        },
                        child: const Text('Next', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
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

  Widget _buildTextField(String hint, IconData? icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: icon != null ? Icon(icon, color: Colors.black) : null,
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
        ),
      ),
    );
  }
}