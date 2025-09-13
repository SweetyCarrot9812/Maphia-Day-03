import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'generated/l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/notification_service.dart';
import 'widgets/auth_wrapper.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (check if already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase is already initialized, continue
    print('[INFO] Firebase already initialized: $e');
  }
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize notification service (web compatible)
  await NotificationService().initialize();
  
  // Request notification permissions
  await NotificationService().requestPermissions();
  
  runApp(const AreumfitApp());
}

class AreumfitApp extends StatelessWidget {
  const AreumfitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        title: 'AreumFit',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2AB1A2), // Primary Teal
            secondary: const Color(0xFFFF6F61), // Accent Coral
          ),
          useMaterial3: true,
          fontFamily: 'Pretendard',
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthWrapper(),
      ),
    );
  }
}