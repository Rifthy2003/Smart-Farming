import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'provider/language_provider.dart';

// Import all your screens
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';      
import 'screens/weather_page.dart';     
import 'screens/soil_page.dart';        
import 'screens/price_page.dart';       
import 'screens/crop_page.dart';        
import 'screens/chatbot_page.dart';     
import 'screens/notification_page.dart'; 
import 'screens/doctor_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    // Wrap the app in ChangeNotifierProvider so the language can change globally
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: const SmartFarmingApp(),
    ),
  );
}

class SmartFarmingApp extends StatelessWidget {
  const SmartFarmingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the LanguageProvider for locale changes
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Farming',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      
      // --- Localization Settings ---
      locale: languageProvider.currentLocale, 
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ta'), // Tamil
        Locale('si'), // Sinhala
      ],

      // --- Navigation Routes ---
      initialRoute: '/', 
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/weather': (context) => const WeatherPage(),
        '/soil': (context) => const SoilPage(),
        '/price': (context) => const PricePage(),
        '/crop': (context) => const CropPage(),
        '/chatbot': (context) => const ChatbotPage(),
        '/notifications': (context) => const NotificationPage(),
        '/doctor': (context) => const DoctorPage(),
      },
    );
  }
}