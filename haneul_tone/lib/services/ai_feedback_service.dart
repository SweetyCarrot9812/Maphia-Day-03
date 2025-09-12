import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pitch_data.dart';
import '../models/audio_reference.dart';
import 'dart:math' as math;

class VocalAnalysis {
  final double accuracyMean;
  final double stabilityStd;
  final List<String> weakNotes;
  final Map<String, dynamic> detailedMetrics;
  final DateTime analyzedAt;
  
  VocalAnalysis({
    required this.accuracyMean,
    required this.stabilityStd,
    required this.weakNotes,
    required this.detailedMetrics,
    required this.analyzedAt,
  });
  
  Map<String, dynamic> toJson() => {
    'accuracy_mean': accuracyMean,
    'stability_std': stabilityStd,
    'weak_notes': weakNotes,
    'detailed_metrics': detailedMetrics,
    'analyzed_at': analyzedAt.toIso8601String(),
  };
}

class AIFeedback {
  final String overallAssessment;
  final List<String> strengthsPoints;
  final List<String> improvementAreas;
  final List<String> specificRecommendations;
  final List<String> practiceExercises;
  final String encouragementMessage;
  final double confidenceScore;
  
  AIFeedback({
    required this.overallAssessment,
    required this.strengthsPoints,
    required this.improvementAreas,
    required this.specificRecommendations,
    required this.practiceExercises,
    required this.encouragementMessage,
    required this.confidenceScore,
  });
  
  factory AIFeedback.fromJson(Map<String, dynamic> json) {
    return AIFeedback(
      overallAssessment: json['overall_assessment'] ?? '',
      strengthsPoints: List<String>.from(json['strengths'] ?? []),
      improvementAreas: List<String>.from(json['improvement_areas'] ?? []),
      specificRecommendations: List<String>.from(json['recommendations'] ?? []),
      practiceExercises: List<String>.from(json['practice_exercises'] ?? []),
      encouragementMessage: json['encouragement'] ?? '',
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'overall_assessment': overallAssessment,
      'strengths': strengthsPoints,
      'improvement_areas': improvementAreas,
      'recommendations': specificRecommendations,
      'practice_exercises': practiceExercises,
      'encouragement': encouragementMessage,
      'confidence_score': confidenceScore,
    };
  }
}

class AIFeedbackService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _defaultModel = 'gpt-5-nano'; // 경제적 모델 우선 사용
  static const String _fallbackModel = 'gpt-4o-mini';
  
  final String? _apiKey;
  
  AIFeedbackService({String? apiKey}) : _apiKey = apiKey;
  
  // 보컬 분석 데이터 생성
  static VocalAnalysis generateAnalysis(
    PitchData pitchData,
    AudioReference audioReference
  ) {
    // 기본 통계 계산
    final basicStats = _calculateBasicStatistics(pitchData);
    
    // 약점 음표 식별
    final weakNotes = _identifyWeakNotes(pitchData.noteSegments);
    
    // 상세 메트릭 계산
    final detailedMetrics = _calculateDetailedMetrics(pitchData, audioReference);
    
    return VocalAnalysis(
      accuracyMean: basicStats['accuracy_mean'] ?? 0.0,
      stabilityStd: basicStats['stability_std'] ?? 0.0,
      weakNotes: weakNotes,
      detailedMetrics: detailedMetrics,
      analyzedAt: DateTime.now(),
    );
  }
  
  // AI 피드백 생성
  Future<AIFeedback?> generateFeedback(
    VocalAnalysis analysis,
    AudioReference audioReference,
    {String language = 'ko'}
  ) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('OpenAI API 키가 설정되지 않았습니다');
      return _generateFallbackFeedback(analysis, language);
    }
    
    try {
      final prompt = _buildFeedbackPrompt(analysis, audioReference, language);
      
      // GPT-5 nano 모델로 먼저 시도
      final response = await _callOpenAIAPI(prompt, _defaultModel);
      
      if (response != null) {
        return _parseFeedbackResponse(response);
      }
      
      // 실패 시 fallback 모델로 재시도
      final fallbackResponse = await _callOpenAIAPI(prompt, _fallbackModel);
      if (fallbackResponse != null) {
        return _parseFeedbackResponse(fallbackResponse);
      }
      
      // API 호출 실패 시 기본 피드백 제공
      return _generateFallbackFeedback(analysis, language);
      
    } catch (e) {
      print('AI 피드백 생성 오류: $e');
      return _generateFallbackFeedback(analysis, language);
    }
  }
  
  // OpenAI API 호출
  Future<String?> _callOpenAIAPI(String prompt, String model) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': '당신은 전문 보컬 트레이너입니다. 피치 분석 데이터를 바탕으로 건설적이고 격려적인 피드백을 제공합니다.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
          'response_format': {'type': 'json_object'}
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        print('OpenAI API 오류: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('API 호출 예외: $e');
      return null;
    }
  }
  
  // 피드백 프롬프트 생성
  String _buildFeedbackPrompt(
    VocalAnalysis analysis,
    AudioReference audioReference,
    String language
  ) {
    final scaleInfo = '${audioReference.key} ${audioReference.scaleType} ${audioReference.octaves} 옥타브';
    
    return '''
다음 보컬 피치 분석 결과를 바탕으로 JSON 형식의 피드백을 생성해주세요:

**연습한 스케일:** $scaleInfo
**분석 결과:**
- 평균 정확도: ${analysis.accuracyMean.toStringAsFixed(1)}센트
- 안정성 (표준편차): ${analysis.stabilityStd.toStringAsFixed(1)}센트
- 약점 음표: ${analysis.weakNotes.join(', ')}

**상세 메트릭:**
${analysis.detailedMetrics.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

JSON 응답 형식:
{
  "overall_assessment": "전반적인 평가 (2-3문장)",
  "strengths": ["강점1", "강점2", "강점3"],
  "improvement_areas": ["개선점1", "개선점2"],
  "recommendations": ["구체적 추천사항1", "구체적 추천사항2", "구체적 추천사항3"],
  "practice_exercises": ["연습법1", "연습법2", "연습법3"],
  "encouragement": "격려 메시지 (1-2문장)",
  "confidence_score": 0.85
}

격려적이고 건설적인 톤으로 작성해주세요. 구체적이고 실용적인 조언을 포함해주세요.
''';
  }
  
  // API 응답 파싱
  AIFeedback _parseFeedbackResponse(String response) {
    try {
      final json = jsonDecode(response);
      return AIFeedback.fromJson(json);
    } catch (e) {
      print('피드백 응답 파싱 오류: $e');
      // 파싱 실패 시 기본 구조로 처리
      return AIFeedback(
        overallAssessment: '분석이 완료되었습니다. 지속적인 연습으로 더욱 향상될 것입니다.',
        strengthsPoints: ['꾸준한 연습 의지'],
        improvementAreas: ['피치 정확도', '안정성'],
        specificRecommendations: ['천천히 스케일 연습하기', '메트로놈과 함께 연습하기'],
        practiceExercises: ['롱톤 연습', '스케일 반복 연습'],
        encouragementMessage: '꾸준한 연습이 실력 향상의 열쇠입니다!',
        confidenceScore: 0.7,
      );
    }
  }
  
  // Fallback 피드백 (API 실패 시)
  AIFeedback _generateFallbackFeedback(VocalAnalysis analysis, String language) {
    final isAccurate = analysis.accuracyMean.abs() < 20.0;
    final isStable = analysis.stabilityStd < 15.0;
    
    return AIFeedback(
      overallAssessment: isAccurate 
        ? '전반적으로 좋은 피치 정확도를 보여주고 있습니다. ${isStable ? "안정성도 우수합니다." : "안정성 개선이 필요합니다."}'
        : '피치 정확도 향상이 필요합니다. 꾸준한 연습을 통해 개선할 수 있습니다.',
      strengthsPoints: [
        if (isAccurate) '좋은 피치 정확도',
        if (isStable) '안정적인 발성',
        '지속적인 학습 의지'
      ],
      improvementAreas: [
        if (!isAccurate) '피치 정확도',
        if (!isStable) '발성 안정성',
        if (analysis.weakNotes.isNotEmpty) '특정 음표 연습'
      ],
      specificRecommendations: [
        '천천히 정확한 피치로 연습하기',
        '메트로놈과 함께 안정적인 템포 유지',
        '약점 음표 집중 연습'
      ],
      practiceExercises: [
        '롱톤 연습 (각 음표 5초씩)',
        '스케일 천천히 반복 연습',
        '호흡 연습과 발성 훈련'
      ],
      encouragementMessage: '꾸준한 연습이 가장 중요합니다. 조금씩 향상되고 있으니 포기하지 마세요!',
      confidenceScore: 0.8,
    );
  }
  
  // 기본 통계 계산
  static Map<String, double> _calculateBasicStatistics(PitchData pitchData) {
    final validSegments = pitchData.noteSegments
        .where((segment) => segment.actualFrequency > 0)
        .toList();
    
    if (validSegments.isEmpty) {
      return {'accuracy_mean': 0.0, 'stability_std': 0.0};
    }
    
    // 센트 오차 계산
    final centErrors = validSegments
        .map((segment) => segment.getAccuracyInCents().abs())
        .toList();
    
    // 평균
    final accuracyMean = centErrors.reduce((a, b) => a + b) / centErrors.length;
    
    // 표준편차
    final variance = centErrors
        .map((error) => (error - accuracyMean) * (error - accuracyMean))
        .reduce((a, b) => a + b) / centErrors.length;
    final stabilityStd = variance > 0 ? math.sqrt(variance) : 0.0;
    
    return {
      'accuracy_mean': accuracyMean,
      'stability_std': stabilityStd,
    };
  }
  
  // 약점 음표 식별
  static List<String> _identifyWeakNotes(List<NoteSegment> segments) {
    const threshold = 30.0; // 30센트 이상 오차
    
    return segments
        .where((segment) => 
            segment.actualFrequency > 0 && 
            segment.getAccuracyInCents().abs() > threshold)
        .map((segment) => 
            '${segment.noteName}(${segment.getAccuracyInCents().abs().round()}¢)')
        .toList();
  }
  
  // 상세 메트릭 계산
  static Map<String, dynamic> _calculateDetailedMetrics(
    PitchData pitchData,
    AudioReference audioReference
  ) {
    final segments = pitchData.noteSegments;
    final validSegments = segments.where((s) => s.actualFrequency > 0).toList();
    
    // 음표별 정확도
    final noteAccuracies = <String, List<double>>{};
    for (final segment in validSegments) {
      final noteName = segment.noteName.substring(0, segment.noteName.length - 1); // 옥타브 제거
      noteAccuracies.putIfAbsent(noteName, () => []);
      noteAccuracies[noteName]!.add(segment.getAccuracyInCents().abs());
    }
    
    // 시간대별 안정성
    final timeSegments = pitchData.pitchCurve.length ~/ 4;
    final timeSegmentAccuracies = <double>[];
    for (int i = 0; i < 4; i++) {
      final start = i * timeSegments;
      final end = (i + 1) * timeSegments;
      final segmentData = pitchData.pitchCurve.sublist(start, end.clamp(0, pitchData.pitchCurve.length));
      final validData = segmentData.where((f) => f > 0).toList();
      if (validData.isNotEmpty) {
        final mean = validData.reduce((a, b) => a + b) / validData.length;
        final variance = validData.map((f) => (f - mean) * (f - mean)).reduce((a, b) => a + b) / validData.length;
        timeSegmentAccuracies.add(math.sqrt(variance));
      }
    }
    
    return {
      'total_notes': segments.length,
      'valid_notes': validSegments.length,
      'completion_rate': (validSegments.length / segments.length * 100).round(),
      'note_accuracies': noteAccuracies.map((note, accuracies) => 
          MapEntry(note, accuracies.reduce((a, b) => a + b) / accuracies.length)),
      'time_stability': timeSegmentAccuracies.isNotEmpty 
          ? timeSegmentAccuracies.reduce((a, b) => a + b) / timeSegmentAccuracies.length
          : 0.0,
      'strongest_note': _findBestNote(noteAccuracies),
      'weakest_note': _findWorstNote(noteAccuracies),
    };
  }
  
  static String _findBestNote(Map<String, List<double>> noteAccuracies) {
    if (noteAccuracies.isEmpty) return '';
    
    String bestNote = '';
    double bestAccuracy = double.infinity;
    
    noteAccuracies.forEach((note, accuracies) {
      final avgAccuracy = accuracies.reduce((a, b) => a + b) / accuracies.length;
      if (avgAccuracy < bestAccuracy) {
        bestAccuracy = avgAccuracy;
        bestNote = note;
      }
    });
    
    return bestNote;
  }
  
  static String _findWorstNote(Map<String, List<double>> noteAccuracies) {
    if (noteAccuracies.isEmpty) return '';
    
    String worstNote = '';
    double worstAccuracy = 0.0;
    
    noteAccuracies.forEach((note, accuracies) {
      final avgAccuracy = accuracies.reduce((a, b) => a + b) / accuracies.length;
      if (avgAccuracy > worstAccuracy) {
        worstAccuracy = avgAccuracy;
        worstNote = note;
      }
    });
    
    return worstNote;
  }
}