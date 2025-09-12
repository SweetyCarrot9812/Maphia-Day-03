import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/srs_card.dart';
import '../core/constants/app_constants.dart';
import 'srs_engine.dart';

class SRSService {
  final Dio _dio;
  
  SRSService(this._dio);

  // ===============================
  // 로컬 저장소 메서드
  // ===============================
  
  /// 로컬에 SRS 카드들 저장
  Future<void> _saveCardsToLocal(List<SRSCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = cards.map((card) => card.toJson()).toList();
    await prefs.setString('srs_cards', jsonEncode(cardsJson));
  }

  /// 로컬에서 SRS 카드들 로드
  Future<List<SRSCard>> _loadCardsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsJsonString = prefs.getString('srs_cards');
      
      if (cardsJsonString == null) return [];
      
      final List<dynamic> cardsJson = jsonDecode(cardsJsonString);
      return cardsJson.map((json) => SRSCard.fromJson(json)).toList();
    } catch (e) {
      print('로컬 SRS 카드 로드 실패: $e');
      return [];
    }
  }

  /// 로컬에 리뷰 로그들 저장
  Future<void> _saveReviewLogsToLocal(List<ReviewLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = logs.map((log) => log.toJson()).toList();
    await prefs.setString('srs_review_logs', jsonEncode(logsJson));
  }

  /// 로컬에서 리뷰 로그들 로드
  Future<List<ReviewLog>> _loadReviewLogsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJsonString = prefs.getString('srs_review_logs');
      
      if (logsJsonString == null) return [];
      
      final List<dynamic> logsJson = jsonDecode(logsJsonString);
      return logsJson.map((json) => ReviewLog.fromJson(json)).toList();
    } catch (e) {
      print('로컬 리뷰 로그 로드 실패: $e');
      return [];
    }
  }

  // ===============================
  // SRS 카드 관리
  // ===============================

  /// 새 SRS 카드 생성
  Future<SRSCard> createCard({
    required String userId,
    required String itemType,
    required String itemId,
    double initialDifficulty = 0.5,
  }) async {
    try {
      // 기존 카드 확인
      final existingCards = await _loadCardsFromLocal();
      final existingCard = existingCards.firstWhere(
        (card) => card.userId == userId && card.itemId == itemId,
        orElse: () => throw StateError('No existing card found'),
      );
      
      // 이미 존재하면 기존 카드 반환
      return existingCard;
    } catch (e) {
      // 존재하지 않으면 새로 생성
      final newCard = SRSEngine.createCard(
        userId: userId,
        itemType: itemType,
        itemId: itemId,
        initialDifficulty: initialDifficulty,
      );

      // 로컬에 저장
      final cards = await _loadCardsFromLocal();
      cards.add(newCard);
      await _saveCardsToLocal(cards);

      print('새 SRS 카드 생성: ${newCard.itemId} (${itemType})');
      return newCard;
    }
  }

  /// 카드 복습 처리
  Future<ReviewResult> reviewCard({
    required String cardId,
    required String userId,
    required String userResponse,
    int responseTimeMs = 5000,
    double confidence = 0.7,
  }) async {
    final cards = await _loadCardsFromLocal();
    final cardIndex = cards.indexWhere((card) => card.cardId == cardId && card.userId == userId);
    
    if (cardIndex == -1) {
      throw Exception('카드를 찾을 수 없습니다: $cardId');
    }

    final card = cards[cardIndex];
    
    // SRS 엔진으로 복습 처리
    final result = SRSEngine.reviewCard(
      card: card,
      userResponse: userResponse,
      responseTimeMs: responseTimeMs,
      confidence: confidence,
    );

    // 업데이트된 카드로 교체
    cards[cardIndex] = result.updatedCard;
    await _saveCardsToLocal(cards);

    // 리뷰 로그 저장
    final reviewLogs = await _loadReviewLogsFromLocal();
    reviewLogs.add(result.reviewLog);
    await _saveReviewLogsToLocal(reviewLogs);

    print('SRS 복습 완료: ${card.itemId} (${result.classification}) → ${result.nextReviewInMinutes}분 후');
    
    return result;
  }

  /// 오늘 복습할 카드 목록 조회
  Future<List<SRSCard>> getTodayReviewCards({
    required String userId,
    int limit = 20,
  }) async {
    final allCards = await _loadCardsFromLocal();
    final userCards = allCards.where((card) => card.userId == userId).toList();
    
    // 오늘 복습 대상 카드들 필터링
    final dueCards = SRSEngine.getTodayDueCards(userCards);
    
    // 우선순위로 정렬
    final sortedCards = SRSEngine.sortCardsByPriority(dueCards);
    
    // 제한 수만큼 반환
    final limitedCards = sortedCards.take(limit).toList();
    
    print('오늘 복습 카드: ${limitedCards.length}장 (사용자: $userId)');
    return limitedCards;
  }

  /// 특정 카드 조회
  Future<SRSCard?> getCard({
    required String cardId,
    required String userId,
  }) async {
    final cards = await _loadCardsFromLocal();
    
    try {
      return cards.firstWhere(
        (card) => card.cardId == cardId && card.userId == userId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 카드 삭제
  Future<bool> deleteCard({
    required String cardId,
    required String userId,
  }) async {
    final cards = await _loadCardsFromLocal();
    final cardIndex = cards.indexWhere((card) => card.cardId == cardId && card.userId == userId);
    
    if (cardIndex == -1) return false;
    
    cards.removeAt(cardIndex);
    await _saveCardsToLocal(cards);

    // 관련 리뷰 로그도 삭제
    final reviewLogs = await _loadReviewLogsFromLocal();
    reviewLogs.removeWhere((log) => log.cardId == cardId && log.userId == userId);
    await _saveReviewLogsToLocal(reviewLogs);

    print('SRS 카드 삭제: $cardId');
    return true;
  }

  /// 사용자 SRS 통계
  Future<SRSStats> getUserStats(String userId) async {
    final allCards = await _loadCardsFromLocal();
    final userCards = allCards.where((card) => card.userId == userId).toList();
    
    final stats = SRSEngine.calculateStats(userCards);
    
    print('SRS 통계 조회: ${stats.totalCards}장 (사용자: $userId)');
    return stats;
  }

  /// 복습 이력 조회
  Future<List<ReviewLog>> getReviewHistory({
    required String userId,
    String? cardId,
    int limit = 50,
  }) async {
    final reviewLogs = await _loadReviewLogsFromLocal();
    
    var filteredLogs = reviewLogs.where((log) => log.userId == userId);
    
    if (cardId != null) {
      filteredLogs = filteredLogs.where((log) => log.cardId == cardId);
    }
    
    // 최신순 정렬 후 제한
    final sortedLogs = filteredLogs.toList();
    sortedLogs.sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt));
    
    return sortedLogs.take(limit).toList();
  }

  // ===============================
  // 백엔드 연동 메서드 (선택적 구현)
  // ===============================

  /// 백엔드에 SRS 카드 동기화 (선택적)
  Future<void> syncToBackend({
    required String userId,
  }) async {
    try {
      final cards = await _loadCardsFromLocal();
      final userCards = cards.where((card) => card.userId == userId).toList();
      
      // 백엔드 API 호출 (구현 예정)
      // await _dio.post('${AppConstants.srsEndpoint}/sync', data: {
      //   'userId': userId,
      //   'cards': userCards.map((card) => card.toJson()).toList(),
      // });
      
      print('SRS 데이터 동기화 완료 (${userCards.length}장)');
    } catch (e) {
      print('SRS 동기화 실패: $e');
      rethrow;
    }
  }

  /// 백엔드에서 SRS 카드 불러오기 (선택적)
  Future<void> syncFromBackend({
    required String userId,
  }) async {
    try {
      // 백엔드 API 호출 (구현 예정)
      // final response = await _dio.get('${AppConstants.srsEndpoint}/cards/$userId');
      // final List<dynamic> cardsJson = response.data['cards'];
      // final backendCards = cardsJson.map((json) => SRSCard.fromJson(json)).toList();
      
      // // 로컬 카드와 병합
      // final localCards = await _loadCardsFromLocal();
      // // 병합 로직 구현...
      // await _saveCardsToLocal(mergedCards);
      
      print('백엔드에서 SRS 데이터 동기화 완료');
    } catch (e) {
      print('백엔드 동기화 실패: $e');
      // 실패해도 로컬 데이터로 계속 작업
    }
  }
}

// ===============================
// Riverpod 프로바이더
// ===============================

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final srsServiceProvider = Provider<SRSService>((ref) {
  final dio = ref.read(dioProvider);
  return SRSService(dio);
});

// SRS 카드 상태 관리
final srsCardsProvider = StateNotifierProvider<SRSCardsNotifier, List<SRSCard>>((ref) {
  final srsService = ref.read(srsServiceProvider);
  return SRSCardsNotifier(srsService);
});

// SRS 통계 프로바이더
final srsStatsProvider = FutureProvider.family<SRSStats, String>((ref, userId) async {
  final srsService = ref.read(srsServiceProvider);
  return await srsService.getUserStats(userId);
});

// 오늘 복습 카드 프로바이더  
final todayReviewCardsProvider = FutureProvider.family<List<SRSCard>, String>((ref, userId) async {
  final srsService = ref.read(srsServiceProvider);
  return await srsService.getTodayReviewCards(userId: userId);
});

/// SRS 카드 상태 관리자
class SRSCardsNotifier extends StateNotifier<List<SRSCard>> {
  final SRSService _srsService;
  
  SRSCardsNotifier(this._srsService) : super([]);

  /// 사용자의 모든 카드 로드
  Future<void> loadUserCards(String userId) async {
    final cards = await _srsService._loadCardsFromLocal();
    final userCards = cards.where((card) => card.userId == userId).toList();
    state = userCards;
  }

  /// 새 카드 추가
  Future<SRSCard> addCard({
    required String userId,
    required String itemType,
    required String itemId,
    double initialDifficulty = 0.5,
  }) async {
    final newCard = await _srsService.createCard(
      userId: userId,
      itemType: itemType,
      itemId: itemId,
      initialDifficulty: initialDifficulty,
    );
    
    state = [...state, newCard];
    return newCard;
  }

  /// 카드 복습 처리
  Future<ReviewResult> reviewCard({
    required String cardId,
    required String userId,
    required String userResponse,
    int responseTimeMs = 5000,
    double confidence = 0.7,
  }) async {
    final result = await _srsService.reviewCard(
      cardId: cardId,
      userId: userId,
      userResponse: userResponse,
      responseTimeMs: responseTimeMs,
      confidence: confidence,
    );
    
    // 상태 업데이트
    state = state.map((card) {
      if (card.cardId == cardId) {
        return result.updatedCard;
      }
      return card;
    }).toList();
    
    return result;
  }

  /// 카드 삭제
  Future<bool> deleteCard(String cardId, String userId) async {
    final success = await _srsService.deleteCard(cardId: cardId, userId: userId);
    
    if (success) {
      state = state.where((card) => card.cardId != cardId).toList();
    }
    
    return success;
  }
}