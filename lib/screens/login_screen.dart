import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../provider/language_provider.dart';
import '../services/auth_service.dart';
// If using the official flutter_localizations, import this:
 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isGoogleLoading = false;
  bool _isLoading = false; // email/password login loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Localization helper
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              color: const Color.fromARGB(255, 0, 22, 11),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  const Text(
                    'smart farming', 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                    )
                  ),
                ],
              ),
            ),
            
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    // --- LANGUAGE SELECTION BUTTONS ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _langButton(context, 'en', 'English'),
                        _langButton(context, 'ta', 'தமிழ்'),
                        _langButton(context, 'si', 'සිංහල'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      local.welcome, // Key in your ARB file
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _emailController, 
                      decoration: const InputDecoration(hintText: 'Email or username')
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController, 
                      obscureText: true, 
                      decoration: InputDecoration(hintText: local.password)
                    ),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                        child: const Text('Forgot password?', style: TextStyle(color: Colors.black54)), 
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.green)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent[400],
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                            ),
                            onPressed: () async {
                              final identifier = _emailController.text.trim();
                              final password = _passwordController.text.trim();

                              if (identifier.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter email/username and password'))
                                );
                                return;
                              }

                              setState(() => _isLoading = true);

                              try {
                                final user = await _authService.signInWithEmailOrUsername(identifier, password);
                                if (!mounted) return;
                                if (user != null) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              } on FirebaseAuthException catch (e) {
                                if (!mounted) return;
                                String message = 'Login failed. Please try again.';
                                switch (e.code) {
                                  case 'wrong-password':
                                    message = 'Wrong password. Please try again.';
                                    break;
                                  case 'user-not-found':
                                    message = 'No user found with that email/username.';
                                    break;
                                  case 'invalid-email':
                                    message = 'Invalid email format.';
                                    break;
                                  case 'too-many-requests':
                                    message = 'Too many attempts. Try again later.';
                                    break;
                                  default:
                                    message = e.message ?? message;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message))
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Login failed: ${e.toString()}'))
                                );
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            },
                            child: Text(
                              local.login, 
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                            ),
                        ),
                    ),
                    
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text(local.signup, style: const TextStyle(color: Colors.black)), 
                    ),
                    
                    const Text('Or continue with'),
                    const SizedBox(height: 15),
                    
                    // --- GOOGLE SIGN-IN BUTTON ---
                    _isGoogleLoading 
                      ? const CircularProgressIndicator(color: Colors.red)
                      : IconButton(
                          icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 35),
                          onPressed: () async {
                            setState(() => _isGoogleLoading = true);
                            User? user = await _authService.signInWithGoogle();
                            setState(() => _isGoogleLoading = false);

                            if (!mounted) return;

                            if (user != null) {
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login failed. Please try again.'))
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

  // Helper widget for language buttons
  Widget _langButton(BuildContext context, String code, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
        onPressed: () => context.read<LanguageProvider>().changeLanguage(code),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}