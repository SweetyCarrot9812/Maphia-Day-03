import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/speaking_models.dart';

class AIEvaluationService {
  static const String _openAiApiUrl = 'https://api.openai.com/v1/audio/transcriptions';
  static const String _chatApiUrl = 'https://api.openai.com/v1/chat/completions';
  
  // API 키는 환경변수나 설정에서 가져와야 함
  final String _apiKey = const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  // 음성을 텍스트로 변환 (Whisper API)
  Future<String> transcribeAudio(String audioFilePath) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    try {
      final file = File(audioFilePath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $audioFilePath');
      }

      final bytes = await file.readAsBytes();
      
      final request = http.MultipartRequest('POST', Uri.parse(_openAiApiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'multipart/form-data',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'audio.aac',
        ),
      );
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'en';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['text'] ?? '';
      } else {
        throw Exception('Transcription failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('Transcription error: $e');
      rethrow;
    }
  }

  // 발음 평가 수행
  Future<SpeakingEvaluation> evaluatePronunciation({
    required String audioFilePath,
    required String expectedText,
    required List<String> keyWords,
  }) async {
    try {
      // 1. 음성을 텍스트로 변환
      final transcribedText = await transcribeAudio(audioFilePath);
      
      // 2. AI를 통한 발음 평가
      final evaluation = await _performAIEvaluation(
        expectedText: expectedText,
        transcribedText: transcribedText,
        keyWords: keyWords,
      );

      return evaluation;
    } catch (e) {
      print('Evaluation error: $e');
      rethrow;
    }
  }

  // AI를 통한 상세 평가 수행
  Future<SpeakingEvaluation> _performAIEvaluation({
    required String expectedText,
    required String transcribedText,
    required List<String> keyWords,
  }) async {
    if (_apiKey.isEmpty) {
      return _createMockEvaluation(expectedText, transcribedText, keyWords);
    }

    try {
      final prompt = _buildEvaluationPrompt(
        expectedText: expectedText,
        transcribedText: transcribedText,
        keyWords: keyWords,
      );

      final response = await http.post(
        Uri.parse(_chatApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert English pronunciation evaluator. Provide detailed, constructive feedback on pronunciation accuracy, fluency, and overall speaking performance.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final aiResponse = jsonResponse['choices'][0]['message']['content'];
        
        return _parseAIEvaluation(aiResponse, transcribedText, keyWords);
      } else {
        throw Exception('AI evaluation failed: ${response.statusCode}');
      }
    } catch (e) {
      print('AI evaluation error: $e');
      return _createMockEvaluation(expectedText, transcribedText, keyWords);
    }
  }

  // 평가 프롬프트 생성
  String _buildEvaluationPrompt({
    required String expectedText,
    required String transcribedText,
    required List<String> keyWords,
  }) {
    return '''
Please evaluate the following English pronunciation:

Expected text: "$expectedText"
Transcribed text: "$transcribedText"
Key words to focus on: ${keyWords.join(', ')}

Please provide a detailed evaluation with the following format:
1. Overall Score (0-100): [score]
2. Pronunciation Score (0-100): [score]
3. Fluency Score (0-100): [score]
4. Accuracy Score (0-100): [score]
5. Word-by-word feedback in JSON format:
[
  {
    "word": "example",
    "score": 85,
    "suggestion": "Try to emphasize the first syllable more",
    "phoneticCorrection": "/ɪɡˈzæmpəl/",
    "isCorrect": true
  }
]

Please provide constructive feedback focusing on:
- Pronunciation accuracy for each key word
- Overall fluency and rhythm
- Suggestions for improvement
- Phonetic guidance where helpful

Make sure scores are realistic and helpful for learning.
''';
  }

  // AI 응답 파싱
  SpeakingEvaluation _parseAIEvaluation(
    String aiResponse,
    String transcribedText,
    List<String> keyWords,
  ) {
    try {
      // AI 응답에서 점수들을 추출 (정규식 사용)
      final overallScoreMatch = RegExp(r'Overall Score.*?(\d+)').firstMatch(aiResponse);
      final pronunciationScoreMatch = RegExp(r'Pronunciation Score.*?(\d+)').firstMatch(aiResponse);
      final fluencyScoreMatch = RegExp(r'Fluency Score.*?(\d+)').firstMatch(aiResponse);
      final accuracyScoreMatch = RegExp(r'Accuracy Score.*?(\d+)').firstMatch(aiResponse);

      final overallScore = double.tryParse(overallScoreMatch?.group(1) ?? '75') ?? 75.0;
      final pronunciationScore = double.tryParse(pronunciationScoreMatch?.group(1) ?? '75') ?? 75.0;
      final fluencyScore = double.tryParse(fluencyScoreMatch?.group(1) ?? '75') ?? 75.0;
      final accuracyScore = double.tryParse(accuracyScoreMatch?.group(1) ?? '75') ?? 75.0;

      // 단어별 피드백 생성 (간단한 버전)
      final feedback = _generateWordFeedback(keyWords, transcribedText);

      return SpeakingEvaluation(
        overallScore: overallScore,
        pronunciationScore: pronunciationScore,
        fluencyScore: fluencyScore,
        accuracyScore: accuracyScore,
        transcribedText: transcribedText,
        feedback: feedback,
        evaluatedAt: DateTime.now(),
        aiModel: 'gpt-4-with-whisper',
      );
    } catch (e) {
      print('AI response parsing error: $e');
      return _createMockEvaluation('', transcribedText, keyWords);
    }
  }

  // 단어별 피드백 생성
  List<PronunciationFeedback> _generateWordFeedback(
    List<String> keyWords,
    String transcribedText,
  ) {
    final feedback = <PronunciationFeedback>[];
    final transcribedLower = transcribedText.toLowerCase();

    for (final word in keyWords) {
      final wordLower = word.toLowerCase();
      final isPresent = transcribedLower.contains(wordLower);
      final score = isPresent ? 85.0 + (DateTime.now().millisecond % 15) : 50.0;
      
      feedback.add(PronunciationFeedback(
        word: word,
        score: score,
        suggestion: isPresent 
            ? 'Good pronunciation! Try to be more confident.'
            : 'This word was not clearly detected. Practice the pronunciation.',
        phoneticCorrection: _getPhoneticTranscription(word),
        isCorrect: isPresent && score > 70,
      ));
    }

    return feedback;
  }

  // 간단한 발음 기호 매핑
  String _getPhoneticTranscription(String word) {
    final phoneticMap = {
      'hello': '/həˈloʊ/',
      'how': '/haʊ/',
      'are': '/ɑːr/',
      'you': '/juː/',
      'nice': '/naɪs/',
      'meet': '/miːt/',
      'what': '/wʌt/',
      'doing': '/ˈduːɪŋ/',
      'weekend': '/ˈwiːkend/',
      'schedule': '/ˈʃedjuːl/',
      'meeting': '/ˈmiːtɪŋ/',
    };

    return phoneticMap[word.toLowerCase()] ?? '/phonetic/';
  }

  // 모의 평가 생성 (API 키가 없을 때)
  SpeakingEvaluation _createMockEvaluation(
    String expectedText,
    String transcribedText,
    List<String> keyWords,
  ) {
    // 간단한 유사도 계산
    final similarity = _calculateSimilarity(expectedText, transcribedText);
    final baseScore = (similarity * 100).clamp(0, 100);
    
    return SpeakingEvaluation(
      overallScore: baseScore.toDouble(),
      pronunciationScore: (baseScore + 5).toDouble(),
      fluencyScore: (baseScore - 5).toDouble(),
      accuracyScore: baseScore.toDouble(),
      transcribedText: transcribedText.isNotEmpty ? transcribedText : 'Mock transcription: $expectedText',
      feedback: _generateWordFeedback(keyWords, transcribedText),
      evaluatedAt: DateTime.now(),
      aiModel: 'mock-evaluator',
    );
  }

  // 간단한 텍스트 유사도 계산
  double _calculateSimilarity(String text1, String text2) {
    if (text1.isEmpty && text2.isEmpty) return 1.0;
    if (text1.isEmpty || text2.isEmpty) return 0.0;

    final words1 = text1.toLowerCase().split(' ');
    final words2 = text2.toLowerCase().split(' ');
    
    final commonWords = words1.where((word) => words2.contains(word)).length;
    final totalWords = (words1.length + words2.length) / 2;
    
    return commonWords / totalWords;
  }

  // 배치 평가 (여러 녹음을 한번에 평가)
  Future<List<SpeakingEvaluation>> evaluateBatch(
    List<Map<String, dynamic>> evaluationData,
  ) async {
    final results = <SpeakingEvaluation>[];
    
    for (final data in evaluationData) {
      try {
        final evaluation = await evaluatePronunciation(
          audioFilePath: data['audioFilePath'],
          expectedText: data['expectedText'],
          keyWords: data['keyWords'],
        );
        results.add(evaluation);
      } catch (e) {
        print('Batch evaluation error for ${data['audioFilePath']}: $e');
        // 에러가 발생한 경우 모의 평가라도 추가
        results.add(_createMockEvaluation(
          data['expectedText'],
          '',
          data['keyWords'],
        ));
      }
    }
    
    return results;
  }
}