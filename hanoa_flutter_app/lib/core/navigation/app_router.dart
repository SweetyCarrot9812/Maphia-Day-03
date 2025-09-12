import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../shared/screens/login_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/learning/presentation/concept_list_screen.dart';
import '../../features/learning/presentation/concept_edit_screen.dart';
import '../../features/learning/presentation/problem_list_screen.dart';
import '../../features/learning/presentation/problem_edit_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/notifications/presentation/pending_changes_screen.dart';
import '../../features/admin/presentation/super_admin_panel.dart';

/// Hanoa MVP 앱의 라우터 설정
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // 스플래시
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 인증
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      
      // 로그인
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // 온보딩
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // 홈
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // 학습 - 개념 목록
      GoRoute(
        path: '/concepts',
        name: 'concepts',
        builder: (context, state) => const ConceptListScreen(),
        routes: [
          // 개념 편집/생성
          GoRoute(
            path: '/edit',
            name: 'concept-edit',
            builder: (context, state) {
              final conceptId = state.uri.queryParameters['id'];
              return ConceptEditScreen(
                conceptId: conceptId != null ? int.parse(conceptId) : null,
              );
            },
          ),
        ],
      ),
      
      // 학습 - 문제 목록
      GoRoute(
        path: '/problems',
        name: 'problems',
        builder: (context, state) => const ProblemListScreen(),
        routes: [
          // 문제 편집/생성
          GoRoute(
            path: '/edit',
            name: 'problem-edit',
            builder: (context, state) {
              final problemId = state.uri.queryParameters['id'];
              return ProblemEditScreen(
                problemId: problemId != null ? int.parse(problemId) : null,
              );
            },
          ),
        ],
      ),
      
      // 설정
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // 변경 알림
      GoRoute(
        path: '/pending-changes',
        name: 'pending-changes',
        builder: (context, state) => const PendingChangesScreen(),
      ),
      
      // 슈퍼 관리자 패널 (권한 확인은 화면에서)
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const SuperAdminPanel(),
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
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
            const Text(
              '페이지를 찾을 수 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Path: ${state.matchedLocation}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('홈으로 이동'),
            ),
          ],
        ),
      ),
    ),
  );
}
