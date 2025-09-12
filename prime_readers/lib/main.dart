import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'features/attendance/models/attendance_model.dart';
import 'features/attendance/services/attendance_service.dart';
import 'features/vocabulary/models/vocabulary_model.dart';
import 'features/vocabulary/services/vocabulary_service.dart';
import 'features/speaking/models/speaking_models.dart';
import 'features/speaking/services/speaking_service.dart';
import 'features/writing/models/writing_models.dart' hide DifficultyLevelAdapter;
import 'features/reading/models/reading_models.dart';
import 'features/reading/services/reading_service.dart';
import 'features/reading/services/quiz_service.dart';
import 'features/parent_reports/models/report_models.dart';
import 'features/parent_reports/services/report_service.dart';
import 'features/parent_reports/services/notification_service.dart';
import 'features/vehicle_tracking/models/vehicle_models.dart';
import 'features/vehicle_tracking/services/vehicle_service.dart';
import 'features/admin/models/admin_models.dart';
import 'features/admin/services/admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters for attendance system
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AttendanceRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(AttendanceStatusAdapter());
  }
  
  // Register Hive adapters for vocabulary system
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(VocabularyWordAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(DifficultyLevelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(LearningStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(ReviewResultAdapter());
  }
  
  // Register Hive adapters for speaking system
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(SpeakingLessonAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(SpeakingExerciseAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(SpeakingSessionAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(SpeakingAttemptAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(SpeakingEvaluationAdapter());
  }
  
  // Register Hive adapters for writing system
  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(WritingTaskAdapter());
  }
  if (!Hive.isAdapterRegistered(21)) {
    Hive.registerAdapter(WritingSubmissionAdapter());
  }
  if (!Hive.isAdapterRegistered(22)) {
    Hive.registerAdapter(WritingEvaluationAdapter());
  }
  if (!Hive.isAdapterRegistered(23)) {
    Hive.registerAdapter(WritingErrorAdapter());
  }
  if (!Hive.isAdapterRegistered(24)) {
    Hive.registerAdapter(WritingSuggestionAdapter());
  }
  if (!Hive.isAdapterRegistered(25)) {
    Hive.registerAdapter(WritingSessionAdapter());
  }
  if (!Hive.isAdapterRegistered(26)) {
    Hive.registerAdapter(WritingActionAdapter());
  }
  if (!Hive.isAdapterRegistered(27)) {
    Hive.registerAdapter(WritingTaskTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(28)) {
    Hive.registerAdapter(WritingInputMethodAdapter());
  }
  if (!Hive.isAdapterRegistered(29)) {
    Hive.registerAdapter(WritingSessionStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(30)) {
    Hive.registerAdapter(WritingActionTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(31)) {
    Hive.registerAdapter(WritingErrorTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(32)) {
    Hive.registerAdapter(WritingSuggestionTypeAdapter());
  }
  // DifficultyLevelAdapter already registered at typeId 3 for vocabulary system
  // No need to register again for writing system
  if (!Hive.isAdapterRegistered(34)) {
    Hive.registerAdapter(WritingStatusAdapter());
  }
  
  // Register Hive adapters for reading system
  if (!Hive.isAdapterRegistered(40)) {
    Hive.registerAdapter(BookGenreAdapter());
  }
  if (!Hive.isAdapterRegistered(41)) {
    Hive.registerAdapter(ReadingStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(42)) {
    Hive.registerAdapter(QuizTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(43)) {
    Hive.registerAdapter(ARLevelAdapter());
  }
  if (!Hive.isAdapterRegistered(44)) {
    Hive.registerAdapter(QuizDifficultyAdapter());
  }
  if (!Hive.isAdapterRegistered(45)) {
    Hive.registerAdapter(BookAdapter());
  }
  if (!Hive.isAdapterRegistered(46)) {
    Hive.registerAdapter(ReadingSessionAdapter());
  }
  if (!Hive.isAdapterRegistered(47)) {
    Hive.registerAdapter(ReadingProgressAdapter());
  }
  if (!Hive.isAdapterRegistered(48)) {
    Hive.registerAdapter(QuizQuestionAdapter());
  }
  if (!Hive.isAdapterRegistered(49)) {
    Hive.registerAdapter(QuizSessionAdapter());
  }
  if (!Hive.isAdapterRegistered(50)) {
    Hive.registerAdapter(QuizAttemptAdapter());
  }
  if (!Hive.isAdapterRegistered(51)) {
    Hive.registerAdapter(ARRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(52)) {
    Hive.registerAdapter(ReadingStatsAdapter());
  }
  
  // Register Hive adapters for parent reports system
  if (!Hive.isAdapterRegistered(60)) {
    Hive.registerAdapter(ReportTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(61)) {
    Hive.registerAdapter(NotificationPriorityAdapter());
  }
  if (!Hive.isAdapterRegistered(62)) {
    Hive.registerAdapter(NotificationTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(63)) {
    Hive.registerAdapter(ReportStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(64)) {
    Hive.registerAdapter(ActivityMetricTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(65)) {
    Hive.registerAdapter(ParentReportAdapter());
  }
  if (!Hive.isAdapterRegistered(66)) {
    Hive.registerAdapter(ActivityMetricAdapter());
  }
  if (!Hive.isAdapterRegistered(67)) {
    Hive.registerAdapter(DataPointAdapter());
  }
  if (!Hive.isAdapterRegistered(68)) {
    Hive.registerAdapter(AchievementAdapter());
  }
  if (!Hive.isAdapterRegistered(69)) {
    Hive.registerAdapter(RecommendationItemAdapter());
  }
  if (!Hive.isAdapterRegistered(70)) {
    Hive.registerAdapter(PushNotificationAdapter());
  }
  if (!Hive.isAdapterRegistered(71)) {
    Hive.registerAdapter(NotificationSettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(72)) {
    Hive.registerAdapter(ParentProfileAdapter());
  }
  
  // Register Hive adapters for vehicle tracking system
  if (!Hive.isAdapterRegistered(80)) {
    Hive.registerAdapter(VehicleStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(81)) {
    Hive.registerAdapter(VehicleTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(82)) {
    Hive.registerAdapter(DriverStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(83)) {
    Hive.registerAdapter(RouteStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(84)) {
    Hive.registerAdapter(AlertTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(85)) {
    Hive.registerAdapter(GeofenceTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(86)) {
    Hive.registerAdapter(VehicleAdapter());
  }
  if (!Hive.isAdapterRegistered(87)) {
    Hive.registerAdapter(DriverAdapter());
  }
  if (!Hive.isAdapterRegistered(88)) {
    Hive.registerAdapter(GPSLocationAdapter());
  }
  if (!Hive.isAdapterRegistered(89)) {
    Hive.registerAdapter(RouteAdapter());
  }
  if (!Hive.isAdapterRegistered(90)) {
    Hive.registerAdapter(RoutePointAdapter());
  }
  if (!Hive.isAdapterRegistered(91)) {
    Hive.registerAdapter(VehicleTrackingAdapter());
  }
  if (!Hive.isAdapterRegistered(92)) {
    Hive.registerAdapter(GeofenceAdapter());
  }
  if (!Hive.isAdapterRegistered(93)) {
    Hive.registerAdapter(VehicleAlertAdapter());
  }
  
  // Register Hive adapters for admin system
  if (!Hive.isAdapterRegistered(94)) {
    Hive.registerAdapter(SystemMetricsAdapter());
  }
  if (!Hive.isAdapterRegistered(95)) {
    Hive.registerAdapter(UserRoleAdapter());
  }
  if (!Hive.isAdapterRegistered(96)) {
    Hive.registerAdapter(UserStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(97)) {
    Hive.registerAdapter(AdminUserAdapter());
  }
  if (!Hive.isAdapterRegistered(98)) {
    Hive.registerAdapter(SystemLogLevelAdapter());
  }
  if (!Hive.isAdapterRegistered(99)) {
    Hive.registerAdapter(SystemLogAdapter());
  }
  if (!Hive.isAdapterRegistered(100)) {
    Hive.registerAdapter(ConfigurationTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(101)) {
    Hive.registerAdapter(SystemConfigurationAdapter());
  }
  if (!Hive.isAdapterRegistered(102)) {
    Hive.registerAdapter(DashboardWidgetAdapter());
  }
  
  // Initialize Services
  final attendanceService = AttendanceService();
  await attendanceService.initialize();
  
  final vocabularyService = VocabularyService();
  await vocabularyService.initialize();
  
  final speakingService = SpeakingService();
  await speakingService.initialize();
  
  final readingService = ReadingService();
  await readingService.initialize();
  
  final quizService = QuizService();
  await quizService.initialize();
  
  final reportService = ReportService();
  await reportService.initialize();
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  final vehicleService = VehicleService();
  await vehicleService.initialize();
  
  final adminService = AdminService();
  await adminService.initialize();
  
  // Add sample data for demo (remove in production)
  try {
    await attendanceService.addSampleData();
    await vocabularyService.addSampleData('student1');
    await vehicleService.addSampleData();
    await adminService.addSampleData();
    debugPrint('Sample data added successfully');
  } catch (e) {
    debugPrint('Sample data already exists or error: $e');
  }
  
  // Initialize Firebase (for production, add firebase_options.dart)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase for demo purposes
  }
  
  runApp(
    const ProviderScope(
      child: PrimeReadersApp(),
    ),
  );
}

class PrimeReadersApp extends ConsumerWidget {
  const PrimeReadersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 12 Pro size as base
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Prime Readers',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ColorScheme.fromSeed(seedColor: Colors.indigo).primary,
                  width: 2,
                ),
              ),
            ),
          ),
          routerConfig: router,
        );
      },
    );
  }
}