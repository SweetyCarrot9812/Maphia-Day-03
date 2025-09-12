import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AudioFileService {
  static const String audioReferencesFolder = 'audio_references';
  static const String pitchDataFolder = 'pitch_data';
  static const String userRecordingsFolder = 'user_recordings';
  static const String sessionsFolder = 'sessions';

  // 앱 데이터 디렉토리 가져오기
  static Future<Directory> getAppDataDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // 오디오 레퍼런스 디렉토리 가져오기/생성
  static Future<Directory> getAudioReferencesDirectory() async {
    final appDir = await getAppDataDirectory();
    final audioDir = Directory(path.join(appDir.path, audioReferencesFolder));
    
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    
    return audioDir;
  }

  // 피치 데이터 디렉토리 가져오기/생성
  static Future<Directory> getPitchDataDirectory() async {
    final appDir = await getAppDataDirectory();
    final pitchDir = Directory(path.join(appDir.path, pitchDataFolder));
    
    if (!await pitchDir.exists()) {
      await pitchDir.create(recursive: true);
    }
    
    return pitchDir;
  }

  // 사용자 녹음 디렉토리 가져오기/생성
  static Future<Directory> getUserRecordingsDirectory() async {
    final appDir = await getAppDataDirectory();
    final recordingsDir = Directory(path.join(appDir.path, userRecordingsFolder));
    
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    
    return recordingsDir;
  }

  // 세션 디렉토리 가져오기/생성
  static Future<Directory> getSessionsDirectory() async {
    final appDir = await getAppDataDirectory();
    final sessionsDir = Directory(path.join(appDir.path, sessionsFolder));
    
    if (!await sessionsDir.exists()) {
      await sessionsDir.create(recursive: true);
    }
    
    return sessionsDir;
  }

  // 파일 복사 (원본 파일을 앱 내부 저장소로)
  static Future<String> copyAudioFile(
    String originalPath,
    String fileName, {
    String? customFolder,
  }) async {
    final originalFile = File(originalPath);
    
    Directory targetDir;
    if (customFolder != null) {
      final appDir = await getAppDataDirectory();
      targetDir = Directory(path.join(appDir.path, customFolder));
    } else {
      targetDir = await getAudioReferencesDirectory();
    }
    
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final newFilePath = path.join(targetDir.path, fileName);
    await originalFile.copy(newFilePath);
    
    return newFilePath;
  }

  // 파일 삭제
  static Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('파일 삭제 오류: $e');
      return false;
    }
  }

  // 파일 존재 여부 확인
  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  // 파일 크기 가져오기 (바이트)
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('파일 크기 확인 오류: $e');
      return 0;
    }
  }

  // 파일 크기를 읽기 쉬운 형태로 변환
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // 지원되는 오디오 형식인지 확인
  static bool isSupportedAudioFormat(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    const supportedFormats = ['.wav', '.mp3', '.m4a', '.aac', '.flac'];
    return supportedFormats.contains(extension);
  }

  // 고유한 파일명 생성
  static String generateUniqueFileName(
    String key,
    String scaleType,
    int octaves,
    String originalExtension,
  ) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${key}_${scaleType}_${octaves}oct_$timestamp$originalExtension';
  }

  // 모든 오디오 파일 목록 가져오기
  static Future<List<FileSystemEntity>> getAllAudioFiles() async {
    final audioDir = await getAudioReferencesDirectory();
    return audioDir.listSync().where((file) {
      if (file is File) {
        return isSupportedAudioFormat(file.path);
      }
      return false;
    }).toList();
  }

  // 저장소 사용량 계산
  static Future<Map<String, dynamic>> getStorageUsage() async {
    final appDir = await getAppDataDirectory();
    
    int audioReferencesSize = 0;
    int pitchDataSize = 0;
    int userRecordingsSize = 0;
    int sessionsSize = 0;
    
    // 각 폴더별 크기 계산
    final audioReferencesDir = Directory(path.join(appDir.path, audioReferencesFolder));
    if (await audioReferencesDir.exists()) {
      audioReferencesSize = await _calculateDirectorySize(audioReferencesDir);
    }
    
    final pitchDataDir = Directory(path.join(appDir.path, pitchDataFolder));
    if (await pitchDataDir.exists()) {
      pitchDataSize = await _calculateDirectorySize(pitchDataDir);
    }
    
    final userRecordingsDir = Directory(path.join(appDir.path, userRecordingsFolder));
    if (await userRecordingsDir.exists()) {
      userRecordingsSize = await _calculateDirectorySize(userRecordingsDir);
    }
    
    final sessionsDir = Directory(path.join(appDir.path, sessionsFolder));
    if (await sessionsDir.exists()) {
      sessionsSize = await _calculateDirectorySize(sessionsDir);
    }
    
    final totalSize = audioReferencesSize + pitchDataSize + userRecordingsSize + sessionsSize;
    
    return {
      'audioReferences': audioReferencesSize,
      'pitchData': pitchDataSize,
      'userRecordings': userRecordingsSize,
      'sessions': sessionsSize,
      'total': totalSize,
    };
  }

  // 디렉토리 크기 계산 (내부 메서드)
  static Future<int> _calculateDirectorySize(Directory directory) async {
    int size = 0;
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      print('디렉토리 크기 계산 오류: $e');
    }
    return size;
  }
}