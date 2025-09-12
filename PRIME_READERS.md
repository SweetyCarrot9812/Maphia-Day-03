---
title: "PRIME_READERS.md"
date: "2025-09-11"
version: "1.0"
description: "Prime Readers 학원 앱 프로젝트 상세 가이드"
---

# Prime Readers 학원 앱 프로젝트

## 프로젝트 개요
- **상태**: ✅ **MVP 완성** (2025-09-09)
- **경로**: `prime_readers/`
- **플랫폼**: Flutter Web
- **포트**: http://localhost:8082
- **목적**: 학원 전용 통합 학습 관리 시스템

## 주요 시스템 (6개)

### 1. Speaking System (스피킹)
- 음성 녹음 및 평가
- 발음 정확도 측정
- 실시간 피드백 제공
- 모델: `SpeakingTask`, `SpeakingSession`, `SpeakingEvaluation`

### 2. Writing System (라이팅)  
- AI 기반 작문 평가
- 문법/어휘/구조 분석
- 실시간 제안 시스템
- OCR 손글씨 인식 지원
- 모델: `WritingTask`, `WritingSubmission`, `WritingEvaluation`, `WritingError`

### 3. Reading System (리딩)
- 지문 이해도 평가
- 독해 속도 측정
- 단계별 문제 생성
- 모델: `ReadingPassage`, `ReadingQuestion`, `ReadingSession`

### 4. Parent Reports (학부모 리포트)
- 학습 진도 추적
- 성과 분석 대시보드
- 자동 리포트 생성
- 모델: `ParentReport`, `LearningProgress`, `PerformanceMetrics`

### 5. Vehicle Tracking (차량 추적)
- 실시간 GPS 추적
- 승하차 알림
- 안전 구역 설정
- 모델: `VehicleLocation`, `StudentPickup`, `SafeZone`

### 6. Admin Dashboard (관리자 대시보드)
- 시스템 통계 및 메트릭
- 사용자 관리
- 설정 및 구성
- 모델: `SystemMetrics`, `AdminUser`, `SystemLog`

## 기술 아키텍처

### Core Technologies
```yaml
플랫폼: Flutter Web (Chrome 최적화)
상태관리: Riverpod (Provider 패턴)
데이터베이스: Hive (로컬 우선)
UI 프레임워크: Material 3 Design
라우팅: go_router
```

### Feature-Based Directory Structure
```
lib/
├── features/
│   ├── speaking/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── writing/
│   ├── reading/
│   ├── parent_reports/
│   ├── vehicle_tracking/
│   └── admin/
├── shared/
├── core/
└── main.dart
```

### Riverpod Provider Pattern
```dart
// 전역 상태 관리
final speakingServiceProvider = Provider<SpeakingService>((ref) {
  return SpeakingService();
});

// 상태 기반 데이터
final speakingTasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<SpeakingTask>>>((ref) {
  return TasksNotifier(ref.read(speakingServiceProvider));
});
```

## Hive TypeAdapter 관리

### TypeId 범위 할당
- Speaking: 1-10
- Reading: 11-19  
- Writing: 20-35
- Parent Reports: 40-49
- Vehicle Tracking: 50-59
- Admin: 60-69
- Shared Models: 70-79
- Enums: 80-102

### 자동 생성 코드 관리
```bash
# .g.dart 파일 재생성
dart run build_runner build --delete-conflicting-outputs

# 지속적 감시 모드
dart run build_runner watch
```

## 실시간 개발 워크플로우

### 개발 서버 실행
```bash
cd prime_readers
flutter run -d chrome --web-port=8082
```

### Hot Reload 최적화
- 상태 보존: Riverpod Provider 상태 유지
- UI 변경: 즉시 반영 (<1초)  
- 로직 변경: 자동 재시작
- 데이터 변경: Hive 파일 백업

### 실시간 디버깅
```dart
// Provider 상태 추적
ref.listen<AsyncValue<List<Task>>>(tasksProvider, (previous, next) {
  print('Tasks updated: ${next.value?.length}');
});

// 성능 모니터링
class PerformanceTracker {
  static void trackBuildTime(String widgetName) {
    final stopwatch = Stopwatch()..start();
    // Widget build logic
    print('$widgetName build time: ${stopwatch.elapsedMilliseconds}ms');
  }
}
```

## 컴파일 에러 해결 패턴

### 1. Import 충돌 해결
```dart
// Before: 모호한 import
import 'package:prime_readers/features/reading/models/reading_models.dart';
import 'package:prime_readers/features/writing/models/writing_models.dart';

// After: alias 사용
import 'package:prime_readers/features/reading/models/reading_models.dart' as reading;
import 'package:prime_readers/features/writing/models/writing_models.dart' as writing;

// 사용법
reading.ReadingTask vs writing.WritingTask
```

### 2. TypeAdapter 중복 방지
```dart
// 전역 등록 확인
void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(DifficultyLevelAdapter());
  }
}
```

### 3. Stream 메모리 누수 방지
```dart
class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _subscription;
  
  @override
  void dispose() {
    _subscription?.cancel(); // 필수!
    super.dispose();
  }
}
```

## 품질 관리

### 코드 생성 파일 관리
```bash
# 자동 생성 파일 정리
find lib -name "*.g.dart" -delete
dart run build_runner build

# Git ignore 패턴
**/*.g.dart
**/*.freezed.dart
```

### 테스트 전략
```dart
// Provider 단위 테스트
testWidgets('Speaking task list displays correctly', (tester) async {
  final container = ProviderContainer();
  
  await tester.pumpWidget(
    ProviderScope(
      parent: container,
      child: MaterialApp(home: SpeakingTaskListScreen()),
    ),
  );
  
  expect(find.text('스피킹 과제'), findsOneWidget);
});
```

## 성능 최적화

### Bundle 크기 최적화
- Tree Shaking: 미사용 코드 자동 제거
- Code Splitting: 기능별 지연 로딩
- Asset Optimization: 이미지 최적화

### 메모리 관리
```dart
// 대용량 데이터 페이징
class PaginatedTasksProvider extends StateNotifier<AsyncValue<List<Task>>> {
  static const int pageSize = 20;
  
  Future<void> loadNextPage() async {
    // 페이징 로직
  }
}
```

## 배포 및 빌드

### Flutter Web 빌드
```bash
flutter build web --release
```

### 빌드 최적화
- **First Load**: ~3.2MB (gzipped)
- **Subsequent Loads**: ~150KB (캐시 활용)
- **Hot Reload**: <500ms

## 향후 확장 계획

### Phase 2 기능
- AI 음성 인식 고도화
- 실시간 화상 수업 지원
- 모바일 앱 버전 개발
- Firebase 실시간 동기화

### 기술적 개선
- Performance 모니터링 도구
- E2E 테스트 자동화
- CI/CD 파이프라인 구축
- 다국어 지원 (i18n)