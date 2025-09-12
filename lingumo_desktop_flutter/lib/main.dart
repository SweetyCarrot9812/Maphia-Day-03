import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'models/word_model.dart';
import 'services/word_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(WordModelAdapter());
  
  // Initialize word service
  await WordService.initializeBox();
  
  // Note: Firebase initialization commented out for desktop compatibility
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  runApp(const ProviderScope(child: LingumoDesktopApp()));
}

class LingumoDesktopApp extends StatefulWidget {
  const LingumoDesktopApp({super.key});

  @override
  State<LingumoDesktopApp> createState() => _LingumoDesktopAppState();
}

class _LingumoDesktopAppState extends State<LingumoDesktopApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingumo 데스크톱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Deep green for language learning
          primary: const Color(0xFF2E7D32), // Deep green
          secondary: const Color(0xFF1976D2), // Blue for interaction
          tertiary: const Color(0xFF388E3C), // Medium green
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFF1F8E9), // Light green surface
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32), // Deep green
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2), // Blue for actions
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2E7D32), // Deep green
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

