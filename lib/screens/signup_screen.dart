import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Ensure this path matches your project structure

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 1. Controllers to capture the text from each input field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    // 2. Always dispose controllers to prevent memory leaks
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // 3. Basic Validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Please fill in all required fields.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match!");
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 4. Call the AuthService to create the user in Firebase
      final user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (user != null) {
        // 5. Success! Navigate to Home or Welcome
        _showSnackBar("Account created successfully!");
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String msg = 'Registration failed. Please try again.';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This email is already in use. Try signing in or reset password.';
          break;
        case 'weak-password':
          msg = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'invalid-email':
          msg = 'The email address is not valid.';
          break;
        default:
          msg = e.message ?? msg;
      }

      _showSnackBar(msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Registration failed: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Branding Header
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              color: const Color(0xFF2ECC71), // Vibrant Green
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Image.asset('assets/logo.png', height: 80),
                  const Text(
                    'smart farming',
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      fontFamily: 'Serif'
                    ),
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
                    // Section Title Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent[400],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4))
                        ],
                      ),
                      child: const Text(
                        'Personal Details', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Icon(Icons.person, size: 30),
                    
                    // Input Fields
                    _buildTextField('First Name', Icons.person_outline, _firstNameController),
                    _buildTextField('Last Name', null, _lastNameController),
                    _buildTextField('E-mail', Icons.email_outlined, _emailController),
                    _buildTextField('Mobile Number', Icons.phone_outlined, _phoneController),
                    _buildTextField('Username', Icons.person_outline, _usernameController),
                    _buildTextField('Create Password', null, _passwordController, isPassword: true),
                    _buildTextField('Confirm Password', Icons.lock_outline, _confirmPasswordController, isPassword: true),
                    
                    const SizedBox(height: 30),
                    
                    // Next/Register Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.green)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent[400],
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            ),
                            onPressed: _handleSignup,
                            child: const Text(
                              'Next', 
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                            ),
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

  // Helper method to build text fields consistently
  Widget _buildTextField(String hint, IconData? icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: icon != null ? Icon(icon, color: Colors.black, size: 20) : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
        ),
      ),
    );
  }
}