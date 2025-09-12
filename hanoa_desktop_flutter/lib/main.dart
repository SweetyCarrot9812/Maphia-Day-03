import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'core/config.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'services/llm_proxy_service.dart';
import 'services/daily_batch_service.dart';
import 'shared/widgets/app_window_frame.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize locale data for Korean
  await initializeDateFormatting('ko_KR', null);
  
  // Load environment variables
  try {
    var env = DotEnv();
    env.load(); // load() 메서드는 void를 반환하므로 await 제거
    AppConfig.initialize(env);
  } catch (e) {
    logger.w('환경 변수 로드 실패: $e');
  }

  // Initialize window manager for desktop
  await _initializeWindowManager();
  
  // Initialize Firebase with options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i('Firebase 초기화 완료');
  } catch (e) {
    logger.w('Firebase 초기화 실패: $e');
  }
  
  // Initialize database
  final database = await DatabaseService.instance.initialize();
  
  // Initialize LLM proxy service
  await LlmProxyService.instance.initialize(database);
  await LlmProxyService.instance.initializePricingModels();
  
  // Initialize daily batch service
  await DailyBatchService.instance.initialize(database);
  
  // Initialize notification service
  await NotificationService.instance.initialize();

  logger.i('모든 서비스 초기화 완료');
  runApp(const ProviderScope(child: HanoaDesktopApp()));
}

Future<void> _initializeWindowManager() async {
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1400, 900),
    minimumSize: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: '🏠 Hanoa - Educational Hub Platform',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class HanoaDesktopApp extends ConsumerWidget {
  const HanoaDesktopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Hanoa Desktop - Educational Hub Platform',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
