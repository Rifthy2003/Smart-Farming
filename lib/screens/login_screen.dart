import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../provider/language_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isGoogleLoading = false;
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email/username and password')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithEmailOrUsername(identifier, password);
      if (!mounted) return;
      if (user != null) {
        final username = identifier.contains('@') ? user.displayName ?? 'Farmer' : identifier;
        Navigator.pushReplacementNamed(context, '/home', arguments: username);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= GLASS CONTAINER =================
  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.15 * 255).round()),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withAlpha((0.1 * 255).round()),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withAlpha((0.3 * 255).round())),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _langButton(BuildContext context, String code, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: Colors.white.withAlpha((0.5 * 255).round())),
        ),
        onPressed: () => context.read<LanguageProvider>().changeLanguage(code),
        child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      // ================= FULL SCREEN BACKGROUND GRADIENT =================
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 100),
                        // ================= TOP CONTENT =================
                        Column(
                          children: [
                            Image.asset('assets/logo.png', height: 80),
                            const SizedBox(height: 12),
                            const Text(
                              'Smart Farming',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                        SizedBox(height: 200),
                        // ================= GLASS FORM =================
                        _glassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _langButton(context, 'en', 'English'),
                                  _langButton(context, 'ta', 'தமிழ்'),
                                  _langButton(context, 'si', 'සිංහල'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(local.welcome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              _buildTextField('Email or username', _emailController),
                              _buildTextField(local.password, _passwordController, isPassword: true),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                  child: const Text('Forgot password?', style: TextStyle(color: Colors.white70)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          backgroundColor: Colors.transparent,
                                        ),
                                        onPressed: _handleLogin,
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.login, color: Colors.white),
                                                SizedBox(width: 10),
                                                Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                  backgroundColor: Colors.transparent,
                                ),
                                onPressed: () => Navigator.pushNamed(context, '/signup'),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                                    child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text('Or continue with', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7))),
                              const SizedBox(height: 10),
                              _isGoogleLoading
                                  ? const CircularProgressIndicator(color: Colors.red)
                                  : IconButton(
                                      icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 35),
                                      onPressed: () async {
                                        setState(() => _isGoogleLoading = true);
                                        try {
                                          User? user = await _authService.signInWithGoogle();
                                          if (user != null && mounted) {
                                            Navigator.pushReplacementNamed(context, '/home', arguments: user.displayName ?? 'Farmer');
                                          }
                                        } catch (_) {
                                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Google sign-in failed')),
                                          );
                                        } finally {
                                          if (mounted) setState(() => _isGoogleLoading = false);
                                        }
                                      },
                                    ),
                            ],
                          ),
                        ),

                        const Spacer(), // Ensures the gradient fills till bottom
                      ],
                    ),
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
