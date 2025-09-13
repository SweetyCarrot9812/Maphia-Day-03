import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/clintest_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase 초기화 완료');
  } catch (e) {
    print('Firebase 초기화 실패: $e');
  }

  runApp(const ProviderScope(child: HanoaWebApp()));
}

class HanoaWebApp extends ConsumerWidget {
  const HanoaWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Hanoa - Educational Hub Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/clintest',
      builder: (context, state) => const ClintestScreen(),
    ),
  ],
);

// 인증 상태에 따른 화면 라우팅
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 앱 초기화를 위한 짧은 지연
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('앱 초기화 중...'),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 초기 로딩 상태
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoginScreen(); // 기본적으로 로그인 화면 먼저 표시
        }

        // 사용자가 로그인되어 있는 경우
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // 로그인되지 않은 경우 (기본값)
        return const LoginScreen();
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService().signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isSuperAdmin = AuthService().isSuperAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hanoa - Educational Hub'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (user != null) ...[
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  await _signOut(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                        child: user.photoURL == null
                          ? Text(user.displayName?.substring(0, 1) ?? 'U')
                          : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.displayName ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user.email ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (isSuperAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'SUPER ADMIN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('로그아웃'),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                  child: user.photoURL == null
                    ? Text(
                        user.displayName?.substring(0, 1) ?? 'U',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
                ),
              ),
            ),
          ],
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Hanoa Educational Platform',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '통합 교육 허브 플랫폼',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),

              if (user != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                          child: user.photoURL == null
                            ? Text(
                                user.displayName?.substring(0, 1) ?? 'U',
                                style: const TextStyle(fontSize: 24),
                              )
                            : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '환영합니다, ${user.displayName ?? 'Unknown'}님!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user.email ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (isSuperAdmin)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'SUPER ADMIN',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        '서비스 목록',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.fitness_center, color: Colors.orange),
                        title: const Text('AreumFit'),
                        subtitle: const Text('피트니스 트레이닝'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('AreumFit 서비스 준비 중입니다')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.music_note, color: Colors.purple),
                        title: const Text('HaneulTone'),
                        subtitle: const Text('성악 레슨'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('HaneulTone 서비스 준비 중입니다')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.medical_services, color: Colors.red),
                        title: const Text('Clintest'),
                        subtitle: const Text('의학 교육'),
                        onTap: () {
                          context.go('/clintest');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}