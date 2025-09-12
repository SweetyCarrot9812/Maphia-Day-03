# 🎵 HaneulTone (하늘톤)

AI 보컬 트레이너 Flutter 앱

## 📱 프로젝트 개요

HaneulTone은 사용자가 직접 녹음한 피아노 스케일을 기준으로 보컬 트레이닝을 제공하는 AI 기반 앱입니다.

### 핵심 기능
- 📹 **레퍼런스 오디오 업로드**: 피아노로 녹음한 스케일 파일 업로드
- 🎼 **실시간 피치 분석**: 마이크를 통한 실시간 음정 측정
- 📊 **정확도 분석**: 정확도, 안정도, 약점 구간 분석
- 🤖 **AI 피드백**: OpenAI GPT-5 기반 개인 맞춤 연습법 제안

## 🚀 현재 구현 상태

### ✅ 완료된 기능
1. **기본 프로젝트 구조** 
   - Flutter 프로젝트 생성 및 패키지 설정
   - SQLite 데이터베이스 구조 설계
   - 로컬 파일 시스템 구조 생성

2. **레퍼런스 오디오 업로드** 
   - 파일 선택 (WAV, MP3, M4A, AAC, FLAC)
   - 음계 메타데이터 입력 (키, 스케일 타입, 옥타브, A4 주파수)
   - 로컬 저장소 및 데이터베이스 저장
   - 웹/데스크톱 플랫폼 분기

3. **기본 UI/UX**
   - 하늘색 테마의 Material Design 3 적용
   - 홈 화면 및 업로드 화면 구현
   - 반응형 디자인 (웹/모바일 대응)

### 🚧 개발 예정 기능
1. **오디오 분석 엔진** - 피치 추출 및 곡선 생성
2. **실시간 마이크 입력** - 권한 관리 및 실시간 분석
3. **AI 연동** - OpenAI GPT-5 API 피드백 시스템
4. **고급 UI** - 튜너, 히트맵, 통계 화면

## 🗂️ 프로젝트 구조

```
haneul_tone/
├── lib/
│   ├── models/                 # 데이터 모델
│   │   ├── audio_reference.dart
│   │   └── session.dart
│   ├── services/              # 비즈니스 로직
│   │   ├── database_service.dart
│   │   └── audio_file_service.dart
│   ├── screens/               # UI 화면
│   │   ├── home_screen.dart
│   │   ├── home_screen_web.dart
│   │   └── upload_reference_screen.dart
│   └── main.dart
├── data/                      # 로컬 데이터 저장소
│   ├── audio_references/      # 레퍼런스 오디오 파일
│   ├── pitch_data/           # 분석된 피치 데이터
│   ├── user_recordings/      # 사용자 녹음
│   └── sessions/            # 연습 세션 기록
└── assets/                   # 이미지, 아이콘 등
```

## 🔧 기술 스택

- **Frontend**: Flutter (Dart)
- **Database**: SQLite (sqflite)
- **Audio**: record, audioplayers, flutter_sound
- **File**: file_picker, path_provider
- **UI**: Material Design 3, Google Fonts
- **State**: Provider
- **Platform**: Android, iOS, Web, Windows, macOS, Linux

## 📦 주요 패키지

```yaml
dependencies:
  # Audio 관련
  record: ^5.1.2
  audioplayers: ^6.1.0
  flutter_sound: ^9.12.5
  audio_session: ^0.1.21
  
  # File 처리
  file_picker: ^8.1.2
  path_provider: ^2.1.4
  permission_handler: ^11.3.1
  
  # Database
  sqflite: ^2.4.0
  
  # UI/UX
  provider: ^6.1.2
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10+1
  
  # Utils
  http: ^1.2.2
  uuid: ^4.5.1
  intl: ^0.19.0
```

## 🏃‍♂️ 실행 방법

### 개발 환경 설정
```bash
# Flutter 설치 확인
flutter doctor

# 의존성 설치
flutter pub get
```

### 플랫폼별 실행
```bash
# 웹 (Chrome)
flutter run -d chrome

# Windows 데스크톱
flutter run -d windows

# Android/iOS (에뮬레이터)
flutter run
```

## 📋 데이터베이스 스키마

### AudioReference 테이블
```sql
CREATE TABLE audio_references (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  file_path TEXT NOT NULL,
  key TEXT NOT NULL,
  scale_type TEXT NOT NULL,
  octaves INTEGER NOT NULL,
  a4_freq REAL NOT NULL DEFAULT 440.0,
  created_at INTEGER NOT NULL
);
```

### Sessions 테이블
```sql
CREATE TABLE sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  reference_id INTEGER NOT NULL,
  accuracy_mean REAL NOT NULL,
  stability_sd REAL NOT NULL,
  weak_steps TEXT NOT NULL,
  ai_feedback TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (reference_id) REFERENCES audio_references (id)
);
```

## 🎯 로드맵

### Phase 1: 기초 구현 (현재)
- [x] 프로젝트 구조 설정
- [x] 레퍼런스 오디오 업로드
- [ ] 오디오 분석 엔진

### Phase 2: 핵심 기능
- [ ] 실시간 마이크 입력
- [ ] 피치 분석 및 시각화
- [ ] 기본 튜너 UI

### Phase 3: AI 연동
- [ ] OpenAI GPT-5 API 연결
- [ ] 피드백 생성 시스템
- [ ] 드릴 제안 기능

### Phase 4: 고도화
- [ ] 상세 분석 화면
- [ ] 연습 이력 관리
- [ ] 내보내기 기능

## 🚨 알려진 이슈

- **웹 제한사항**: 웹 브라우저에서는 파일 시스템 접근과 SQLite가 제한적
- **플랫폼 차이**: 데스크톱/모바일에서 완전한 기능 지원

## 📝 개발 노트

프로젝트는 로컬 저장 방식을 채택하여 MongoDB 없이도 독립적으로 작동하도록 설계되었습니다. 사용자 데이터는 모두 디바이스에 저장되어 프라이버시가 보장됩니다.