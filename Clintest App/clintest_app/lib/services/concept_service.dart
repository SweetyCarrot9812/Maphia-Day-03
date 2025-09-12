import 'package:isar/isar.dart';
import '../models/concept.dart';
import 'database_service.dart';
import 'api_service.dart';

/// 개념 학습 서비스
class ConceptService {
  static final Isar _isar = DatabaseService.isar;

  // =================
  // 개념 조회 메서드
  // =================

  /// 모든 개념 조회
  static Future<List<Concept>> getAllConcepts() async {
    return await _isar.concepts
        .where()
        .sortByLearningOrder()
        .findAll();
  }

  /// 과목별 개념 조회
  static Future<List<Concept>> getConceptsBySubject(String subjectCode) async {
    return await _isar.concepts
        .where()
        .filter()
        .subjectCodeEqualTo(subjectCode)
        .sortByLearningOrder()
        .findAll();
  }

  /// 학습 가능한 개념들 조회 (선수 개념 완료된 것들)
  static Future<List<Concept>> getAvailableConcepts(String subjectCode) async {
    final allConcepts = await getConceptsBySubject(subjectCode);
    final availableConcepts = <Concept>[];
    
    for (final concept in allConcepts) {
      if (!concept.isLearned && concept.isReadyToLearn(allConcepts)) {
        availableConcepts.add(concept);
      }
    }
    
    return availableConcepts..sort((a, b) => a.learningOrder.compareTo(b.learningOrder));
  }

  /// 복습 필요한 개념들 조회
  static Future<List<Concept>> getConceptsForReview() async {
    final allConcepts = await getAllConcepts();
    return allConcepts.where((concept) => concept.shouldReview).toList();
  }

  /// 개념 코드로 조회
  static Future<Concept?> getConceptByCode(String conceptCode) async {
    return await _isar.concepts
        .where()
        .filter()
        .conceptCodeEqualTo(conceptCode)
        .findFirst();
  }

  /// 관련 개념들 조회 (선수/후속 개념)
  static Future<List<Concept>> getRelatedConcepts(String conceptCode) async {
    final concept = await getConceptByCode(conceptCode);
    if (concept == null) return [];

    final relatedCodes = <String>[
      ...concept.prerequisites,
      ...concept.followUps,
    ];

    if (relatedCodes.isEmpty) return [];

    return await _isar.concepts
        .where()
        .anyOf(relatedCodes, (q, conceptCode) => q.conceptCodeEqualTo(conceptCode))
        .findAll();
  }

  // =================
  // 학습 진행 메서드
  // =================

  /// 개념 학습 완료 처리
  static Future<void> markConceptAsLearned(String conceptCode) async {
    await _isar.writeTxn(() async {
      final concept = await getConceptByCode(conceptCode);
      if (concept != null) {
        concept.markAsLearned();
        await _isar.concepts.put(concept);
      }
    });
  }

  /// 개념 복습 완료 처리
  static Future<void> completeConceptReview(String conceptCode, bool wasSuccessful) async {
    await _isar.writeTxn(() async {
      final concept = await getConceptByCode(conceptCode);
      if (concept != null) {
        concept.completeReview(wasSuccessful);
        await _isar.concepts.put(concept);
      }
    });
  }

  // =================
  // AI 설명 생성 메서드
  // =================

  /// AI 개념 설명 생성
  static Future<String?> generateAIExplanation(String conceptCode) async {
    try {
      final concept = await getConceptByCode(conceptCode);
      if (concept == null) return null;

      // GPT-5 Standard를 통한 개념 설명 생성
      final prompt = _buildExplanationPrompt(concept);
      final explanation = await ApiService.generateConceptExplanation(prompt);

      if (explanation != null) {
        // AI 설명 저장
        await _isar.writeTxn(() async {
          concept.updateAIExplanation(explanation);
          await _isar.concepts.put(concept);
        });
      }

      return explanation;
    } catch (e) {
      print('AI 설명 생성 오류: $e');
      return null;
    }
  }

  /// 설명 생성 프롬프트 구성
  static String _buildExplanationPrompt(Concept concept) {
    return '''
의료/간호학 개념에 대한 학습자 맞춤형 설명을 생성해주세요.

개념 정보:
- 개념명: ${concept.conceptName}
- 과목: ${concept.subjectCode}
- 카테고리: ${concept.category}
- 난이도: ${concept.difficulty}
- 기본 설명: ${concept.description}
- 키워드: ${concept.keywords.join(', ')}

요구사항:
1. 의료/간호학과 학생 수준에 맞는 쉽고 명확한 설명
2. 실제 임상 사례나 예시 포함
3. 핵심 포인트를 5개 이하로 정리
4. 암기해야 할 중요 내용 강조
5. 관련 개념과의 연결점 설명
6. 500자 이내로 간결하게 작성

형식:
📚 **${concept.conceptName}**

🔍 **핵심 설명:**
[명확하고 이해하기 쉬운 설명]

💡 **핵심 포인트:**
• [포인트 1]
• [포인트 2]
• [포인트 3]

🏥 **임상 예시:**
[실제 사례나 예시]

🔗 **연관 개념:**
[관련된 다른 개념들과의 관계]
''';
  }

  // =================
  // 통계 및 분석 메서드
  // =================

  /// 개념 학습 통계
  static Future<ConceptLearningStats> getConceptStats(String subjectCode) async {
    final concepts = await getConceptsBySubject(subjectCode);
    final learned = concepts.where((c) => c.isLearned).length;
    final available = concepts.where((c) => !c.isLearned && c.isReadyToLearn(concepts)).length;
    final needsReview = concepts.where((c) => c.shouldReview).length;

    return ConceptLearningStats(
      totalConcepts: concepts.length,
      learnedConcepts: learned,
      availableConcepts: available,
      reviewNeeded: needsReview,
      progressRate: concepts.isEmpty ? 0.0 : learned / concepts.length,
    );
  }

  /// 학습 경로 추천 (다음에 학습할 개념들)
  static Future<List<Concept>> getRecommendedLearningPath(String subjectCode, {int limit = 5}) async {
    final availableConcepts = await getAvailableConcepts(subjectCode);
    
    // 중요도와 학습 순서를 고려한 정렬
    availableConcepts.sort((a, b) {
      final importanceCompare = b.importance.compareTo(a.importance);
      if (importanceCompare != 0) return importanceCompare;
      return a.learningOrder.compareTo(b.learningOrder);
    });
    
    return availableConcepts.take(limit).toList();
  }

  /// 약점 개념 분석 (복습 횟수가 많은 개념들)
  static Future<List<Concept>> getWeakConcepts(String subjectCode) async {
    final concepts = await getConceptsBySubject(subjectCode);
    
    // 복습이 자주 필요했던 개념들 (실제로는 복습 이력을 추적해야 하지만, 현재는 단순화)
    return concepts.where((c) => c.needsReview && c.isLearned).toList();
  }
}

/// 개념 학습 통계 클래스
class ConceptLearningStats {
  final int totalConcepts;
  final int learnedConcepts;
  final int availableConcepts;
  final int reviewNeeded;
  final double progressRate;

  ConceptLearningStats({
    required this.totalConcepts,
    required this.learnedConcepts,
    required this.availableConcepts,
    required this.reviewNeeded,
    required this.progressRate,
  });
}