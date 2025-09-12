import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class SRSCard {
  final String cardId;
  final String userId;
  final String itemType;
  final String itemId;
  final int interval;
  final double easeFactor;
  final DateTime dueDate;
  final int totalReviews;
  final int consecutiveCorrect;
  final double aiDifficultyScore;
  final String? lastPerformance;
  final DateTime createdAt;
  final DateTime updatedAt;

  SRSCard({
    required this.cardId,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.interval,
    required this.easeFactor,
    required this.dueDate,
    required this.totalReviews,
    required this.consecutiveCorrect,
    required this.aiDifficultyScore,
    this.lastPerformance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SRSCard.fromJson(Map<String, dynamic> json) {
    return SRSCard(
      cardId: json['cardId'] ?? '',
      userId: json['userId'] ?? '',
      itemType: json['itemType'] ?? '',
      itemId: json['itemId'] ?? '',
      interval: json['interval'] ?? 0,
      easeFactor: (json['easeFactor'] ?? 0.0).toDouble(),
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
      totalReviews: json['totalReviews'] ?? 0,
      consecutiveCorrect: json['consecutiveCorrect'] ?? 0,
      aiDifficultyScore: (json['aiDifficultyScore'] ?? 0.0).toDouble(),
      lastPerformance: json['lastPerformance'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ReviewResult {
  final String userResponse;
  final String internalClassification;
  final DateTime nextDueDate;
  final int newInterval;
  final bool isCorrect;

  ReviewResult({
    required this.userResponse,
    required this.internalClassification,
    required this.nextDueDate,
    required this.newInterval,
    required this.isCorrect,
  });

  factory ReviewResult.fromJson(Map<String, dynamic> json) {
    return ReviewResult(
      userResponse: json['userResponse'] ?? '',
      internalClassification: json['internalClassification'] ?? '',
      nextDueDate: DateTime.tryParse(json['nextDueDate'] ?? '') ?? DateTime.now(),
      newInterval: json['newInterval'] ?? 0,
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}

class SRSService {
  static const String baseUrl = 'http://localhost:3001';
  
  // 싱글톤 패턴
  static final SRSService _instance = SRSService._internal();
  factory SRSService() => _instance;
  SRSService._internal();

  // 헤더 생성
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // SRS 카드 생성 (문제를 틀렸을 때 자동으로 호출)
  Future<SRSCard?> createCard({
    required String itemType,
    required String itemId,
    double initialDifficulty = 0.5,
  }) async {
    try {
      final userId = StorageService.userId;
      if (userId == null) {
        print('SRS: 로그인된 사용자 없음');
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/srs/cards'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'itemType': itemType,
          'itemId': itemId,
          'initialDifficulty': initialDifficulty,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('SRS: 카드 생성 성공 - ${data['cardId']}');
          return SRSCard.fromJson(data['card']);
        }
      } else {
        print('SRS: 카드 생성 실패 - ${response.statusCode}: ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('SRS: 카드 생성 오류 - $e');
      return null;
    }
  }

  // SRS 리뷰 처리 (문제를 풀었을 때 자동으로 호출)
  Future<ReviewResult?> reviewCard({
    required String cardId,
    required String userResponse, // 'again' 또는 'good'
    int responseTimeMs = 5000,
  }) async {
    try {
      final userId = StorageService.userId;
      if (userId == null) {
        print('SRS: 로그인된 사용자 없음');
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/srs/review'),
        headers: _headers,
        body: jsonEncode({
          'cardId': cardId,
          'userId': userId,
          'userResponse': userResponse,
          'responseTimeMs': responseTimeMs,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('SRS: 리뷰 처리 성공 - ${data['reviewResult']['internalClassification']}');
          return ReviewResult.fromJson(data['reviewResult']);
        }
      } else {
        print('SRS: 리뷰 처리 실패 - ${response.statusCode}: ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('SRS: 리뷰 처리 오류 - $e');
      return null;
    }
  }

  // 기존 카드 확인 (중복 생성 방지)
  Future<SRSCard?> findExistingCard(String itemId) async {
    try {
      final userId = StorageService.userId;
      if (userId == null) return null;

      // 사용자의 모든 카드를 가져와서 itemId로 필터링
      final todayCards = await getTodayReviewCards();
      if (todayCards != null) {
        for (var card in todayCards) {
          if (card.itemId == itemId) {
            return card;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('SRS: 기존 카드 확인 오류 - $e');
      return null;
    }
  }

  // 오늘 복습할 카드 목록 (향후 복습 기능용)
  Future<List<SRSCard>?> getTodayReviewCards({int limit = 50}) async {
    try {
      final userId = StorageService.userId;
      if (userId == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/srs/today/$userId?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['cards'] != null) {
          List<SRSCard> cards = [];
          for (var cardJson in data['cards']) {
            try {
              cards.add(SRSCard.fromJson(cardJson));
            } catch (e) {
              print('SRS: 카드 파싱 오류 - $e');
            }
          }
          return cards;
        }
      }
      
      return null;
    } catch (e) {
      print('SRS: 오늘 복습 카드 조회 오류 - $e');
      return null;
    }
  }

  // 사용자 SRS 통계
  Future<Map<String, dynamic>?> getUserStats() async {
    try {
      final userId = StorageService.userId;
      if (userId == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/srs/stats/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['stats'];
        }
      }
      
      return null;
    } catch (e) {
      print('SRS: 통계 조회 오류 - $e');
      return null;
    }
  }

  // 자동 SRS 처리 (문제풀이 완료 시 호출)
  Future<void> processQuestionResult({
    required String questionId,
    required bool isCorrect,
    int responseTimeMs = 5000,
  }) async {
    try {
      // 1. 기존 카드가 있는지 확인
      SRSCard? existingCard = await findExistingCard(questionId);
      
      if (existingCard != null) {
        // 2. 기존 카드가 있으면 리뷰 처리
        final userResponse = isCorrect ? 'good' : 'again';
        await reviewCard(
          cardId: existingCard.cardId,
          userResponse: userResponse,
          responseTimeMs: responseTimeMs,
        );
      } else if (!isCorrect) {
        // 3. 틀린 문제이고 기존 카드가 없으면 새 카드 생성
        await createCard(
          itemType: 'problem',
          itemId: questionId,
          initialDifficulty: 0.5, // 기본 난이도
        );
        
        print('SRS: 틀린 문제 복습 카드 생성 - $questionId');
      }
      
      // 정답인 경우이고 기존 카드가 없으면 아무것도 하지 않음
      // (정답인 문제는 굳이 SRS에 추가할 필요 없음)
      
    } catch (e) {
      print('SRS: 자동 처리 오류 - $e');
    }
  }
}