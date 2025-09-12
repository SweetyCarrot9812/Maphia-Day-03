import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'shared/widgets/app_initializer.dart';

// 웹이 아닌 플랫폼에서만 Isar import
import 'core/database/database.dart' if (dart.library.html) 'core/database/database_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🚀 로거 초기화 (가장 먼저)
  HanoaLogger.initialize();
  
  // 🔥 Firebase 초기화 (중복 방지)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Loggers.service.info('Firebase 초기화 완료');
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      Loggers.service.info('Firebase already initialized');
    } else {
      Loggers.service.error('Firebase 초기화 실패', e);
      rethrow;
    }
  }
  
  // 🛡️ Firebase App Check 초기화는 나중에 추가 예정
  
  // 세로 모드 고정 (모바일만)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialize database (웹에서는 스킵)
  if (!kIsWeb) {
    await Database.initialize();
  }

  runApp(const ProviderScope(child: HanoaApp()));
}

class HanoaApp extends ConsumerWidget {
  const HanoaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppInitializer(
      child: MaterialApp.router(
        title: 'Hanoa - 슈퍼앱',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}