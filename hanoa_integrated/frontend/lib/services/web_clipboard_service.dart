import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:js' as js;

class WebClipboardService {
  static final WebClipboardService _instance = WebClipboardService._internal();
  factory WebClipboardService() => _instance;
  WebClipboardService._internal();

  /// 웹 클립보드에서 이미지 가져오기
  Future<Uint8List?> getImageFromClipboard() async {
    if (!kIsWeb) return null;

    try {
      // JavaScript를 사용하여 클립보드에서 이미지 가져오기
      final result = await _getClipboardImageViaJS();
      if (result != null && result.isNotEmpty) {
        print('클립보드에서 이미지를 성공적으로 가져왔습니다. 크기: ${result.length} bytes');
        return result;
      } else {
        print('클립보드에 이미지가 없습니다.');
        return null;
      }
    } catch (e) {
      print('웹 클립보드 이미지 가져오기 실패: $e');
      return null;
    }
  }

  /// JavaScript를 사용하여 클립보드 이미지 가져오기
  Future<Uint8List?> _getClipboardImageViaJS() async {
    try {
      // HTML의 기존 getClipboardImage 함수 호출
      final jsResult = await _executeClipboardJS();
      if (jsResult != null) {
        return jsResult;
      }

      // Fallback 방법 시도
      return await _tryFallbackClipboardMethod();
    } catch (e) {
      print('JavaScript 클립보드 호출 실패: $e');
      return await _tryFallbackClipboardMethod();
    }
  }

  /// Fallback 방법: HTML5 Clipboard API 직접 호출
  Future<Uint8List?> _tryFallbackClipboardMethod() async {
    try {
      // 웹 전용 클립보드 API 시도
      if (kIsWeb) {
        // 브라우저의 Clipboard API 권한 확인 후 실행
        print('Fallback: 브라우저 클립보드 API 시도 중...');

        // 간단한 JavaScript interop으로 클립보드 확인
        final jsResult = await _executeClipboardJS();
        if (jsResult != null) {
          return jsResult;
        }
      }
      return null;
    } catch (e) {
      print('Fallback 클립보드 방법 실패: $e');
      return null;
    }
  }

  /// 브라우저 JavaScript 실행하여 클립보드 이미지 가져오기
  Future<Uint8List?> _executeClipboardJS() async {
    try {
      final completer = Completer<Uint8List?>();
      bool isCompleted = false;

      // 안전한 콜백 함수 등록
      js.context['dartClipboardCallback'] = js.allowInterop((dynamic result) {
        if (isCompleted) return;

        try {
          if (result != null) {
            // JavaScript 객체를 안전하게 변환
            final dataProperty = js.context['JSON'].callMethod('stringify', [result]);
            final Map<String, dynamic> resultMap = jsonDecode(dataProperty);

            if (resultMap.containsKey('data')) {
              final List<dynamic> dataList = resultMap['data'];
              final List<int> intList = dataList.cast<int>();
              final bytes = Uint8List.fromList(intList);

              print('클립보드 이미지 처리 성공: ${bytes.length} bytes');
              isCompleted = true;
              completer.complete(bytes);
              return;
            }
          }

          print('클립보드에 이미지 없음');
          isCompleted = true;
          completer.complete(null);
        } catch (e) {
          print('결과 처리 오류: $e');
          if (!isCompleted) {
            isCompleted = true;
            completer.complete(null);
          }
        }
      });

      // JavaScript 함수 실행
      js.context.callMethod('eval', ['''
        try {
          if (typeof window.getClipboardImage === 'function') {
            console.log('getClipboardImage 함수 호출 시작');
            window.getClipboardImage()
              .then(function(result) {
                console.log('클립보드 결과:', result);
                if (window.dartClipboardCallback) {
                  window.dartClipboardCallback(result);
                } else {
                  console.error('dartClipboardCallback이 없습니다');
                }
              })
              .catch(function(error) {
                console.error('클립보드 호출 오류:', error);
                if (window.dartClipboardCallback) {
                  window.dartClipboardCallback(null);
                }
              });
          } else {
            console.error('getClipboardImage 함수를 찾을 수 없습니다');
            if (window.dartClipboardCallback) {
              window.dartClipboardCallback(null);
            }
          }
        } catch (jsError) {
          console.error('JavaScript 실행 오류:', jsError);
          if (window.dartClipboardCallback) {
            window.dartClipboardCallback(null);
          }
        }
      ''']);

      // 타임아웃 설정
      Timer(const Duration(seconds: 15), () {
        if (!isCompleted) {
          print('클립보드 읽기 타임아웃');
          isCompleted = true;
          completer.complete(null);
        }
      });

      return await completer.future;
    } catch (e) {
      print('JavaScript 실행 실패: $e');
      return null;
    } finally {
      // 콜백 정리
      try {
        js.context.deleteProperty('dartClipboardCallback');
      } catch (e) {
        print('콜백 정리 실패: $e');
      }
    }
  }

  /// JavaScript Promise를 Dart Future로 변환
  Future<Map<String, dynamic>?> _promiseToFuture(dynamic promise) {
    final completer = Completer<Map<String, dynamic>?>();

    promise.callMethod('then', [
      (result) {
        if (result == null) {
          completer.complete(null);
        } else {
          final map = <String, dynamic>{};
          map['data'] = result['data'];
          map['type'] = result['type'];
          completer.complete(map);
        }
      }
    ]);

    promise.callMethod('catch', [
      (error) {
        completer.completeError(error);
      }
    ]);

    return completer.future;
  }

  /// 클립보드에 이미지가 있는지 확인
  Future<bool> hasImageInClipboard() async {
    if (!kIsWeb) return false;

    try {
      final result = await getImageFromClipboard();
      return result != null && result.isNotEmpty;
    } catch (e) {
      print('클립보드 이미지 확인 실패: $e');
      return false;
    }
  }

  /// 이미지 데이터의 MIME 타입 확인
  String _getMimeTypeFromBytes(Uint8List bytes) {
    if (bytes.length < 8) return 'application/octet-stream';

    // PNG 시그니처 확인
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }

    // JPEG 시그니처 확인
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'image/jpeg';
    }

    // WebP 시그니처 확인
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }

    // GIF 시그니처 확인
    if (bytes.length >= 6) {
      final header = String.fromCharCodes(bytes.take(6));
      if (header == 'GIF87a' || header == 'GIF89a') {
        return 'image/gif';
      }
    }

    return 'image/png'; // 기본값
  }
}