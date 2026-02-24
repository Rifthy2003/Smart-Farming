import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'provider/language_provider.dart';

// Screens
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
import 'screens/crop_selection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const SmartFarmingApp(),
    ),
  );
}

class SmartFarmingApp extends StatelessWidget {
  const SmartFarmingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Farming',

      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),

      // 🌍 Localization
      locale: languageProvider.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ta'),
        Locale('si'),
      ],

      // 🚀 Initial Route
      initialRoute: '/',

      // 📌 Static Routes
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/weather': (context) => const WeatherPage(),
        '/crop-selection': (context) => const CropSelectionPage(),
        '/soil': (context) => const SoilPage(),
        '/price': (context) => const PricePage(),
        '/crop': (context) => const CropPage(),
        '/chatbot': (context) => const ChatbotPage(),
        '/notifications': (context) => const NotificationPage(),
        '/doctor': (context) => const DoctorPage(),
      },

      // 🔄 Dynamic Routes
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final username =
              settings.arguments as String? ?? 'Farmer';

          return MaterialPageRoute(
            builder: (context) =>
                HomeScreen(username: username),
          );
        }
        return null;
      },
    );
  }
}
