import 'dart:convert';
import 'package:flutter/material.dart';

/// Server-Driven UI 서비스 - 허용된 블록만 원격 제어
class SDUIService {
  // 서버에서 가져온 UI 설정 캐시
  static Map<String, dynamic> _serverUIConfig = {};
  
  // 허용된 SDUI 블록 타입들 (보안 가드레일)
  static const Set<String> _allowedBlockTypes = {
    'card',
    'list',
    'badge',
    'tooltip',
    'banner',
    'notice',
  };
  
  /// SDUI 시스템 초기화 - 서버에서 UI 설정 가져오기
  static Future<void> initialize() async {
    try {
      await _fetchServerUIConfig();
      print('[SDUI] 서버 UI 설정 로드 완료');
    } catch (e) {
      print('[SDUI] 서버 UI 설정 로드 실패: $e');
      // 실패해도 앱은 기본 UI로 작동
    }
  }
  
  /// 서버에서 UI 설정 가져오기
  static Future<void> _fetchServerUIConfig() async {
    try {
      // TODO: 실제 서버 API 호출로 교체
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 임시 서버 응답 시뮬레이션
      _serverUIConfig = {
        'version': '2025.09',
        'home_screen': {
          'banners': [
            {
              'id': 'beta_notice',
              'type': 'banner',
              'content': 'Beta 무료 이용 중 · 정식 출시 후 서비스별 요금 적용 예정',
              'style': 'info',
              'dismissible': false,
              'position': 'top',
            }
          ],
          'cards': [
            {
              'id': 'continue_learning',
              'type': 'card',
              'title': '오늘 이어서 하기',
              'enabled': true,
              'priority': 1,
            }
          ],
          'badges': [
            {
              'id': 'beta_free',
              'type': 'badge',
              'text': 'Beta Free',
              'color': '#4CAF50',
              'text_color': '#FFFFFF',
              'show_on_modules': true,
              'enabled': true,
            }
          ]
        },
        'modules': {
          'language': {
            'tooltips': [
              {
                'id': 'preload_tip',
                'type': 'tooltip',
                'text': '이 모듈은 선로딩되어 즉시 사용 가능합니다',
                'trigger': 'long_press',
              }
            ]
          },
          'medical': {
            'tooltips': [
              {
                'id': 'lazy_load_tip',
                'type': 'tooltip',
                'text': '처음 진입 시 다운로드됩니다',
                'trigger': 'tap',
              }
            ]
          }
        },
        'notices': [
          {
            'id': 'maintenance_notice',
            'type': 'notice',
            'title': '시스템 점검 안내',
            'content': '매주 일요일 새벽 2-4시 시스템 점검이 진행됩니다.',
            'priority': 'medium',
            'show_until': '2025-12-31T23:59:59Z',
            'enabled': false,
          }
        ]
      };
    } catch (e) {
      print('[SDUI] 서버 UI 설정 로드 실패: $e');
      _serverUIConfig = {}; // 빈 설정으로 fallback
    }
  }
  
  /// 배너 목록 가져오기
  static List<SDUIBanner> getHomeBanners() {
    final banners = _serverUIConfig['home_screen']?['banners'] as List<dynamic>? ?? [];
    return banners
        .where((banner) => _isValidBlock(banner, 'banner'))
        .map((banner) => SDUIBanner.fromJson(banner))
        .toList();
  }
  
  /// 배지 설정 가져오기
  static SDUIBadge? getHomeBadge(String badgeId) {
    final badges = _serverUIConfig['home_screen']?['badges'] as List<dynamic>? ?? [];
    final badgeData = badges.firstWhere(
      (badge) => badge['id'] == badgeId && _isValidBlock(badge, 'badge'),
      orElse: () => null,
    );
    
    return badgeData != null ? SDUIBadge.fromJson(badgeData) : null;
  }
  
  /// 카드 설정 가져오기
  static List<SDUICard> getHomeCards() {
    final cards = _serverUIConfig['home_screen']?['cards'] as List<dynamic>? ?? [];
    return cards
        .where((card) => _isValidBlock(card, 'card') && card['enabled'] == true)
        .map((card) => SDUICard.fromJson(card))
        .toList();
  }
  
  /// 툴팁 가져오기
  static SDUITooltip? getModuleTooltip(String moduleId, String tooltipId) {
    final moduleConfig = _serverUIConfig['modules']?[moduleId] as Map<String, dynamic>?;
    if (moduleConfig == null) return null;
    
    final tooltips = moduleConfig['tooltips'] as List<dynamic>? ?? [];
    final tooltipData = tooltips.firstWhere(
      (tooltip) => tooltip['id'] == tooltipId && _isValidBlock(tooltip, 'tooltip'),
      orElse: () => null,
    );
    
    return tooltipData != null ? SDUITooltip.fromJson(tooltipData) : null;
  }
  
  /// 공지사항 목록 가져오기
  static List<SDUINotice> getActiveNotices() {
    final notices = _serverUIConfig['notices'] as List<dynamic>? ?? [];
    final now = DateTime.now();
    
    return notices
        .where((notice) {
          if (!_isValidBlock(notice, 'notice') || notice['enabled'] != true) {
            return false;
          }
          
          final showUntil = notice['show_until'] as String?;
          if (showUntil != null) {
            final endDate = DateTime.tryParse(showUntil);
            if (endDate != null && now.isAfter(endDate)) {
              return false;
            }
          }
          
          return true;
        })
        .map((notice) => SDUINotice.fromJson(notice))
        .toList();
  }
  
  /// 블록 유효성 검사 (보안 가드레일)
  static bool _isValidBlock(Map<String, dynamic> block, String expectedType) {
    // 1. 타입 검사
    final type = block['type'] as String?;
    if (type != expectedType || !_allowedBlockTypes.contains(type)) {
      print('[SDUI] 허용되지 않은 블록 타입: $type');
      return false;
    }
    
    // 2. 필수 필드 검사
    if (block['id'] == null) {
      print('[SDUI] 블록 ID 누락');
      return false;
    }
    
    // 3. 스크립트 삽입 방지
    final content = block['content'] as String?;
    if (content != null && _containsScript(content)) {
      print('[SDUI] 스크립트 삽입 시도 감지');
      return false;
    }
    
    return true;
  }
  
  /// 스크립트 삽입 감지
  static bool _containsScript(String text) {
    final dangerousPatterns = [
      '<script',
      'javascript:',
      'onclick=',
      'onload=',
      'eval(',
    ];
    
    final lowerText = text.toLowerCase();
    return dangerousPatterns.any((pattern) => lowerText.contains(pattern));
  }
  
  /// 서버 UI 설정 새로고침
  static Future<void> refreshServerConfig() async {
    await _fetchServerUIConfig();
  }
  
  /// 개발용: 특정 블록 토글
  static void devToggleBlock(String screenName, String blockType, String blockId, bool enabled) {
    final screenConfig = _serverUIConfig[screenName] as Map<String, dynamic>?;
    if (screenConfig == null) return;
    
    final blocks = screenConfig[blockType] as List<dynamic>?;
    if (blocks == null) return;
    
    for (final block in blocks) {
      if (block['id'] == blockId) {
        block['enabled'] = enabled;
        break;
      }
    }
    
    print('[SDUI] Dev: $screenName.$blockType.$blockId → $enabled');
  }
}

/// SDUI 배너
class SDUIBanner {
  final String id;
  final String content;
  final SDUIBannerStyle style;
  final bool dismissible;
  final SDUIPosition position;
  
  SDUIBanner({
    required this.id,
    required this.content,
    required this.style,
    required this.dismissible,
    required this.position,
  });
  
  factory SDUIBanner.fromJson(Map<String, dynamic> json) {
    return SDUIBanner(
      id: json['id'],
      content: json['content'],
      style: SDUIBannerStyle.values.firstWhere(
        (s) => s.name == json['style'],
        orElse: () => SDUIBannerStyle.info,
      ),
      dismissible: json['dismissible'] ?? false,
      position: SDUIPosition.values.firstWhere(
        (p) => p.name == json['position'],
        orElse: () => SDUIPosition.top,
      ),
    );
  }
}

/// SDUI 배지
class SDUIBadge {
  final String id;
  final String text;
  final Color color;
  final Color textColor;
  final bool showOnModules;
  final bool enabled;
  
  SDUIBadge({
    required this.id,
    required this.text,
    required this.color,
    required this.textColor,
    required this.showOnModules,
    required this.enabled,
  });
  
  factory SDUIBadge.fromJson(Map<String, dynamic> json) {
    return SDUIBadge(
      id: json['id'],
      text: json['text'],
      color: _parseColor(json['color']),
      textColor: _parseColor(json['text_color']),
      showOnModules: json['show_on_modules'] ?? false,
      enabled: json['enabled'] ?? true,
    );
  }
  
  static Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.grey;
    
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}

/// SDUI 카드
class SDUICard {
  final String id;
  final String title;
  final bool enabled;
  final int priority;
  
  SDUICard({
    required this.id,
    required this.title,
    required this.enabled,
    required this.priority,
  });
  
  factory SDUICard.fromJson(Map<String, dynamic> json) {
    return SDUICard(
      id: json['id'],
      title: json['title'],
      enabled: json['enabled'] ?? true,
      priority: json['priority'] ?? 0,
    );
  }
}

/// SDUI 툴팁
class SDUITooltip {
  final String id;
  final String text;
  final SDUITrigger trigger;
  
  SDUITooltip({
    required this.id,
    required this.text,
    required this.trigger,
  });
  
  factory SDUITooltip.fromJson(Map<String, dynamic> json) {
    return SDUITooltip(
      id: json['id'],
      text: json['text'],
      trigger: SDUITrigger.values.firstWhere(
        (t) => t.name == json['trigger'],
        orElse: () => SDUITrigger.tap,
      ),
    );
  }
}

/// SDUI 공지사항
class SDUINotice {
  final String id;
  final String title;
  final String content;
  final SDUIPriority priority;
  final DateTime? showUntil;
  
  SDUINotice({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    this.showUntil,
  });
  
  factory SDUINotice.fromJson(Map<String, dynamic> json) {
    return SDUINotice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      priority: SDUIPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => SDUIPriority.low,
      ),
      showUntil: json['show_until'] != null 
          ? DateTime.tryParse(json['show_until'])
          : null,
    );
  }
}

/// SDUI 열거형들
enum SDUIBannerStyle { info, warning, error, success }
enum SDUIPosition { top, bottom }
enum SDUITrigger { tap, longPress, hover }
enum SDUIPriority { low, medium, high, critical }