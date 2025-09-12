import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/app_window_frame.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/users/presentation/user_management_screen.dart';

import '../features/home/presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => AppWindowFrame(
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => AppWindowFrame(
          child: const AuthScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => AppWindowFrame(
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => AppWindowFrame(
          child: const UserManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/packages',
        name: 'packages',
        builder: (context, state) => AppWindowFrame(
          child: const _PlaceholderScreen(title: '패키지 관리'),
        ),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => AppWindowFrame(
          child: const _PlaceholderScreen(title: '학습 분석'),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => AppWindowFrame(
          child: const _PlaceholderScreen(title: '설정'),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('페이지를 찾을 수 없음'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '요청한 페이지를 찾을 수 없습니다.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${state.error}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Temporary placeholder screen for unimplemented routes
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.orange.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '이 기능은 개발 중입니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}

// Route extensions for easy navigation
extension GoRouterExtension on BuildContext {
  void goHome() => go('/');
  void goProblemManagement(String category) => go('/problem-management/$category');
  void goQuiz() => go('/learning/quiz');
  void goAnalysis() => go('/learning/analysis');
  void goJobs() => go('/system/jobs');
  void goHealth() => go('/system/health');
  void goAIGenerator() => go('/ai-generator');
  void goSettings() => go('/settings');
}