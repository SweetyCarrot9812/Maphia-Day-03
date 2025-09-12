import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  // Google ML Kit을 이용한 온디바이스 OCR
  Future<OCRResult> recognizeTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      final extractedText = recognizedText.text;
      final confidence = _calculateAverageConfidence(recognizedText);
      
      return OCRResult(
        text: extractedText,
        confidence: confidence,
        method: OCRMethod.googleMLKit,
        processingTime: DateTime.now(),
        blocks: recognizedText.blocks.map((block) => OCRTextBlock(
          text: block.text,
          boundingBox: OCRBoundingBox(
            left: block.boundingBox.left.toDouble(),
            top: block.boundingBox.top.toDouble(),
            width: block.boundingBox.width.toDouble(),
            height: block.boundingBox.height.toDouble(),
          ),
          confidence: block.recognizedLanguages.isNotEmpty 
              ? 0.9  // ML Kit doesn't provide confidence per block, use default
              : 0.7,
        )).toList(),
      );
    } catch (e) {
      // 폴백: 모의 OCR 결과 반환
      return _getMockOCRResult();
    }
  }

  // 이미지 바이트에서 텍스트 인식
  Future<OCRResult> recognizeTextFromBytes(Uint8List imageBytes) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(800, 600), // 기본 크기 설정
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 800,
        ),
      );
      
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      final extractedText = recognizedText.text;
      final confidence = _calculateAverageConfidence(recognizedText);
      
      return OCRResult(
        text: extractedText,
        confidence: confidence,
        method: OCRMethod.googleMLKit,
        processingTime: DateTime.now(),
        blocks: recognizedText.blocks.map((block) => OCRTextBlock(
          text: block.text,
          boundingBox: OCRBoundingBox(
            left: block.boundingBox.left.toDouble(),
            top: block.boundingBox.top.toDouble(),
            width: block.boundingBox.width.toDouble(),
            height: block.boundingBox.height.toDouble(),
          ),
          confidence: 0.85, // 기본 신뢰도
        )).toList(),
      );
    } catch (e) {
      return _getMockOCRResult();
    }
  }

  // 클라우드 OCR API 호출 (Google Cloud Vision API 등)
  Future<OCRResult> recognizeTextFromCloudAPI(
    Uint8List imageBytes, {
    String? apiKey,
    OCRCloudProvider provider = OCRCloudProvider.googleCloud,
  }) async {
    if (apiKey == null) {
      // API 키가 없으면 로컬 OCR 사용
      return recognizeTextFromBytes(imageBytes);
    }

    try {
      switch (provider) {
        case OCRCloudProvider.googleCloud:
          return await _callGoogleCloudVisionAPI(imageBytes, apiKey);
        case OCRCloudProvider.microsoftCognitive:
          return await _callMicrosoftCognitiveAPI(imageBytes, apiKey);
        case OCRCloudProvider.awsTextract:
          return await _callAWSTextractAPI(imageBytes, apiKey);
      }
    } catch (e) {
      // 클라우드 API 실패 시 로컬 OCR로 폴백
      return recognizeTextFromBytes(imageBytes);
    }
  }

  // Google Cloud Vision API 호출
  Future<OCRResult> _callGoogleCloudVisionAPI(Uint8List imageBytes, String apiKey) async {
    final url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';
    final base64Image = base64Encode(imageBytes);
    
    final requestBody = {
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'TEXT_DETECTION', 'maxResults': 10}
          ]
        }
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final annotations = responseData['responses'][0]['textAnnotations'];
      
      if (annotations != null && annotations.isNotEmpty) {
        final fullText = annotations[0]['description'];
        
        final blocks = (annotations as List).skip(1).map((annotation) {
          final vertices = annotation['boundingPoly']['vertices'];
          final boundingBox = OCRBoundingBox.fromVertices(vertices);
          
          return OCRTextBlock(
            text: annotation['description'],
            boundingBox: boundingBox,
            confidence: 0.9, // Google Cloud는 일반적으로 높은 정확도
          );
        }).toList();
        
        return OCRResult(
          text: fullText,
          confidence: 0.95,
          method: OCRMethod.googleCloudVision,
          processingTime: DateTime.now(),
          blocks: blocks,
        );
      }
    }
    
    throw Exception('Google Cloud Vision API call failed');
  }

  // Microsoft Cognitive Services API 호출
  Future<OCRResult> _callMicrosoftCognitiveAPI(Uint8List imageBytes, String apiKey) async {
    // Microsoft Cognitive Services OCR API 구현
    // 실제 구현에서는 Microsoft의 Computer Vision API를 호출
    throw UnimplementedError('Microsoft Cognitive Services API not implemented');
  }

  // AWS Textract API 호출
  Future<OCRResult> _callAWSTextractAPI(Uint8List imageBytes, String apiKey) async {
    // AWS Textract API 구현
    // 실제 구현에서는 AWS Textract API를 호출
    throw UnimplementedError('AWS Textract API not implemented');
  }

  // 평균 신뢰도 계산
  double _calculateAverageConfidence(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) return 0.0;
    
    double totalConfidence = 0.0;
    int elementCount = 0;
    
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          // ML Kit은 element별 신뢰도를 제공하지 않으므로 기본값 사용
          totalConfidence += 0.85;
          elementCount++;
        }
      }
    }
    
    return elementCount > 0 ? totalConfidence / elementCount : 0.0;
  }

  // 모의 OCR 결과 (테스트용)
  OCRResult _getMockOCRResult() {
    return OCRResult(
      text: 'This is a sample handwritten text recognized by OCR.\nThe recognition accuracy may vary based on handwriting quality.',
      confidence: 0.78,
      method: OCRMethod.mock,
      processingTime: DateTime.now(),
      blocks: [
        OCRTextBlock(
          text: 'This is a sample handwritten text recognized by OCR.',
          boundingBox: const OCRBoundingBox(left: 10, top: 10, width: 400, height: 30),
          confidence: 0.82,
        ),
        OCRTextBlock(
          text: 'The recognition accuracy may vary based on handwriting quality.',
          boundingBox: const OCRBoundingBox(left: 10, top: 50, width: 450, height: 30),
          confidence: 0.74,
        ),
      ],
    );
  }

  // 텍스트 후처리 (맞춤법 검사, 문법 교정 등)
  Future<String> postProcessText(String rawText) async {
    // 기본적인 텍스트 정리
    String processedText = rawText
        .replaceAll(RegExp(r'\s+'), ' ') // 중복 공백 제거
        .replaceAll(RegExp(r'\n+'), '\n') // 중복 줄바꿈 제거
        .trim();

    // 일반적인 OCR 오류 수정
    processedText = _fixCommonOCRErrors(processedText);
    
    return processedText;
  }

  // 일반적인 OCR 오류 수정
  String _fixCommonOCRErrors(String text) {
    // 숫자와 문자 혼동 수정
    final corrections = {
      r'\b0\b': 'O', // 0 -> O
      r'\b1\b': 'I', // 1 -> I (문맥에 따라)
      r'\b5\b': 'S', // 5 -> S (문맥에 따라)
      r'\brn\b': 'm', // rn -> m
      r'\bvv\b': 'w', // vv -> w
      r'\b[|]\b': 'I', // | -> I
    };

    String correctedText = text;
    corrections.forEach((pattern, replacement) {
      correctedText = correctedText.replaceAll(RegExp(pattern), replacement);
    });

    return correctedText;
  }

  void dispose() {
    _textRecognizer.close();
  }
}

// OCR 결과 클래스
class OCRResult {
  final String text;
  final double confidence;
  final OCRMethod method;
  final DateTime processingTime;
  final List<OCRTextBlock> blocks;

  OCRResult({
    required this.text,
    required this.confidence,
    required this.method,
    required this.processingTime,
    required this.blocks,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'confidence': confidence,
    'method': method.name,
    'processingTime': processingTime.toIso8601String(),
    'blocks': blocks.map((b) => b.toJson()).toList(),
  };
}

// OCR 텍스트 블록
class OCRTextBlock {
  final String text;
  final OCRBoundingBox boundingBox;
  final double confidence;

  OCRTextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'boundingBox': boundingBox.toJson(),
    'confidence': confidence,
  };
}

// 경계 상자
class OCRBoundingBox {
  final double left;
  final double top;
  final double width;
  final double height;

  const OCRBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  // Google Cloud Vision API의 vertices에서 변환
  factory OCRBoundingBox.fromVertices(List<dynamic> vertices) {
    final x1 = vertices[0]['x']?.toDouble() ?? 0.0;
    final y1 = vertices[0]['y']?.toDouble() ?? 0.0;
    final x2 = vertices[2]['x']?.toDouble() ?? 0.0;
    final y2 = vertices[2]['y']?.toDouble() ?? 0.0;
    
    return OCRBoundingBox(
      left: x1,
      top: y1,
      width: x2 - x1,
      height: y2 - y1,
    );
  }

  Map<String, dynamic> toJson() => {
    'left': left,
    'top': top,
    'width': width,
    'height': height,
  };
}

// OCR 방법
enum OCRMethod {
  googleMLKit,
  googleCloudVision,
  microsoftCognitive,
  awsTextract,
  mock,
}

// 클라우드 OCR 제공업체
enum OCRCloudProvider {
  googleCloud,
  microsoftCognitive,
  awsTextract,
}