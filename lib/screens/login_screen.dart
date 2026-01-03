import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Double check this path matches your project

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isGoogleLoading = false; // To show loading state for Google button

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header (Logo + Title)
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              color: Colors.greenAccent[400],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 120),
                  const Text(
                    'smart farming', 
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      fontFamily: 'Serif'
                    )
                  ),
                ],
              ),
            ),
            
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
                    const Text(
                      "Login here", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController, 
                      decoration: const InputDecoration(hintText: 'Username or Email')
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController, 
                      obscureText: true, 
                      decoration: const InputDecoration(hintText: 'Password')
                    ),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                        child: const Text(
                          'Forgot your Password?', 
                          style: TextStyle(color: Colors.black54)
                        ),
                      ),
                    ),
                    
                    // Sign In Button
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent[400],
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      ),
                      onPressed: () async {
                        final user = await _authService.signIn(
                          _emailController.text.trim(), 
                          _passwordController.text.trim()
                        );
                        if (user != null) {
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Login Failed"))
                          );
                        }
                      },
                      child: const Text(
                        'Sign in', 
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        'Create new account', 
                        style: TextStyle(color: Colors.black)
                      ),
                    ),
                    
                    const Text("Or continue with"),
                    const SizedBox(height: 10),
                    
                    // --- UPDATED GOOGLE SIGN-IN BUTTON ---
                    _isGoogleLoading 
                      ? const CircularProgressIndicator(color: Colors.red)
                      : IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.google, 
                            color: Colors.red, 
                            size: 30
                          ),
                          onPressed: () async {
                            setState(() => _isGoogleLoading = true);
                            
                            print("Attempting Google Sign In...");
                            User? user = await _authService.signInWithGoogle();
                            
                            setState(() => _isGoogleLoading = false);

                            if (user != null) {
                              print("Google Login Successful: ${user.email}");
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              print("Google Login Cancelled or Failed");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Google Login failed or cancelled"))
                              );
                            }
                          },
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