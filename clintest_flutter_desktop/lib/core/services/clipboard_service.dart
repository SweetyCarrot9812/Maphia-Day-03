import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ClipboardService {
  static Future<Uint8List?> _readImageBytes(
      ClipboardReader reader, FileFormat format) async {
    final completer = Completer<Uint8List?>();
    final progress = reader.getFile(
      format,
      (file) async {
        try {
          final bytes = await file.readAll();
          if (!completer.isCompleted) completer.complete(bytes);
        } catch (_) {
          if (!completer.isCompleted) completer.complete(null);
        }
      },
    );

    if (progress == null) {
      return null;
    }

    return await completer.future;
  }
  /// 클립보드에서 이미지를 가져와서 임시 파일로 저장
  static Future<File?> getImageFromClipboard() async {
    try {
      final clipboard = SystemClipboard.instance;
      
      if (clipboard == null) {
        print('시스템 클립보드에 접근할 수 없습니다.');
        return null;
      }

      final reader = await clipboard.read();
      
      // PNG 형식 우선 확인
      if (reader.canProvide(Formats.png)) {
        final pngData = await _readImageBytes(reader, Formats.png);
        if (pngData != null) {
          return await _saveImageToTempFile(pngData, 'png');
        }
      }
      
      // JPEG 형식 확인
      if (reader.canProvide(Formats.jpeg)) {
        final jpegData = await _readImageBytes(reader, Formats.jpeg);
        if (jpegData != null) {
          return await _saveImageToTempFile(jpegData, 'jpg');
        }
      }
      
      // BMP 형식 확인
      if (reader.canProvide(Formats.bmp)) {
        final bmpData = await _readImageBytes(reader, Formats.bmp);
        if (bmpData != null) {
          return await _saveImageToTempFile(bmpData, 'bmp');
        }
      }

      print('클립보드에 지원되는 이미지 형식이 없습니다.');
      return null;
    } catch (e) {
      print('클립보드 이미지 가져오기 실패: $e');
      return null;
    }
  }

  /// 클립보드에 이미지가 있는지 확인
  static Future<bool> hasImageInClipboard() async {
    try {
      final clipboard = SystemClipboard.instance;
      
      if (clipboard == null) {
        return false;
      }

      final reader = await clipboard.read();
      
      // PNG, JPEG, BMP 형식 중 하나라도 있으면 true
      return reader.canProvide(Formats.png) || 
             reader.canProvide(Formats.jpeg) || 
             reader.canProvide(Formats.bmp);
    } catch (e) {
      print('클립보드 확인 실패: $e');
      return false;
    }
  }

  /// 이미지 바이트를 임시 파일로 저장
  static Future<File> _saveImageToTempFile(Uint8List bytes, String extension) async {
    final tempDir = Directory.systemTemp;
    final fileName = 'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  /// 클립보드 텍스트 가져오기 (추가 기능)
  static Future<String?> getTextFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text;
    } catch (e) {
      print('클립보드 텍스트 가져오기 실패: $e');
      return null;
    }
  }

  /// 이미지 파일 유효성 검사
  static bool isValidImageFile(File file) {
    final extension = file.path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// 이미지 파일 크기 검사 (5MB 제한)
  static Future<bool> isImageSizeValid(File file) async {
    try {
      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5MB
      return fileSize <= maxSize;
    } catch (e) {
      return false;
    }
  }
}
