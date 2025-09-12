---
title: "DEVELOPMENT.md"
date: "2025-09-08"
version: "1.0"
description: "Hanoa 프로젝트 개발 가이드 (통합본)"
---

# DEVELOPMENT.md

Hanoa 패키지형 슈퍼앱 개발 통합 가이드

## 📋 프로젝트 개요

**Hanoa**: 로컬 우선 아키텍처 기반의 패키지형 교육 슈퍼앱
- **목표**: 교육/건강 분야 통합 플랫폼  
- **현재 상태**: Beta Free (전 서비스 무료)
- **과금 철학**: 패키지별 구독, 티어 없음

### 패키지 구성
- **의학/간호학 패키지**: 간호사 국가고시 (hanoa_desktop_flutter)
- **언어 패키지**: Lingumo (개발 중)
- **피트니스 패키지**: AreumFit (완료)
- **성악 패키지**: HaneulTone (개발 중)

---

## 🏗️ 핵심 아키텍처

### 로컬 우선 설계 (Local-First)
```dart
// ✅ 올바른 방법: 로컬 저장 후 선택적 동기화
await Database.isar.writeTxn(() async {
  await Database.isar.users.put(user); // 로컬에 먼저 저장
});

// ❌ 잘못된 방법: 서버 우선
await apiService.createUser(user); // X
```

### 패키지 독립성
```
lib/packages/
├── medical_nursing/    # 의학/간호학 패키지
├── language/          # 언어 패키지  
├── vocal/             # 성악 패키지
└── fitness/           # 피트니스 패키지
```

### 데이터베이스 구조 (Isar)
```dart
// 핵심 모델
@collection
class User {
  Id id = Isar.autoIncrement;
  late String name;
  late String email;
  DateTime? createdAt;
}

@collection  
class Problem {
  Id id = Isar.autoIncrement;
  @Index() // 검색 필드에 인덱스
  late String subject;
  late String question;
  late String answer;
  DateTime? createdAt;
}
```

---

## 💻 개발 환경 설정

### 필수 도구
- **Flutter**: 3.9.0+
- **State Management**: Riverpod
- **Database**: Isar (로컬), Firebase (동기화)
- **Desktop**: Windows/macOS 지원

### 환경 변수
```env
# AI API Keys
GEMINI_API_KEY=your_gemini_key
OPENAI_API_KEY=your_openai_key

# Firebase 설정
FIREBASE_PROJECT_ID=hanoa-97393
```

### 실행 명령어
```bash
# Flutter 앱 실행
flutter run -d emulator-5554

# Desktop Hub 실행
cd hanoa_desktop_flutter && flutter run -d windows

# 코드 품질 확인
flutter analyze
dart format .
```

---

## 📝 코딩 규칙

### 네이밍 컨벤션
```dart
// ✅ 파일명: snake_case
medical_nursing_screen.dart

// ✅ 클래스명: PascalCase  
class MedicalNursingScreen extends StatelessWidget {}

// ✅ 변수명: camelCase
String userName = '사용자';

// ✅ 상수명: lowerCamelCase
static const String packageMedicalNursing = 'medical_nursing';
```

### Import 순서
```dart
// 1. Dart 코어
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';  

// 3. 외부 패키지
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. 내부 패키지
import '../models/nursing_exam.dart';
```

### 에러 처리
```dart
Future<List<Problem>> getProblems() async {
  try {
    return await Database.isar.problems.where().findAll();
  } catch (e) {
    print('❌ 문제 로드 오류: $e');
    return []; // 앱 크래시 방지
  }
}
```

---

## 🎨 UI/UX 가이드

### 디자인 시스템
```dart
// 색상 정의
class AppColors {
  static const Color primary = Color(0xFF1565C0); // HANOA 네이비
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
}

// 텍스트 스타일
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16, // 최소 16pt
    height: 1.4,
  );
}
```

### 반응형 처리
```dart
class ResponsiveBuilder extends StatelessWidget {
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 768) {
      return DesktopLayout();
    } else {
      return MobileLayout();
    }
  }
}
```

---

## 📦 패키지 개발

### 표준 패키지 구조
```
lib/packages/{package_name}/
├── models/              # 데이터 모델
├── services/            # 비즈니스 로직
├── providers/           # Riverpod 상태 관리
├── presentation/        # UI 레이어
│   ├── screens/
│   └── widgets/
├── data/               # 로컬 데이터 파일
└── utils/              # 유틸리티
```

### 패키지 독립성 원칙
```dart
// ✅ 패키지 내부 import만
import '../models/nursing_exam.dart';

// ❌ 다른 패키지 직접 의존 금지  
import '../../language/models/vocabulary.dart'; // X

// ✅ 공통 코드는 core에
import '../../core/database/database.dart';
```

### CRUD 서비스 패턴
```dart
class NursingExamService {
  static Future<void> create(NursingExam exam) async {
    exam.createdAt = DateTime.now();
    await Database.isar.writeTxn(() async {
      await Database.isar.nursingExams.put(exam);
    });
  }
  
  static Future<List<NursingExam>> getBySubject(String subject) async {
    return await Database.isar.nursingExams
        .filter()
        .subjectEqualTo(subject)
        .findAll();
  }
}
```

---

## 🔧 성능 최적화

### Isar 최적화
```dart
// ✅ 필요한 필드만 선택, 페이징 적용
final problems = await Database.isar.problems
    .where()
    .subjectEqualTo(subject)
    .limit(20)
    .findAll();

// ✅ 인덱스 활용
@Index()
late String subject; // 자주 검색하는 필드
```

### 메모리 관리
```dart
// ✅ 큰 목록은 ListView.builder
ListView.builder(
  itemCount: problems.length,
  itemBuilder: (context, index) => ProblemCard(problems[index]),
);
```

---

## 🧪 테스트 전략

### 단위 테스트
```dart
void main() {
  group('NursingExamService', () {
    testWidgets('문제 생성 테스트', (tester) async {
      final exam = NursingExam()
        ..question = '간호사 윤리 원칙은?'
        ..answer = '자율성 존중';
      
      await NursingExamService.create(exam);
      
      final saved = await NursingExamService.getById(exam.id);
      expect(saved?.question, equals('간호사 윤리 원칙은?'));
    });
  });
}
```

### 성능 목표
- **앱 시작**: 3초 이내
- **화면 전환**: 300ms 이내  
- **데이터 로드**: 1초 이내 (로컬 DB)
- **오프라인 지원**: 100% 핵심 기능

---

## 📚 문서화

### 코드 문서화
```dart
/// 간호사 국가고시 문제 관리 서비스
/// 
/// 로컬 Isar DB를 사용하여 오프라인 완전 지원
/// 
/// Example:
/// ```dart
/// final problems = await NursingExamService.getBySubject('성인간호학');
/// ```
class NursingExamService {
  /// 과목별 문제 조회
  /// 
  /// [subject]: 간호학 과목명
  /// Returns: 해당 과목의 문제 목록
  static Future<List<NursingExam>> getBySubject(String subject) async {
    // 구현...
  }
}
```

### Git 커밋 메시지
```
feat: 간호사 국가고시 문제 풀이 기능 추가

- 8개 과목별 문제 분류
- 오프라인 완전 지원  
- 학습 진도 추적 기능

Closes #123
```

---

## 🔒 보안 가이드

### 데이터 보호
```dart
// ✅ 민감한 데이터는 flutter_secure_storage 사용
final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);

// ❌ SharedPreferences에 민감한 데이터 저장 금지
// prefs.setString('password', password); // X
```

### API 보안
```dart
// ✅ 토큰 기반 인증
final dio = Dio();
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  },
));
```

---

## 🚀 배포 가이드

### 빌드 전 체크리스트
- [ ] 모든 테스트 통과
- [ ] 코드 포맷팅 완료 (`dart format .`)
- [ ] 정적 분석 통과 (`dart analyze`)
- [ ] 성능 프로파일링 완료
- [ ] 버전 번호 업데이트

### 플랫폼별 배포
- **Android**: Google Play Store
- **Windows**: Microsoft Store (계획 중)
- **Desktop**: Direct Download

---

## 💡 핵심 기억사항

1. 🏠 **로컬 우선**: 모든 데이터는 로컬에 먼저
2. 📱 **오프라인 지원**: 인터넷 없어도 모든 기능 작동  
3. 📦 **패키지 독립성**: 각 패키지는 독립적으로 개발
4. 🇰🇷 **한국어 우선**: 사용자 경험 최우선
5. 🔒 **보안 중시**: 사용자 데이터 보호 필수

---

**최종 업데이트**: 2025-09-08  
**문서 버전**: v1.0