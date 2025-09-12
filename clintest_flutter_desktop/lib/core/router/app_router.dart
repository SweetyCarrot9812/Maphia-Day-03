import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/nursing/presentation/nursing_screen.dart';
import '../../features/manual_input/presentation/manual_questions_screen.dart';
import '../../features/manual_input/presentation/manual_concepts_screen.dart';
import '../../features/manual_input/presentation/question_input_screen.dart';
import '../../features/ai_generation/presentation/ai_generation_screen.dart';
import '../../features/sync_management/presentation/sync_management_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/nursing',
      name: 'nursing',
      builder: (context, state) => const NursingScreen(),
    ),
    // 주요 기능 라우트들
    GoRoute(
      path: '/manual-questions',
      name: 'manual_questions',
      builder: (context, state) => const ManualQuestionsScreen(),
    ),
    GoRoute(
      path: '/manual-concepts',
      name: 'manual_concepts',
      builder: (context, state) => const ManualConceptsScreen(),
    ),
    GoRoute(
      path: '/question-input/:subject',
      name: 'question_input',
      builder: (context, state) {
        final subject = state.pathParameters['subject']!;
        final subjectColors = {
          '성인간호학': Colors.blue,
          '모성간호학': Colors.pink,
          '아동간호학': Colors.orange,
          '지역사회간호학': Colors.green,
          '정신간호학': Colors.purple,
          '간호관리학': Colors.red,
          '기본간호학': Colors.teal,
          '보건의약관계법규': Colors.brown,
        };
        
        return QuestionInputScreen(
          subject: subject,
          subjectColor: subjectColors[subject] ?? Colors.grey,
        );
      },
    ),
    GoRoute(
      path: '/ai-work',
      name: 'ai_work',
      builder: (context, state) => const AiGenerationScreen(),
    ),
    GoRoute(
      path: '/sync-management',
      name: 'sync_management',
      builder: (context, state) => const SyncManagementScreen(),
    ),
  ],
);