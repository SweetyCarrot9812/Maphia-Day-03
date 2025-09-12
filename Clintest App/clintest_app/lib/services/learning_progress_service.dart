import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class LearningProgressService {
  static const String _baseUrl = 'https://clintest-fpj6bvy4g-tkandpf26-9808s-projects.vercel.app/api';
  
  // 학습 진도 현황 가져오기
  static Future<Map<String, dynamic>?> getLearningProgress(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mastery/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.getString('auth_token')}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('학습 진도 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('학습 진도 API 오류: $e');
      return null;
    }
  }

  // SRS 학습 통계 가져오기
  static Future<Map<String, dynamic>?> getSRSStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/srs/stats/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.getString('auth_token')}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('SRS 통계 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('SRS 통계 API 오류: $e');
      return null;
    }
  }

  // 오늘의 학습 카드 가져오기
  static Future<Map<String, dynamic>?> getTodayCards(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/srs/today/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.getString('auth_token')}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('오늘의 카드 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('오늘의 카드 API 오류: $e');
      return null;
    }
  }

  // 간호사 문제 통계 가져오기
  static Future<Map<String, dynamic>?> getNursingStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/nursing/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.getString('auth_token')}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('간호사 통계 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('간호사 통계 API 오류: $e');
      return null;
    }
  }

  // Storage System 통계 가져오기
  static Future<Map<String, dynamic>?> getStorageStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/storage/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.getString('auth_token')}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Storage 통계 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Storage 통계 API 오류: $e');
      return null;
    }
  }

  // 약점/강점 과목 가져오기
  static Future<Map<String, dynamic>?> getWeakStrongSubjects(String userId) async {
    try {
      final weakResponse = await http.get(
        Uri.parse('$_baseUrl/mastery/$userId/weak'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.getString('auth_token')}',
        },
      );

      final strongResponse = await http.get(
        Uri.parse('$_baseUrl/mastery/$userId/strong'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.getString('auth_token')}',
        },
      );

      if (weakResponse.statusCode == 200 && strongResponse.statusCode == 200) {
        return {
          'weak': json.decode(weakResponse.body),
          'strong': json.decode(strongResponse.body),
        };
      } else {
        print('약점/강점 조회 실패');
        return null;
      }
    } catch (e) {
      print('약점/강점 API 오류: $e');
      return null;
    }
  }

  // 종합 대시보드 데이터 가져오기
  static Future<Map<String, dynamic>?> getDashboardData(String userId) async {
    try {
      final results = await Future.wait([
        getLearningProgress(userId),
        getSRSStats(userId),
        getTodayCards(userId),
        getNursingStats(),
        getStorageStats(),
        getWeakStrongSubjects(userId),
      ]);

      return {
        'progress': results[0],
        'srs_stats': results[1],
        'today_cards': results[2],
        'nursing_stats': results[3],
        'storage_stats': results[4],
        'weak_strong': results[5],
      };
    } catch (e) {
      print('대시보드 데이터 조회 오류: $e');
      return null;
    }
  }

  // 학습 진도율 계산
  static double calculateProgressPercentage(Map<String, dynamic>? progressData) {
    if (progressData == null) return 0.0;
    
    try {
      final masteryStats = progressData['mastery_stats'] as Map<String, dynamic>?;
      if (masteryStats == null) return 0.0;

      final masteredCount = masteryStats['mastered'] as int? ?? 0;
      final totalCount = masteryStats['total'] as int? ?? 0;

      if (totalCount == 0) return 0.0;
      return (masteredCount / totalCount) * 100;
    } catch (e) {
      print('진도율 계산 오류: $e');
      return 0.0;
    }
  }

  // 연속 학습일 계산
  static int calculateStudyStreak(Map<String, dynamic>? srsStats) {
    if (srsStats == null) return 0;
    
    try {
      return srsStats['study_streak'] as int? ?? 0;
    } catch (e) {
      print('연속 학습일 계산 오류: $e');
      return 0;
    }
  }

  // 오늘 학습할 카드 수
  static int getTodayCardCount(Map<String, dynamic>? todayCards) {
    if (todayCards == null) return 0;
    
    try {
      final cards = todayCards['cards'] as List?;
      return cards?.length ?? 0;
    } catch (e) {
      print('오늘 카드 수 계산 오류: $e');
      return 0;
    }
  }
}