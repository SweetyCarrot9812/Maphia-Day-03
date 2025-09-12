import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Feature imports
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/dashboard/screens/student_dashboard.dart';
import '../../features/dashboard/screens/parent_dashboard.dart';
import '../../features/dashboard/screens/teacher_dashboard.dart';
// Attendance imports

// Story imports
import '../../features/story/screens/story_library_screen.dart';
import '../../features/story/screens/story_reading_screen.dart';

// Speaking imports
import '../../features/speaking/screens/speaking_lesson_list_screen.dart';
import '../../features/speaking/screens/speaking_practice_screen.dart' as speaking;

// Writing imports
import '../../features/writing/screens/writing_task_list_screen.dart';
import '../../features/writing/screens/writing_practice_screen.dart' as writing;

// Parent Reports imports
import '../../features/parent_reports/screens/parent_dashboard_screen.dart';

// Vehicle Tracking imports
import '../../features/vehicle_tracking/screens/vehicle_tracking_screen.dart' as vehicle;

// Admin Operations imports
import '../../features/admin/screens/admin_dashboard_screen.dart' as admin;

// Provider for router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: kDebugMode,
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // Dashboard Routes
      GoRoute(
        path: '/student-dashboard',
        name: 'studentDashboard',
        builder: (context, state) => const StudentDashboard(),
        routes: [
          // Student sub-routes
          GoRoute(
            path: 'attendance',
            name: 'studentAttendance',
            builder: (context, state) => const StudentAttendanceScreen(),
          ),
          GoRoute(
            path: 'learning',
            name: 'studentLearning',
            builder: (context, state) => const StudentLearningScreen(),
          ),
          GoRoute(
            path: 'story-library',
            name: 'storyLibrary',
            builder: (context, state) => const StoryLibraryScreen(userId: 'temp_user'),
          ),
          GoRoute(
            path: 'story/:storyId',
            name: 'storyLearning',
            builder: (context, state) {
              final storyId = state.pathParameters['storyId']!;
              return StoryLearningScreen(storyId: storyId);
            },
          ),
          GoRoute(
            path: 'speaking',
            name: 'speakingLessons',
            builder: (context, state) => const SpeakingLessonListScreen(userId: 'temp_user'),
          ),
          GoRoute(
            path: 'speaking/:lessonId',
            name: 'speakingPractice',
            builder: (context, state) {
              final lessonId = state.pathParameters['lessonId']!;
              final extra = state.extra as Map<String, dynamic>?;
              final userId = extra?['userId'] ?? 'temp_user';
              return speaking.SpeakingPracticeScreen(
                lessonId: lessonId,
                userId: userId,
              );
            },
          ),
          GoRoute(
            path: 'writing',
            name: 'writingTasks',
            builder: (context, state) => const WritingTaskListScreen(userId: 'temp_user'),
          ),
          GoRoute(
            path: 'writing/:taskId',
            name: 'writingPractice',
            builder: (context, state) {
              final taskId = state.pathParameters['taskId']!;
              return writing.WritingPracticeScreen(
                taskId: taskId,
              );
            },
          ),
          GoRoute(
            path: 'reading',
            name: 'readingLibrary',
            builder: (context, state) => const ReadingLibraryScreen(),
          ),
          GoRoute(
            path: 'reading/quiz/:bookId',
            name: 'readingQuiz',
            builder: (context, state) {
              final bookId = state.pathParameters['bookId']!;
              return ReadingQuizScreen(bookId: bookId);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/parent-dashboard',
        name: 'parentDashboard',
        builder: (context, state) => const ParentDashboard(),
        routes: [
          // Parent sub-routes
          GoRoute(
            path: 'reports',
            name: 'parentReports',
            builder: (context, state) => const ParentReportsScreen(),
          ),
          GoRoute(
            path: 'dashboard',
            name: 'parentDetailedDashboard',
            builder: (context, state) => const ParentDashboardScreen(parentId: 'parent1'),
          ),
          GoRoute(
            path: 'vehicle-tracking',
            name: 'vehicleTracking',
            builder: (context, state) => const vehicle.VehicleTrackingScreen(),
          ),
          GoRoute(
            path: 'child-progress/:childId',
            name: 'childProgress',
            builder: (context, state) {
              final childId = state.pathParameters['childId']!;
              return ChildProgressScreen(childId: childId);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/teacher-dashboard',
        name: 'teacherDashboard',
        builder: (context, state) => const TeacherDashboard(),
        routes: [
          // Teacher sub-routes
          GoRoute(
            path: 'attendance-approval',
            name: 'attendanceApproval',
            builder: (context, state) => const AttendanceApprovalScreen(),
          ),
          GoRoute(
            path: 'student-management',
            name: 'studentManagement',
            builder: (context, state) => const StudentManagementScreen(),
          ),
          GoRoute(
            path: 'writing-review',
            name: 'writingReview',
            builder: (context, state) => const WritingReviewScreen(),
          ),
          GoRoute(
            path: 'progress-reports',
            name: 'progressReports',
            builder: (context, state) => const ProgressReportsScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/admin-dashboard',
        name: 'adminDashboard',
        builder: (context, state) => const admin.AdminDashboardScreen(),
        routes: [
          // Admin sub-routes
          GoRoute(
            path: 'user-management',
            name: 'userManagement',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'system-settings',
            name: 'systemSettings',
            builder: (context, state) => const SystemSettingsScreen(),
          ),
          GoRoute(
            path: 'analytics',
            name: 'systemAnalytics',
            builder: (context, state) => const SystemAnalyticsScreen(),
          ),
          GoRoute(
            path: 'vehicle-management',
            name: 'vehicleManagement',
            builder: (context, state) => const VehicleManagementScreen(),
          ),
        ],
      ),

      // Global Story Routes (accessible from any role)
      GoRoute(
        path: '/story-reading/:storyId',
        name: 'storyReading',
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final story = extra?['story'];
          final userId = extra?['userId'] ?? 'temp_user';
          
          return StoryReadingScreen(
            storyId: storyId,
            userId: userId,
            story: story,
          );
        },
      ),

      // Error handling
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) => ErrorScreen(
          error: state.extra as String? ?? 'Unknown error',
        ),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error.toString(),
    ),
  );
});

// Placeholder screens (to be implemented)
class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('출석 체크')),
      body: const Center(child: Text('출석 체크 화면')),
    );
  }
}

class StudentLearningScreen extends StatelessWidget {
  const StudentLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('단어 학습')),
      body: const Center(child: Text('단어 학습 화면')),
    );
  }
}

class StoryLearningScreen extends StatelessWidget {
  final String storyId;
  
  const StoryLearningScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('스토리 학습 - $storyId')),
      body: Center(child: Text('스토리 학습 화면 - $storyId')),
    );
  }
}


class WritingPracticeScreen extends StatelessWidget {
  const WritingPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('라이팅 연습')),
      body: const Center(child: Text('라이팅 연습 화면')),
    );
  }
}

class ReadingLibraryScreen extends StatelessWidget {
  const ReadingLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('독서 라이브러리')),
      body: const Center(child: Text('독서 라이브러리 화면')),
    );
  }
}

class ReadingQuizScreen extends StatelessWidget {
  final String bookId;
  
  const ReadingQuizScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('독서 퀴즈 - $bookId')),
      body: Center(child: Text('독서 퀴즈 화면 - $bookId')),
    );
  }
}

class ParentReportsScreen extends StatelessWidget {
  const ParentReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('학습 리포트')),
      body: const Center(child: Text('학습 리포트 화면')),
    );
  }
}


class ChildProgressScreen extends StatelessWidget {
  final String childId;
  
  const ChildProgressScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('자녀 진도 - $childId')),
      body: Center(child: Text('자녀 진도 화면 - $childId')),
    );
  }
}

class AttendanceApprovalScreen extends StatelessWidget {
  const AttendanceApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('출석 승인')),
      body: const Center(child: Text('출석 승인 화면')),
    );
  }
}

class StudentManagementScreen extends StatelessWidget {
  const StudentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('학생 관리')),
      body: const Center(child: Text('학생 관리 화면')),
    );
  }
}

class WritingReviewScreen extends StatelessWidget {
  const WritingReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('라이팅 첨삭')),
      body: const Center(child: Text('라이팅 첨삭 화면')),
    );
  }
}

class ProgressReportsScreen extends StatelessWidget {
  const ProgressReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('진도 리포트')),
      body: const Center(child: Text('진도 리포트 화면')),
    );
  }
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용자 관리')),
      body: const Center(child: Text('사용자 관리 화면')),
    );
  }
}

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('시스템 설정')),
      body: const Center(child: Text('시스템 설정 화면')),
    );
  }
}

class SystemAnalyticsScreen extends StatelessWidget {
  const SystemAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('시스템 분석')),
      body: const Center(child: Text('시스템 분석 화면')),
    );
  }
}

class VehicleManagementScreen extends StatelessWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('차량 관리')),
      body: const Center(child: Text('차량 관리 화면')),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오류')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다'),
            const SizedBox(height: 8),
            Text(error, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('로그인으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}