# Assets 폴더

이 폴더는 Clintest 앱의 이미지, 아이콘 및 기타 정적 자산을 포함합니다.

## 구조

- `images/` - 앱 내에서 사용되는 이미지 파일
- `icons/` - 사용자 정의 아이콘 파일
- `fonts/` - 사용자 정의 폰트 파일 (필요시)

## 사용법

pubspec.yaml에 다음과 같이 추가하여 assets를 등록하세요:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

코드에서 사용:
```dart
Image.asset('assets/images/logo.png')
```