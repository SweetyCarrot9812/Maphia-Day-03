import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/question.dart';
import '../models/concept.dart';

class ObsidianWebService {
  static const String _baseUrl = 'https://127.0.0.1:27124';
  static const String _apiKey = 'c9d0396f92f581b9f370ab404c2d41079dceb1b8532926cef389e2ca5f3d08a8';

  // Obsidian 볼트 경로 설정
  static const String _vaultPath = 'Clintest';

  /// SSL 인증서 검증 무시하는 HTTP 클라이언트 생성 (localhost 전용)
  static http.Client _createHttpClient() {
    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // localhost에서만 자가서명 인증서 허용
      return host == '127.0.0.1' || host == 'localhost';
    };
    return IOClient(httpClient);
  }

  /// Obsidian Local REST API 연결 테스트
  static Future<bool> testConnection() async {
    final client = _createHttpClient();
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      print('Obsidian API 연결 실패: $e');
      return false;
    } finally {
      client.close();
    }
  }

  /// 생성한 문제를 Obsidian에 저장
  static Future<bool> saveQuestionToObsidian(Question question) async {
    final client = _createHttpClient();
    try {
      // 과목별 폴더 경로 생성
      final folderPath = _getFolderPath(question.subject);
      final fileName = _generateFileName(question);
      final filePath = '$folderPath/$fileName';

      // 마크다운 내용 생성
      final markdownContent = _generateMarkdownContent(question);

      // 먼저 폴더 생성 (존재하지 않는 경우)
      await _createFolderIfNotExists(folderPath);

      // 파일 생성
      final response = await client.put(
        Uri.parse('$_baseUrl/vault/$filePath'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'text/markdown',
        },
        body: markdownContent,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Obsidian에 저장 완료: $filePath');
        return true;
      } else {
        print('❌ Obsidian 저장 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Obsidian 저장 중 오류: $e');
      return false;
    } finally {
      client.close();
    }
  }

  /// 폴더 생성 (존재하지 않는 경우)
  static Future<void> _createFolderIfNotExists(String folderPath) async {
    final client = _createHttpClient();
    try {
      await client.post(
        Uri.parse('$_baseUrl/vault/$folderPath'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      // 폴더가 이미 존재하거나 생성 실패해도 무시
      print('폴더 생성 시도: $folderPath');
    } finally {
      client.close();
    }
  }

  /// 과목별 폴더 경로 반환
  static String _getFolderPath(String subject) {
    // 과목명을 폴더명으로 변환
    final folderName = subject.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    return '$_vaultPath/$folderName';
  }

  /// 파일명 생성
  static String _generateFileName(Question question) {
    final now = DateTime.now();
    final timestamp = now.toIso8601String().split('T')[0]; // YYYY-MM-DD
    final questionPreview = question.questionText
        .replaceAll(RegExp(r'[<>:"/\\|?*\n\r]'), '_')
        .substring(0, question.questionText.length > 30 ? 30 : question.questionText.length);

    return '${timestamp}_${questionPreview}.md';
  }

  /// 마크다운 내용 생성
  static String _generateMarkdownContent(Question question) {
    final now = DateTime.now();
    final buffer = StringBuffer();

    // 메타데이터
    buffer.writeln('---');
    buffer.writeln('created: ${now.toIso8601String()}');
    buffer.writeln('subject: ${question.subject}');
    buffer.writeln('difficulty: ${question.difficulty}');
    buffer.writeln('tags:');
    buffer.writeln('  - clintest');
    buffer.writeln('  - ${question.subject.toLowerCase().replaceAll(' ', '_')}');
    buffer.writeln('  - question');
    buffer.writeln('---');
    buffer.writeln();

    // 문제 제목
    buffer.writeln('# ${question.questionText}');
    buffer.writeln();

    // 선택지
    buffer.writeln('## 선택지');
    buffer.writeln();
    for (int i = 0; i < question.choices.length; i++) {
      final isCorrect = i == question.correctAnswer;
      final marker = isCorrect ? '**' : '';
      buffer.writeln('${i + 1}. $marker${question.choices[i]}$marker');
    }
    buffer.writeln();

    // 정답
    buffer.writeln('## 정답');
    buffer.writeln();
    buffer.writeln('**${question.correctAnswer + 1}번**: ${question.choices[question.correctAnswer]}');
    buffer.writeln();

    // 해설 (있는 경우)
    if (question.explanation.isNotEmpty) {
      buffer.writeln('## 해설');
      buffer.writeln();
      buffer.writeln(question.explanation);
      buffer.writeln();
    }

    // 메타 정보
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('### 문제 정보');
    buffer.writeln('- **과목**: ${question.subject}');
    buffer.writeln('- **난이도**: ${question.difficulty}');
    buffer.writeln('- **생성자**: ${question.createdBy}');
    buffer.writeln('- **생성일**: ${question.createdAt.toLocal().toString().split('.')[0]}');

    return buffer.toString();
  }

  /// Obsidian에서 특정 과목의 모든 문제 조회
  static Future<List<String>> getQuestionsBySubject(String subject) async {
    try {
      final folderPath = _getFolderPath(subject);
      final response = await http.get(
        Uri.parse('$_baseUrl/vault/$folderPath'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> files = json.decode(response.body);
        return files.map((file) => file['name'].toString()).toList();
      }
      return [];
    } catch (e) {
      print('❌ Obsidian 파일 목록 조회 실패: $e');
      return [];
    }
  }

  /// 생성한 개념을 Obsidian에 저장
  static Future<bool> saveConceptToObsidian(Concept concept) async {
    try {
      // medical/pending 폴더에 모든 개념 저장 (GPT 작업 대기)
      final folderPath = 'medical/pending';
      final fileName = _generateConceptFileName(concept);
      final filePath = '$folderPath/$fileName';

      // 마크다운 내용 생성
      final markdownContent = _generateConceptMarkdownContent(concept);

      // 먼저 폴더 생성 (존재하지 않는 경우)
      await _createFolderIfNotExists(folderPath);

      // 파일 생성
      final response = await http.put(
        Uri.parse('$_baseUrl/vault/$filePath'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'text/markdown',
        },
        body: markdownContent,
      );

      if (response.statusCode == 200) {
        print('✅ Obsidian에 개념 저장 성공: $fileName');
        return true;
      } else {
        print('❌ Obsidian 개념 저장 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Obsidian 개념 저장 중 오류: $e');
      return false;
    }
  }

  /// 개념 파일명 생성
  static String _generateConceptFileName(Concept concept) {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

    // 제목에서 특수문자 제거하고 길이 제한
    final cleanTitle = concept.title
        .replaceAll(RegExp(r'[^\w\s가-힣]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, concept.title.length > 30 ? 30 : concept.title.length);

    return '개념_${cleanTitle}_${dateStr}_$timeStr.md';
  }

  /// 개념 마크다운 내용 생성
  static String _generateConceptMarkdownContent(Concept concept) {
    final buffer = StringBuffer();

    // 제목과 메타데이터
    buffer.writeln('# ${concept.title}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('**과목:** ${concept.subject}');
    buffer.writeln('**작성자:** ${concept.createdBy}');
    buffer.writeln('**작성일:** ${_formatDateTime(concept.createdAt)}');
    if (concept.updatedAt != null) {
      buffer.writeln('**수정일:** ${_formatDateTime(concept.updatedAt!)}');
    }
    if (concept.tags.isNotEmpty) {
      buffer.writeln('**태그:** ${concept.tags.map((tag) => '#$tag').join(' ')}');
    }
    buffer.writeln('---');
    buffer.writeln();

    // 간단 설명
    buffer.writeln('## 개요');
    buffer.writeln();
    buffer.writeln(concept.description);
    buffer.writeln();

    // 메인 이미지가 있는 경우
    if (concept.mainImageUrl != null) {
      buffer.writeln('## 대표 이미지');
      buffer.writeln();
      buffer.writeln('![대표 이미지](${concept.mainImageUrl})');
      buffer.writeln();
    }

    // 상세 내용
    buffer.writeln('## 상세 설명');
    buffer.writeln();
    buffer.writeln(concept.content);
    buffer.writeln();

    // 추가 이미지들
    if (concept.imageUrls.isNotEmpty) {
      buffer.writeln('## 참고 이미지');
      buffer.writeln();
      for (int i = 0; i < concept.imageUrls.length; i++) {
        buffer.writeln('### 이미지 ${i + 1}');
        buffer.writeln('![참고 이미지 ${i + 1}](${concept.imageUrls[i]})');
        buffer.writeln();
      }
    }

    // 관련 문제들 (있는 경우)
    if (concept.relatedQuestionIds.isNotEmpty) {
      buffer.writeln('## 관련 문제');
      buffer.writeln();
      for (final questionId in concept.relatedQuestionIds) {
        buffer.writeln('- [[문제_$questionId]]');
      }
      buffer.writeln();
    }

    // 하단 메타 정보
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('**생성 정보**');
    buffer.writeln('- ID: `${concept.id}`');
    buffer.writeln('- 생성일시: ${concept.createdAt.toIso8601String()}');
    if (concept.updatedAt != null) {
      buffer.writeln('- 수정일시: ${concept.updatedAt!.toIso8601String()}');
    }
    buffer.writeln();
    buffer.writeln('> 📚 이 개념은 Clintest 웹 애플리케이션에서 자동 생성되었습니다.');

    return buffer.toString();
  }

  /// 이미지 파일을 Obsidian에 직접 저장
  static Future<String?> saveImageToObsidian(dynamic imageData, String fileName) async {
    final client = _createHttpClient();
    try {
      final imageFolderPath = 'medical/pending/images';
      final filePath = '$imageFolderPath/$fileName';

      // 폴더 생성
      await _createFolderIfNotExists(imageFolderPath);

      // 이미지 데이터 처리
      List<int> bytes;
      if (imageData is Uint8List) {
        bytes = imageData;
      } else if (imageData is List<int>) {
        bytes = imageData;
      } else {
        print('❌ 지원되지 않는 이미지 데이터 형식');
        return null;
      }

      print('📤 Obsidian에 이미지 저장 시도: $fileName (${bytes.length} bytes)');

      // 이미지 파일 저장
      final response = await client.put(
        Uri.parse('$_baseUrl/vault/$filePath'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/octet-stream',
        },
        body: bytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Obsidian에 이미지 저장 성공: $fileName');
        return filePath;
      } else {
        print('❌ Obsidian 이미지 저장 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Obsidian 이미지 저장 중 오류: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// 고유한 이미지 파일명 생성
  static String generateImageFileName(String extension) {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();
    return 'img_${timestamp}_$uuid.$extension';
  }

  /// Obsidian 볼트 열기
  static Future<void> openObsidianVault() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/open/$_vaultPath'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      print('❌ Obsidian 볼트 열기 실패: $e');
    }
  }

  /// DateTime을 보기 좋은 문자열로 포맷
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}