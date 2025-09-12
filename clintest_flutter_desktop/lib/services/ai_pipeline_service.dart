import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/models/question_data.dart';
import '../shared/models/ai_models.dart';

/// Clintest GPT AI 파이프라인 v3.1
/// 난이도 분기 + 문제 유형 확장 + text-embedding-004 + 실시간 동기화
class AiPipelineService {
  final Dio _dio;
  late final AiModelRouter _router;
  late final QualityGateService _qualityGate;
  late final EmbeddingService _embedding;

  AiPipelineService(this._dio) {
    _router = AiModelRouter(_dio);
    _qualityGate = QualityGateService();
    _embedding = EmbeddingService(_dio);
  }

  /// 개념에서 자동 문제 생성
  Future<GenerationResult> generateFromConcept({
    required String conceptText,
    required String subject,
    required String difficulty, // 'HIGH', 'MID', 'LOW'
    int questionCount = 5,
    List<String> questionTypes = const ['MCQ'], // MCQ, Simulation, Image-based, Essay
    bool includeImages = false,
  }) async {
    try {
      // 1. 계획 수립 (항상 GPT-5 Standard)
      final plan = await _router.planQuestionGeneration(
        conceptText: conceptText,
        subject: subject,
        difficulty: difficulty,
        questionCount: questionCount,
        questionTypes: questionTypes,
      );

      // 2. 문제 생성 (난이도 기반 분기)
      List<QuestionCandidate> candidates = [];
      
      if (difficulty == 'HIGH') {
        // HIGH: GPT-5 Standard 직접 생성
        candidates = await _router.generateWithStandard(plan);
      } else {
        // MID/LOW: GPT-5 Mini 대량 생성
        candidates = await _router.generateWithMini(plan);
      }

      // 3. 이미지 문항 처리 (필요시)
      if (includeImages) {
        final imageCandidates = await _router.generateImageBasedQuestions(plan);
        candidates.addAll(imageCandidates);
      }

      // 4. Gate-OUT: 품질 게이트 통과
      final validQuestions = <QuestionData>[];
      final blockedQuestions = <BlockedQuestion>[];

      for (final candidate in candidates) {
        final gateResult = await _qualityGate.processGateOut(candidate);
        
        if (gateResult.passed) {
          validQuestions.add(gateResult.question!);
        } else {
          blockedQuestions.add(BlockedQuestion(
            candidate: candidate,
            reason: gateResult.blockReason!,
            duplicateIds: gateResult.duplicateIds,
          ));
        }
      }

      // 5. 세트 다양성 보장 (MMR)
      final diverseQuestions = _qualityGate.applyMMR(
        validQuestions, 
        alpha: 0.75,
        targetCount: questionCount,
      );

      return GenerationResult(
        questions: diverseQuestions,
        blocked: blockedQuestions,
        planUsed: plan,
        totalGenerated: candidates.length,
        qualityScore: _calculateQualityScore(diverseQuestions),
      );

    } catch (e) {
      throw AiPipelineException('Generation failed: $e');
    }
  }

  /// 수동 문제 입력 시 Gate-IN 처리
  Future<GateResult> processManualQuestion(QuestionData question) async {
    return await _qualityGate.processGateIn(QuestionCandidate(
      stem: question.stem,
      choices: question.choices,
      correctAnswer: question.correctAnswer,
      explanation: question.explanation,
      subject: question.subject,
      difficulty: question.difficulty,
      imagePaths: question.imagePaths,
      source: 'manual',
    ));
  }

  /// 품질 점수 계산
  double _calculateQualityScore(List<QuestionData> questions) {
    if (questions.isEmpty) return 0.0;
    
    double avgDiversity = 0.0;
    int pairCount = 0;
    
    for (int i = 0; i < questions.length; i++) {
      for (int j = i + 1; j < questions.length; j++) {
        // 문항 간 유사도 계산 (간단한 휴리스틱)
        final similarity = _calculateSimilarity(questions[i], questions[j]);
        avgDiversity += (1.0 - similarity);
        pairCount++;
      }
    }
    
    return pairCount > 0 ? avgDiversity / pairCount : 1.0;
  }

  /// 문항 간 유사도 계산
  double _calculateSimilarity(QuestionData q1, QuestionData q2) {
    // 간단한 텍스트 유사도 (실제로는 임베딩 기반)
    final words1 = q1.stem.toLowerCase().split(' ').toSet();
    final words2 = q2.stem.toLowerCase().split(' ').toSet();
    
    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;
    
    return union > 0 ? intersection / union : 0.0;
  }
}

/// AI 모델 라우터
class AiModelRouter {
  final Dio _dio;
  
  AiModelRouter(this._dio);

  Future<GenerationPlan> planQuestionGeneration({
    required String conceptText,
    required String subject,
    required String difficulty,
    required int questionCount,
    required List<String> questionTypes,
  }) async {
    // GPT-5 Standard로 계획 수립
    final response = await _dio.post(
      '/api/ai/plan',
      data: {
        'model': 'gpt-5-standard',
        'concept': conceptText,
        'subject': subject,
        'difficulty': difficulty,
        'questionCount': questionCount,
        'questionTypes': questionTypes,
      },
    );

    return GenerationPlan.fromJson(response.data);
  }

  Future<List<QuestionCandidate>> generateWithStandard(GenerationPlan plan) async {
    final response = await _dio.post(
      '/api/ai/generate',
      data: {
        'model': 'gpt-5-standard',
        'plan': plan.toJson(),
      },
    );

    return (response.data['questions'] as List)
        .map((json) => QuestionCandidate.fromJson(json))
        .toList();
  }

  Future<List<QuestionCandidate>> generateWithMini(GenerationPlan plan) async {
    final response = await _dio.post(
      '/api/ai/generate',
      data: {
        'model': 'gpt-5-mini',
        'plan': plan.toJson(),
      },
    );

    return (response.data['questions'] as List)
        .map((json) => QuestionCandidate.fromJson(json))
        .toList();
  }

  Future<List<QuestionCandidate>> generateImageBasedQuestions(GenerationPlan plan) async {
    // Gemini 2.5 Flash Image로 시각자료 생성
    final response = await _dio.post(
      '/api/ai/generate-image',
      data: {
        'model': 'gemini-2.5-flash-image',
        'plan': plan.toJson(),
      },
    );

    return (response.data['questions'] as List)
        .map((json) => QuestionCandidate.fromJson(json))
        .toList();
  }
}

/// 품질 게이트 서비스
class QualityGateService {
  static const _thresholds = QualityThresholds.balanced();

  /// Gate-IN 처리 (수동 입력)
  Future<GateResult> processGateIn(QuestionCandidate candidate) async {
    return await _processGate(candidate, isGateOut: false);
  }

  /// Gate-OUT 처리 (AI 생성)
  Future<GateResult> processGateOut(QuestionCandidate candidate) async {
    return await _processGate(candidate, isGateOut: true);
  }

  Future<GateResult> _processGate(QuestionCandidate candidate, {required bool isGateOut}) async {
    try {
      // 1. 정규화
      final normalized = normalizeQuestion(candidate.stem, candidate.choices);
      
      // 2. 해시 생성
      final hash = _generateHash(normalized.normalizedAll);
      
      // 3. 임베딩 생성
      final embedding = await _generateEmbedding(normalized.normalizedAll);
      
      // 4. 벡터 검색
      final duplicates = await _vectorSearch(embedding);
      
      // 5. 중복 검사
      final duplicateCheck = _checkDuplicates(normalized, duplicates);
      
      if (duplicateCheck.isDuplicate) {
        return GateResult(
          passed: false,
          blockReason: duplicateCheck.reason,
          duplicateIds: duplicateCheck.duplicateIds,
        );
      }

      // 6. 통과한 경우 QuestionData 생성
      final question = QuestionData(
        id: _generateId(),
        subject: candidate.subject,
        stem: candidate.stem,
        choices: candidate.choices,
        correctAnswer: candidate.correctAnswer,
        explanation: candidate.explanation,
        difficulty: candidate.difficulty,
        imagePaths: [], // 기본값: 빈 목록
        source: candidate.source,
        hash: hash,
        embedding: embedding,
        createdAt: DateTime.now(),
      );

      return GateResult(
        passed: true,
        question: question,
      );

    } catch (e) {
      return GateResult(
        passed: false,
        blockReason: 'Processing error: $e',
      );
    }
  }

  /// MMR 다양성 보장
  List<QuestionData> applyMMR(List<QuestionData> questions, {
    required double alpha,
    required int targetCount,
  }) {
    if (questions.length <= targetCount) return questions;

    final selected = <QuestionData>[];
    final remaining = List<QuestionData>.from(questions);

    // 첫 번째 문항 선택 (임베딩 크기 기준)
    remaining.sort((a, b) => b.embedding.length.compareTo(a.embedding.length));
    selected.add(remaining.removeAt(0));

    // MMR 알고리즘으로 나머지 선택
    while (selected.length < targetCount && remaining.isNotEmpty) {
      double bestScore = -1;
      int bestIndex = -1;

      for (int i = 0; i < remaining.length; i++) {
        final candidate = remaining[i];
        
        // 다양성 점수 계산
        double maxSimilarity = 0;
        for (final selected_q in selected) {
          final similarity = _cosineSimilarity(candidate.embedding, selected_q.embedding);
          maxSimilarity = max(maxSimilarity, similarity);
        }

        // MMR 점수 = α * 관련성 + (1-α) * 다양성
        final mmrScore = alpha * 0.5 + (1 - alpha) * (1 - maxSimilarity);

        if (mmrScore > bestScore) {
          bestScore = mmrScore;
          bestIndex = i;
        }
      }

      if (bestIndex >= 0) {
        selected.add(remaining.removeAt(bestIndex));
      } else {
        break;
      }
    }

    return selected;
  }

  /// 문항 정규화
  NormalizedQuestion normalizeQuestion(String stem, List<String> choices) {
    // 정규화 로직 (공백, 특수문자, 대소문자 처리)
    String normalize(String text) {
      return text
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\sㄱ-ㅎㅏ-ㅣ가-힣]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }

    final normStem = normalize(stem);
    final normChoices = choices.map(normalize).toList();
    final normalizedAll = '$normStem ${normChoices.join(' ')}';

    return NormalizedQuestion(
      normalizedAll: normalizedAll,
      normStem: normStem,
      normChoices: normChoices,
    );
  }

  String _generateHash(String text) {
    return sha256.convert(utf8.encode(text)).toString();
  }

  Future<List<double>> _generateEmbedding(String text) async {
    // Google text-embedding-004 API 호출
    // 실제 구현에서는 API 키와 함께 호출
    return List.generate(3072, (index) => Random().nextDouble());
  }

  Future<List<VectorSearchResult>> _vectorSearch(List<double> embedding) async {
    // 벡터 검색 구현 (Qdrant/Pinecone)
    return [];
  }

  DuplicateCheckResult _checkDuplicates(NormalizedQuestion normalized, List<VectorSearchResult> duplicates) {
    if (duplicates.isEmpty) {
      return DuplicateCheckResult(isDuplicate: false);
    }

    // 임계값 기반 중복 검사
    for (final duplicate in duplicates) {
      if (duplicate.similarity >= _thresholds.allThreshold) {
        return DuplicateCheckResult(
          isDuplicate: true,
          reason: 'DUP_EXACT',
          duplicateIds: [duplicate.id],
        );
      }
    }

    return DuplicateCheckResult(isDuplicate: false);
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString().padLeft(3, '0');
  }
}

/// 임베딩 서비스
class EmbeddingService {
  final Dio _dio;
  
  EmbeddingService(this._dio);

  Future<List<double>> generateEmbedding(String text) async {
    // Google text-embedding-004 API
    final response = await _dio.post(
      '/api/embedding/generate',
      data: {
        'model': 'text-embedding-004',
        'text': text,
      },
    );

    return List<double>.from(response.data['embedding']);
  }
}

// === Models ===

class GenerationResult {
  final List<QuestionData> questions;
  final List<BlockedQuestion> blocked;
  final GenerationPlan planUsed;
  final int totalGenerated;
  final double qualityScore;

  GenerationResult({
    required this.questions,
    required this.blocked,
    required this.planUsed,
    required this.totalGenerated,
    required this.qualityScore,
  });
}

class BlockedQuestion {
  final QuestionCandidate candidate;
  final String reason;
  final List<String>? duplicateIds;

  BlockedQuestion({
    required this.candidate,
    required this.reason,
    this.duplicateIds,
  });
}

class GenerationPlan {
  final String subject;
  final String difficulty;
  final int questionCount;
  final List<String> questionTypes;
  final Map<String, dynamic> metadata;

  GenerationPlan({
    required this.subject,
    required this.difficulty,
    required this.questionCount,
    required this.questionTypes,
    required this.metadata,
  });

  factory GenerationPlan.fromJson(Map<String, dynamic> json) {
    return GenerationPlan(
      subject: json['subject'],
      difficulty: json['difficulty'],
      questionCount: json['questionCount'],
      questionTypes: List<String>.from(json['questionTypes']),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'difficulty': difficulty,
    'questionCount': questionCount,
    'questionTypes': questionTypes,
    'metadata': metadata,
  };
}

class QuestionCandidate {
  final String stem;
  final List<String> choices;
  final String correctAnswer;
  final String? explanation;
  final String subject;
  final String difficulty;
  final List<String> imagePaths;
  final String source;

  QuestionCandidate({
    required this.stem,
    required this.choices,
    required this.correctAnswer,
    this.explanation,
    required this.subject,
    required this.difficulty,
    this.imagePaths = const [],
    required this.source,
  });

  factory QuestionCandidate.fromJson(Map<String, dynamic> json) {
    return QuestionCandidate(
      stem: json['stem'],
      choices: List<String>.from(json['choices']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
      subject: json['subject'],
      difficulty: json['difficulty'],
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      source: json['source'] ?? 'generated',
    );
  }
}

class GateResult {
  final bool passed;
  final QuestionData? question;
  final String? blockReason;
  final List<String>? duplicateIds;

  GateResult({
    required this.passed,
    this.question,
    this.blockReason,
    this.duplicateIds,
  });
}

class NormalizedQuestion {
  final String normalizedAll;
  final String normStem;
  final List<String> normChoices;

  NormalizedQuestion({
    required this.normalizedAll,
    required this.normStem,
    required this.normChoices,
  });
}

class VectorSearchResult {
  final String id;
  final double similarity;
  final Map<String, dynamic> metadata;

  VectorSearchResult({
    required this.id,
    required this.similarity,
    required this.metadata,
  });
}

class DuplicateCheckResult {
  final bool isDuplicate;
  final String? reason;
  final List<String>? duplicateIds;

  DuplicateCheckResult({
    required this.isDuplicate,
    this.reason,
    this.duplicateIds,
  });
}

class QualityThresholds {
  final double allThreshold;
  final double optionAvgThreshold;
  final double optionMaxThreshold;

  const QualityThresholds({
    required this.allThreshold,
    required this.optionAvgThreshold,
    required this.optionMaxThreshold,
  });

  const QualityThresholds.strict() : this(
    allThreshold: 0.88,
    optionAvgThreshold: 0.90,
    optionMaxThreshold: 0.94,
  );

  const QualityThresholds.balanced() : this(
    allThreshold: 0.86,
    optionAvgThreshold: 0.88,
    optionMaxThreshold: 0.92,
  );

  const QualityThresholds.relaxed() : this(
    allThreshold: 0.84,
    optionAvgThreshold: 0.86,
    optionMaxThreshold: 0.90,
  );
}

class AiPipelineException implements Exception {
  final String message;
  AiPipelineException(this.message);
  
  @override
  String toString() => 'AiPipelineException: $message';
}

// === Riverpod Providers ===

final aiPipelineServiceProvider = Provider<AiPipelineService>((ref) {
  return AiPipelineService(Dio());
});