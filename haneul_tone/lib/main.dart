import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/cross_platform_storage_service.dart';
import 'services/auth_service.dart';
import 'services/sync_service.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // 크로스 플랫폼 데이터베이스 초기화
  try {
    final storageService = CrossPlatformStorageService();
    await storageService.initialize();
    print('${storageService.currentDatabaseType} 데이터베이스 초기화 완료');
  } catch (e) {
    print('데이터베이스 초기화 오류: $e');
  }
  
  runApp(const HaneulToneApp());
}

class HaneulToneApp extends StatelessWidget {
  const HaneulToneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialApp = MaterialApp(
      title: 'HaneulTone',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2), // 하늘색 테마
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSansKrTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.notoSansKr(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );

    return MultiProvider(
      providers: [
        Provider<CrossPlatformStorageService>(
          create: (_) => CrossPlatformStorageService(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: AuthInitializer(child: materialApp),
    );
  }
}

/// 인증 상태에 따라 화면을 분기하는 위젯
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // 초기화 중인 경우 로딩 화면 표시
        if (!authService.isInitialized) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'HaneulTone',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('앱을 초기화하는 중...'),
                ],
              ),
            ),
          );
        }

        // 로그인 상태에 따라 화면 분기
        if (authService.isLoggedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

/// AuthService 초기화를 위한 위젯
class AuthInitializer extends StatefulWidget {
  final Widget child;

  const AuthInitializer({
    super.key,
    required this.child,
  });

  @override
  State<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends State<AuthInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().initialize().whenComplete(() async {
        // Try flushing offline queue (best-effort)
        try {
          await SyncService.instance.init();
          final sent = await SyncService.instance.flushQueued();
          if (sent > 0) {
            debugPrint('Synced $sent queued session(s).');
          }
        } catch (_) {}
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
