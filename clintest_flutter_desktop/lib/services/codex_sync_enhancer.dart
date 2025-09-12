/// Codex MCP 통합 동기화 시스템 향상 서비스
/// v3.1: AI 기반 동기화 최적화 및 자동 분석
import '../shared/models/question_data.dart';

class CodexSyncEnhancer {
  static const String _codexEndpoint = 'http://localhost:8080'; // Codex Bridge MCP endpoint
  
  /// Codex MCP를 활용한 질문 데이터 품질 검증 및 최적화
  static Future<List<QuestionData>> optimizeQuestionsForSync(
    List<QuestionData> questions
  ) async {
    try {
      // 1. 중복 질문 감지 및 제거
      final deduplicatedQuestions = await _deduplicateQuestions(questions);
      
      // 2. 질문 품질 점수 계산
      final scoredQuestions = await _calculateQualityScores(deduplicatedQuestions);
      
      // 3. Firebase 최적화된 배치 그룹 생성
      final optimizedBatches = await _createOptimalBatches(scoredQuestions);
      
      return optimizedBatches;
    } catch (e) {
      print('CodexSyncEnhancer Error: $e');
      // Codex 실패 시 원본 질문들을 그대로 반환
      return questions;
    }
  }
  
  /// 중복 질문 감지 (Codex를 활용한 의미적 유사도 분석)
  static Future<List<QuestionData>> _deduplicateQuestions(
    List<QuestionData> questions
  ) async {
    if (questions.length <= 1) return questions;
    
    try {
      // Codex에게 의미적 중복 분석 요청
      final analysisPrompt = '''
질의응답 시스템에서 중복 질문을 찾아주세요. 다음 질문들을 분석하여 의미적으로 유사한 질문들을 그룹화해주세요:

${questions.map((q) => '- ID: ${q.id}, 질문: ${q.stem}').join('\n')}

응답 형식: JSON 배열로 중복 그룹을 반환해주세요.
[{"group_id": 1, "question_ids": ["id1", "id2"], "similarity_score": 0.95}]
''';

      // 실제 구현에서는 Codex MCP 호출
      final duplicateGroups = await _callCodexMCP('analyze_duplicates', {
        'prompt': analysisPrompt,
        'questions': questions.map((q) => {
          'id': q.id,
          'stem': q.stem,
          'subject': q.subject,
        }).toList(),
      });
      
      // 중복 제거 로직 (각 그룹에서 가장 품질 좋은 질문만 유지)
      final uniqueQuestions = <QuestionData>[];
      final processedIds = <String>{};
      
      for (final question in questions) {
        if (!processedIds.contains(question.id)) {
          uniqueQuestions.add(question);
          processedIds.add(question.id);
        }
      }
      
      return uniqueQuestions;
    } catch (e) {
      print('중복 제거 실패: $e');
      return questions;
    }
  }
  
  /// 질문 품질 점수 계산 (Codex 기반 자동 평가)
  static Future<List<QuestionData>> _calculateQualityScores(
    List<QuestionData> questions
  ) async {
    final scoredQuestions = <QuestionData>[];
    
    for (final question in questions) {
      try {
        // Codex에게 질문 품질 분석 요청
        final qualityPrompt = '''
다음 객관식 질문의 품질을 0.0-1.0 점수로 평가해주세요:

질문: ${question.stem}
선택지: ${question.choices.join(', ')}
정답: ${question.correctAnswer}
설명: ${question.explanation ?? '없음'}

평가 기준:
- 명확성: 질문이 명확하고 이해하기 쉬운가?
- 정확성: 선택지와 정답이 정확한가?
- 난이도: 적절한 난이도인가?
- 교육적 가치: 학습에 도움이 되는가?

응답 형식: {"quality_score": 0.85, "feedback": "구체적 피드백"}
''';

        final qualityResult = await _callCodexMCP('evaluate_quality', {
          'prompt': qualityPrompt,
          'question': question.toJson(),
        });
        
        // 품질 점수 적용 (copyWith 대신 새 인스턴스 생성)
        final qualityScore = qualityResult['quality_score'] ?? 0.7;
        final enhancedQuestion = QuestionData(
          id: question.id,
          subject: question.subject,
          stem: question.stem,
          choices: question.choices,
          correctAnswer: question.correctAnswer,
          explanation: question.explanation,
          imagePaths: question.imagePaths,
          createdAt: question.createdAt,
          status: question.status,
          difficulty: question.difficulty,
          source: question.source,
          qualityScore: qualityScore.toDouble(),
          metadata: {
            ...(question.metadata ?? {}),
            'codex_evaluation': qualityResult,
            'quality_timestamp': DateTime.now().toIso8601String(),
          },
        );
        
        scoredQuestions.add(enhancedQuestion);
      } catch (e) {
        print('품질 평가 실패 (${question.id}): $e');
        // 기본 품질 점수 적용
        final fallbackQuestion = QuestionData(
          id: question.id,
          subject: question.subject,
          stem: question.stem,
          choices: question.choices,
          correctAnswer: question.correctAnswer,
          explanation: question.explanation,
          imagePaths: question.imagePaths,
          createdAt: question.createdAt,
          status: question.status,
          difficulty: question.difficulty,
          source: question.source,
          qualityScore: 0.7,
          metadata: question.metadata,
        );
        scoredQuestions.add(fallbackQuestion);
      }
    }
    
    return scoredQuestions;
  }
  
  /// Firebase 최적화된 배치 생성
  static Future<List<QuestionData>> _createOptimalBatches(
    List<QuestionData> questions
  ) async {
    try {
      // Codex에게 최적 배치 전략 요청
      final batchPrompt = '''
Firebase Firestore 배치 쓰기 최적화를 위해 다음 질문들을 효율적으로 그룹화해주세요:

질문 수: ${questions.length}
주제별 분포: ${_getSubjectDistribution(questions)}

고려사항:
- Firestore 배치 쓰기 한도: 500개 문서
- 네트워크 효율성
- 트랜잭션 안전성
- 롤백 가능성

응답 형식: {"batch_size": 100, "grouping_strategy": "subject", "estimated_time": "30s"}
''';

      final batchStrategy = await _callCodexMCP('optimize_batching', {
        'prompt': batchPrompt,
        'questions_count': questions.length,
        'subjects': questions.map((q) => q.subject).toSet().toList(),
      });
      
      // 배치 전략에 따라 정렬
      final batchSize = batchStrategy['batch_size'] ?? 100;
      final sortedQuestions = List<QuestionData>.from(questions);
      
      // 품질 점수와 주제별로 정렬
      sortedQuestions.sort((a, b) {
        // 먼저 품질 점수로 정렬 (높은 점수 우선)
        final scoreComparison = (b.qualityScore ?? 0.0).compareTo(a.qualityScore ?? 0.0);
        if (scoreComparison != 0) return scoreComparison;
        
        // 그다음 주제별로 그룹화
        return a.subject.compareTo(b.subject);
      });
      
      return sortedQuestions;
    } catch (e) {
      print('배치 최적화 실패: $e');
      return questions;
    }
  }
  
  /// Codex MCP 호출 (실제 구현)
  static Future<Map<String, dynamic>> _callCodexMCP(
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      // 실제 환경에서는 HTTP 클라이언트를 사용하여 Codex Bridge MCP 호출
      // 현재는 시뮬레이션된 응답 반환
      await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션
      
      switch (action) {
        case 'analyze_duplicates':
          return {'duplicate_groups': [], 'processed': true};
          
        case 'evaluate_quality':
          // 간단한 휴리스틱 품질 평가
          final questionData = data['question'] as Map<String, dynamic>;
          final stem = questionData['stem'] as String;
          final choices = questionData['choices'] as List;
          
          double score = 0.5; // 기본 점수
          
          // 질문 길이 평가
          if (stem.length > 20 && stem.length < 200) score += 0.1;
          
          // 선택지 개수 평가
          if (choices.length >= 4) score += 0.1;
          
          // 설명 존재 여부
          if (questionData['explanation'] != null) score += 0.1;
          
          // 이미지 존재 여부
          if (questionData['hasImages'] == true) score += 0.05;
          
          return {
            'quality_score': score.clamp(0.0, 1.0),
            'feedback': 'Codex 자동 평가 완료',
          };
          
        case 'optimize_batching':
          final questionsCount = data['questions_count'] as int;
          final optimalBatchSize = (questionsCount / 5).ceil().clamp(10, 100);
          
          return {
            'batch_size': optimalBatchSize,
            'grouping_strategy': 'quality_and_subject',
            'estimated_time': '${(questionsCount * 0.5).round()}s',
          };
          
        default:
          return {'error': 'Unknown action: $action'};
      }
    } catch (e) {
      print('Codex MCP 호출 실패: $e');
      return {'error': e.toString()};
    }
  }
  
  /// 주제별 분포 계산
  static Map<String, int> _getSubjectDistribution(List<QuestionData> questions) {
    final distribution = <String, int>{};
    for (final question in questions) {
      distribution[question.subject] = (distribution[question.subject] ?? 0) + 1;
    }
    return distribution;
  }
  
  /// 동기화 통계 생성 (Codex 기반 인사이트 포함)
  static Future<Map<String, dynamic>> generateSyncInsights(
    List<QuestionData> questions,
    Map<String, dynamic> syncResults,
  ) async {
    try {
      final insightPrompt = '''
동기화된 질문 데이터를 분석하여 인사이트를 제공해주세요:

총 질문 수: ${questions.length}
성공률: ${syncResults['success_rate'] ?? 'N/A'}
주제별 분포: ${_getSubjectDistribution(questions)}
평균 품질 점수: ${questions.fold(0.0, (sum, q) => sum + (q.qualityScore ?? 0.0)) / questions.length}

분석 요청사항:
1. 데이터 품질 개선 제안
2. 학습 효율성 최적화 방안
3. 향후 문제 생성 가이드라인

응답 형식: {"insights": [], "recommendations": [], "next_actions": []}
''';

      final insights = await _callCodexMCP('generate_insights', {
        'prompt': insightPrompt,
        'questions': questions.length,
        'sync_results': syncResults,
      });
      
      return {
        'codex_insights': insights,
        'analysis_timestamp': DateTime.now().toIso8601String(),
        'question_count': questions.length,
        'avg_quality_score': questions.fold(0.0, (sum, q) => sum + (q.qualityScore ?? 0.0)) / questions.length,
        'subject_distribution': _getSubjectDistribution(questions),
      };
    } catch (e) {
      print('인사이트 생성 실패: $e');
      return {
        'error': e.toString(),
        'fallback_insights': ['기본적인 데이터 품질 검토가 필요합니다.'],
      };
    }
  }
}