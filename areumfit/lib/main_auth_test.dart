import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AreumfitAuthTestApp());
}

class AreumfitAuthTestApp extends StatelessWidget {
  const AreumfitAuthTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AreumFit Auth Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2AB1A2), // Primary Teal
          secondary: const Color(0xFFFF6F61), // Accent Coral
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const AuthWrapper(),
    );
  }
}