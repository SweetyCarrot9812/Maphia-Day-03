import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/database_service.dart';
import 'services/sample_data_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 서비스 초기화
  await StorageService.init();
  
  // 데이터베이스 초기화 시도, 실패 시 무시하고 진행
  try {
    await DatabaseService.init();
    
    // 샘플 데이터 초기화 (개발/테스트용)
    await SampleDataService.initializeSampleData();
    
    debugPrint('✅ 로컬 데이터베이스 초기화 완료');
  } catch (e) {
    debugPrint('⚠️  로컬 데이터베이스 초기화 실패, 서버 연동 모드로 전환: $e');
    // 서버 연동 모드로 계속 진행
  }
  
  runApp(const ClintestApp());
}

class ClintestApp extends StatelessWidget {
  const ClintestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        title: 'Clintest - 의료 학습 플랫폼',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}