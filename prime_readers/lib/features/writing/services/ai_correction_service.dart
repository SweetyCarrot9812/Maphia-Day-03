import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/writing_models.dart';

class AICorrectionService {
  static const String _openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  final String? _openAIApiKey;
  final String? _geminiApiKey;
  final Random _random = Random();

  AICorrectionService({
    String? openAIApiKey,
    String? geminiApiKey,
  }) : _openAIApiKey = openAIApiKey,
       _geminiApiKey = geminiApiKey;

  // 메인 평가 함수
  Future<WritingEvaluation> evaluateWriting({
    required String submissionId,
    required String content,
    required WritingTask task,
    String? ocrText,
    AIModel preferredModel = AIModel.openAI,
  }) async {
    try {
      // 실제 AI API 호출 시도
      if (preferredModel == AIModel.openAI && _openAIApiKey != null) {
        return await _evaluateWithOpenAI(submissionId, content, task, ocrText);
      } else if (preferredModel == AIModel.gemini && _geminiApiKey != null) {
        return await _evaluateWithGemini(submissionId, content, task, ocrText);
      }
    } catch (e) {
      print('AI evaluation failed: $e');
    }

    // AI 호출 실패 시 모의 평가 반환
    return _generateMockEvaluation(submissionId, content, task);
  }

  // OpenAI GPT를 이용한 평가
  Future<WritingEvaluation> _evaluateWithOpenAI(
    String submissionId,
    String content,
    WritingTask task,
    String? ocrText,
  ) async {
    final prompt = _buildEvaluationPrompt(content, task, ocrText);
    
    final requestBody = {
      'model': 'gpt-4',
      'messages': [
        {
          'role': 'system',
          'content': 'You are an experienced English writing teacher. Evaluate the student\'s writing and provide detailed feedback in JSON format.',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'temperature': 0.3,
      'max_tokens': 2000,
    };

    final response = await http.post(
      Uri.parse(_openAIEndpoint),
      headers: {
        'Authorization': 'Bearer $_openAIApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final aiResponse = responseData['choices'][0]['message']['content'];
      
      return _parseAIResponse(submissionId, aiResponse, 'gpt-4');
    } else {
      throw Exception('OpenAI API call failed: ${response.statusCode}');
    }
  }

  // Gemini를 이용한 평가
  Future<WritingEvaluation> _evaluateWithGemini(
    String submissionId,
    String content,
    WritingTask task,
    String? ocrText,
  ) async {
    final prompt = _buildEvaluationPrompt(content, task, ocrText);
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text': 'You are an experienced English writing teacher. Evaluate the student\'s writing and provide detailed feedback in JSON format.\n\n$prompt'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 2000,
      }
    };

    final url = '$_geminiEndpoint?key=$_geminiApiKey';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final aiResponse = responseData['candidates'][0]['content']['parts'][0]['text'];
      
      return _parseAIResponse(submissionId, aiResponse, 'gemini-pro');
    } else {
      throw Exception('Gemini API call failed: ${response.statusCode}');
    }
  }

  // 평가 프롬프트 생성
  String _buildEvaluationPrompt(String content, WritingTask task, String? ocrText) {
    final ocrInfo = ocrText != null 
        ? '\n\nOCR Recognized Text (from handwriting): $ocrText\nFinal Submitted Text: $content'
        : '\n\nSubmitted Text: $content';

    return '''
Task: ${task.title}
Description: ${task.description}
Prompt: ${task.prompt}
Type: ${task.type.name}
Difficulty: ${task.difficulty.name}
Word Limit: ${task.minWords}-${task.maxWords} words
Key Points: ${task.keyPoints.join(', ')}
$ocrInfo

Please evaluate this writing and provide feedback in the following JSON format:
{
  "overallScore": 85,
  "grammarScore": 80,
  "vocabularyScore": 90,
  "contentScore": 85,
  "structureScore": 82,
  "creativityScore": 88,
  "errors": [
    {
      "type": "grammar",
      "originalText": "text with error",
      "correctedText": "corrected text",
      "explanation": "explanation of the error",
      "startPosition": 10,
      "endPosition": 20,
      "severity": "medium"
    }
  ],
  "suggestions": [
    {
      "type": "vocabulary",
      "title": "Better word choice",
      "description": "Consider using more precise vocabulary",
      "example": "example text",
      "priority": "medium"
    }
  ],
  "overallFeedback": "Overall feedback paragraph",
  "strengths": ["strength 1", "strength 2"],
  "improvements": ["improvement 1", "improvement 2"]
}

Focus on:
1. Grammar and spelling accuracy
2. Vocabulary usage and variety
3. Content relevance to the prompt
4. Text structure and organization
5. Creativity and originality (if applicable)

Provide constructive feedback that helps the student improve.
''';
  }

  // AI 응답 파싱
  WritingEvaluation _parseAIResponse(String submissionId, String aiResponse, String model) {
    try {
      // JSON 부분만 추출 (응답에 다른 텍스트가 포함될 수 있음)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(aiResponse);
      if (jsonMatch == null) {
        throw Exception('No JSON found in AI response');
      }

      final jsonData = jsonDecode(jsonMatch.group(0)!);
      
      return WritingEvaluation(
        id: 'eval_${DateTime.now().millisecondsSinceEpoch}',
        submissionId: submissionId,
        overallScore: (jsonData['overallScore'] as num).toDouble(),
        grammarScore: (jsonData['grammarScore'] as num).toDouble(),
        vocabularyScore: (jsonData['vocabularyScore'] as num).toDouble(),
        contentScore: (jsonData['contentScore'] as num).toDouble(),
        structureScore: (jsonData['structureScore'] as num).toDouble(),
        creativityScore: (jsonData['creativityScore'] as num).toDouble(),
        errors: (jsonData['errors'] as List).map((errorData) => WritingError(
          id: 'error_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
          type: WritingErrorType.values.firstWhere(
            (type) => type.name == errorData['type'],
            orElse: () => WritingErrorType.grammar,
          ),
          originalText: errorData['originalText'],
          correctedText: errorData['correctedText'],
          description: errorData['explanation'],
          rule: 'Grammar rule',
          confidence: 0.85,
          startPosition: errorData['startPosition'],
          endPosition: errorData['endPosition'],
        )).toList(),
        suggestions: (jsonData['suggestions'] as List).map((suggestionData) => WritingSuggestion(
          id: 'suggestion_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
          type: WritingSuggestionType.values.firstWhere(
            (type) => type.name == suggestionData['type'],
            orElse: () => WritingSuggestionType.vocabulary,
          ),
          title: suggestionData['title'],
          description: suggestionData['description'],
          example: suggestionData['example'],
          priority: 0.7,
        )).toList(),
        feedback: jsonData['overallFeedback'],
        evaluatedAt: DateTime.now(),
      );
    } catch (e) {
      // JSON 파싱 실패 시 기본 평가 반환
      return _generateMockEvaluation(submissionId, '', null);
    }
  }

  // 모의 평가 생성 (AI 호출 실패 시)
  WritingEvaluation _generateMockEvaluation(String submissionId, String content, WritingTask? task) {
    final wordCount = content.split(' ').where((word) => word.isNotEmpty).length;
    final baseScore = _calculateMockScore(content, wordCount, task);
    
    return WritingEvaluation(
      id: 'eval_${DateTime.now().millisecondsSinceEpoch}',
      submissionId: submissionId,
      overallScore: baseScore,
      grammarScore: baseScore + _random.nextDouble() * 10 - 5,
      vocabularyScore: baseScore + _random.nextDouble() * 10 - 5,
      contentScore: baseScore + _random.nextDouble() * 10 - 5,
      structureScore: baseScore + _random.nextDouble() * 10 - 5,
      creativityScore: baseScore + _random.nextDouble() * 10 - 5,
      errors: _generateMockErrors(content),
      suggestions: _generateMockSuggestions(),
      feedback: _generateMockFeedback(baseScore),
      evaluatedAt: DateTime.now(),
    );
  }

  // 모의 점수 계산
  double _calculateMockScore(String content, int wordCount, WritingTask? task) {
    double score = 70.0; // 기본 점수
    
    // 길이 기준 점수 조정
    if (task != null) {
      if (wordCount >= task.minWords && wordCount <= task.maxWords) {
        score += 10; // 적절한 길이
      } else if (wordCount < task.minWords) {
        score -= 15; // 너무 짧음
      } else {
        score -= 5; // 너무 김
      }
    }
    
    // 문장 수에 따른 점수 조정
    final sentences = content.split(RegExp(r'[.!?]')).where((s) => s.trim().isNotEmpty).length;
    if (sentences >= 3) score += 5;
    if (sentences >= 5) score += 5;
    
    // 단어 다양성에 따른 점수 조정
    final uniqueWords = content.toLowerCase().split(' ').toSet().length;
    final totalWords = content.split(' ').where((w) => w.isNotEmpty).length;
    final diversity = totalWords > 0 ? uniqueWords / totalWords : 0;
    if (diversity > 0.7) score += 10;
    
    return score.clamp(0, 100);
  }

  // 모의 오류 생성
  List<WritingError> _generateMockErrors(String content) {
    final errors = <WritingError>[];
    final errorTypes = [
      WritingErrorType.grammar,
      WritingErrorType.spelling,
      WritingErrorType.punctuation,
      WritingErrorType.vocabulary,
    ];
    
    // 랜덤하게 1-3개의 오류 생성
    final errorCount = _random.nextInt(3) + 1;
    for (int i = 0; i < errorCount; i++) {
      final type = errorTypes[_random.nextInt(errorTypes.length)];
      final startPos = _random.nextInt(content.length.clamp(0, 50));
      
      errors.add(WritingError(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}_$i',
        type: type,
        originalText: 'example error',
        correctedText: 'corrected example',
        description: _getErrorExplanation(type),
        rule: 'Writing rule',
        confidence: 0.8,
        startPosition: startPos,
        endPosition: startPos + 10,
      ));
    }
    
    return errors;
  }

  // 오류 설명 생성
  String _getErrorExplanation(WritingErrorType type) {
    switch (type) {
      case WritingErrorType.grammar:
        return '문법 규칙을 확인해보세요. 주어와 동사의 일치를 점검하세요.';
      case WritingErrorType.spelling:
        return '맞춤법을 확인해보세요. 올바른 철자를 사용하세요.';
      case WritingErrorType.punctuation:
        return '구두점 사용을 확인해보세요. 문장 끝에 적절한 구두점을 사용하세요.';
      case WritingErrorType.vocabulary:
        return '더 적절한 단어를 선택해보세요. 문맥에 맞는 어휘를 사용하세요.';
      default:
        return '이 부분을 다시 검토해보세요.';
    }
  }

  // 모의 제안 생성
  List<WritingSuggestion> _generateMockSuggestions() {
    return [
      WritingSuggestion(
        id: 'suggestion_1',
        type: WritingSuggestionType.vocabulary,
        title: '어휘력 향상',
        description: '더 다양하고 정확한 어휘를 사용해보세요.',
        example: '"good" 대신 "excellent", "wonderful" 등을 사용해보세요.',
        priority: 0.7,
      ),
      WritingSuggestion(
        id: 'suggestion_2',
        type: WritingSuggestionType.structure,
        title: '문단 구성',
        description: '문단 간의 연결을 더 명확하게 해보세요.',
        example: '전환어구(However, Furthermore, In conclusion)를 사용해보세요.',
        priority: 0.9,
      ),
    ];
  }

  // 모의 피드백 생성
  String _generateMockFeedback(double score) {
    if (score >= 90) {
      return '정말 훌륭한 글입니다! 창의적이고 잘 구성된 내용으로 주제를 효과적으로 다뤘습니다. 계속 이런 수준을 유지해보세요.';
    } else if (score >= 80) {
      return '잘 쓰여진 글입니다. 주제를 적절히 다뤘고 구조도 좋습니다. 몇 가지 작은 개선사항이 있지만 전체적으로 만족스럽습니다.';
    } else if (score >= 70) {
      return '괜찮은 글입니다. 주제에 대한 이해는 좋지만 표현력과 구성 면에서 조금 더 발전시킬 필요가 있습니다.';
    } else {
      return '기본적인 요소들은 갖추고 있지만 더 많은 연습이 필요합니다. 문법과 어휘력을 향상시키고 구조를 더 체계적으로 구성해보세요.';
    }
  }

  // 모의 강점 생성
  List<String> _generateMockStrengths() {
    final strengths = [
      '주제에 대한 이해가 좋습니다',
      '창의적인 아이디어를 제시했습니다',
      '문장 구조가 다양합니다',
      '개인적인 경험을 잘 활용했습니다',
      '논리적인 흐름을 갖추고 있습니다',
    ];
    
    return strengths.take(_random.nextInt(3) + 2).toList();
  }

  // 모의 개선사항 생성
  List<String> _generateMockImprovements() {
    final improvements = [
      '더 다양한 어휘를 사용해보세요',
      '문단 간의 연결을 강화해보세요',
      '구체적인 예시를 더 추가해보세요',
      '결론을 더 강력하게 마무리해보세요',
      '문법 검토를 한 번 더 해보세요',
    ];
    
    return improvements.take(_random.nextInt(3) + 2).toList();
  }

  // 실시간 문법 검사
  Future<List<WritingError>> checkGrammarRealtime(String text) async {
    // 실제 구현에서는 Grammarly API, LanguageTool API 등을 사용
    // 여기서는 간단한 패턴 기반 검사 구현
    return _performBasicGrammarCheck(text);
  }

  // 기본 문법 검사
  List<WritingError> _performBasicGrammarCheck(String text) {
    final errors = <WritingError>[];
    
    // 기본적인 패턴 검사
    final patterns = {
      r'\bi\b': 'I', // 소문자 'i' -> 대문자 'I'
      r'\bthier\b': 'their', // 일반적인 맞춤법 오류
      r'\bteh\b': 'the',
      r'\badn\b': 'and',
    };
    
    patterns.forEach((pattern, correction) {
      final matches = RegExp(pattern, caseSensitive: false).allMatches(text);
      for (final match in matches) {
        errors.add(WritingError(
          id: 'realtime_${DateTime.now().millisecondsSinceEpoch}_${errors.length}',
          type: WritingErrorType.spelling,
          originalText: match.group(0)!,
          correctedText: correction,
          description: 'Check spelling',
          rule: 'Spelling rule',
          confidence: 0.95,
          startPosition: match.start,
          endPosition: match.end,
        ));
      }
    });
    
    return errors;
  }
}

// AI 모델 선택
enum AIModel {
  openAI,
  gemini,
  claude,
  mock,
}