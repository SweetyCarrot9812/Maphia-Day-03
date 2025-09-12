import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

/// 모듈 로딩 서비스 - 선로딩/지연로딩 관리
class ModuleLoaderService {
  static const String _channelName = 'hanoa/module_loader';
  static const MethodChannel _channel = MethodChannel(_channelName);
  
  // 로딩 정책 설정
  static final Map<String, ModuleLoadPolicy> _loadPolicies = {
    'language': ModuleLoadPolicy.preload,     // 언어 모듈: 선로딩
    'medical': ModuleLoadPolicy.lazy,         // 의학/간호학: 지연로딩  
    'exercise': ModuleLoadPolicy.lazy,        // 운동: 지연로딩
    'restaurant': ModuleLoadPolicy.lazy,      // 맛집: 지연로딩
    'christian': ModuleLoadPolicy.lazy,       // 기독교: 지연로딩
  };
  
  // 로딩된 모듈 캐시
  static final Map<String, ModuleData> _loadedModules = {};
  
  // Feature Flag 캐시 (서버에서 가져온 설정)
  static Map<String, dynamic> _serverConfig = {};
  
  /// 앱 시작 시 초기화 - 선로딩 모듈들 로드
  static Future<void> initialize() async {
    try {
      // 1. 서버에서 Feature Flag 가져오기
      await _fetchServerConfig();
      
      // 2. 선로딩 정책 업데이트
      _updateLoadPoliciesFromServer();
      
      // 3. 선로딩 모듈들 로드
      await _preloadModules();
      
      print('[ModuleLoader] 초기화 완료: ${_loadedModules.keys.toList()}');
    } catch (e) {
      print('[ModuleLoader] 초기화 실패: $e');
      // 실패해도 앱은 계속 실행 (오프라인 fallback)
    }
  }
  
  /// 서버에서 Feature Flag 설정 가져오기
  static Future<void> _fetchServerConfig() async {
    try {
      // TODO: 실제 서버 API 호출로 교체
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 임시 서버 응답 시뮬레이션
      _serverConfig = {
        'module_policies': {
          'language': 'preload',     // 서버에서 언어 모듈 선로딩 지시
          'medical': 'lazy',         // 의학은 지연로딩
        },
        'feature_flags': {
          'language_module_enabled': true,
          'medical_module_enabled': true,
          'exercise_module_enabled': false, // 운동 모듈 비활성화
        },
        'version': '2025.09',
      };
    } catch (e) {
      print('[ModuleLoader] 서버 설정 로드 실패: $e');
      // 기본 설정 유지
    }
  }
  
  /// 서버 설정으로 로딩 정책 업데이트
  static void _updateLoadPoliciesFromServer() {
    final serverPolicies = _serverConfig['module_policies'] as Map<String, dynamic>?;
    if (serverPolicies == null) return;
    
    for (final entry in serverPolicies.entries) {
      final moduleId = entry.key;
      final policyString = entry.value as String;
      
      final policy = policyString == 'preload' 
          ? ModuleLoadPolicy.preload 
          : ModuleLoadPolicy.lazy;
          
      _loadPolicies[moduleId] = policy;
      print('[ModuleLoader] 정책 업데이트: $moduleId -> $policy');
    }
  }
  
  /// 선로딩 모듈들 로드
  static Future<void> _preloadModules() async {
    final preloadModules = _loadPolicies.entries
        .where((entry) => entry.value == ModuleLoadPolicy.preload)
        .map((entry) => entry.key)
        .toList();
    
    for (final moduleId in preloadModules) {
      await _loadModuleData(moduleId);
    }
  }
  
  /// 특정 모듈 데이터 로드 (실제 로딩 로직)
  static Future<ModuleData> _loadModuleData(String moduleId) async {
    try {
      print('[ModuleLoader] 모듈 로딩 시작: $moduleId');
      
      // 이미 로딩된 경우 캐시 반환
      if (_loadedModules.containsKey(moduleId)) {
        return _loadedModules[moduleId]!;
      }
      
      // 모듈별 로딩 시뮬레이션 (실제로는 네트워크/파일 로딩)
      await Future.delayed(Duration(
        milliseconds: moduleId == 'language' ? 800 : 1500, // 언어는 빠르게
      ));
      
      final moduleData = _createModuleData(moduleId);
      _loadedModules[moduleId] = moduleData;
      
      print('[ModuleLoader] 모듈 로딩 완료: $moduleId');
      return moduleData;
    } catch (e) {
      print('[ModuleLoader] 모듈 로딩 실패 $moduleId: $e');
      rethrow;
    }
  }
  
  /// 모듈 데이터 생성 (임시 - 실제로는 서버에서 가져옴)
  static ModuleData _createModuleData(String moduleId) {
    switch (moduleId) {
      case 'language':
        return ModuleData(
          id: moduleId,
          name: '언어 학습',
          version: '1.2.0',
          description: 'SRS 기반 다국어 학습',
          entryPoint: '/language/home',
          assets: ['language_pack_en.json', 'language_pack_ko.json'],
          permissions: ['microphone', 'storage'],
        );
      case 'medical':
        return ModuleData(
          id: moduleId,
          name: '의학/간호학',
          version: '1.6.0', 
          description: '간호사 국가고시 대비',
          entryPoint: '/medical/nursing',
          assets: ['nursing_problems.db', 'medical_concepts.json'],
          permissions: ['storage'],
        );
      case 'exercise':
        return ModuleData(
          id: moduleId,
          name: '퍼스널 피트니스',
          version: '1.0.0',
          description: 'AI 맞춤 운동 추천',
          entryPoint: '/exercise/workout',
          assets: ['exercise_data.json'],
          permissions: ['storage'],
        );
      default:
        throw Exception('알 수 없는 모듈: $moduleId');
    }
  }
  
  /// 지연 로딩 - 사용자가 모듈 진입 시 호출
  static Future<ModuleData> loadModuleOnDemand(String moduleId) async {
    // Feature Flag 체크
    final isEnabled = isModuleEnabled(moduleId);
    if (!isEnabled) {
      throw Exception('모듈이 비활성화됨: $moduleId');
    }
    
    return await _loadModuleData(moduleId);
  }
  
  /// 모듈 활성화 여부 확인 (Feature Flag)
  static bool isModuleEnabled(String moduleId) {
    final flagKey = '${moduleId}_module_enabled';
    final flags = _serverConfig['feature_flags'] as Map<String, dynamic>?;
    return flags?[flagKey] ?? true; // 기본값 true
  }
  
  /// 모듈 로딩 상태 확인
  static bool isModuleLoaded(String moduleId) {
    return _loadedModules.containsKey(moduleId);
  }
  
  /// 로딩된 모듈 데이터 가져오기
  static ModuleData? getLoadedModule(String moduleId) {
    return _loadedModules[moduleId];
  }
  
  /// 모듈 언로드 (메모리 절약)
  static void unloadModule(String moduleId) {
    _loadedModules.remove(moduleId);
    print('[ModuleLoader] 모듈 언로드: $moduleId');
  }
  
  /// 모든 모듈 상태 가져오기
  static Map<String, ModuleLoadStatus> getModuleStatuses() {
    final result = <String, ModuleLoadStatus>{};
    
    for (final moduleId in _loadPolicies.keys) {
      if (!isModuleEnabled(moduleId)) {
        result[moduleId] = ModuleLoadStatus.disabled;
      } else if (isModuleLoaded(moduleId)) {
        result[moduleId] = ModuleLoadStatus.loaded;
      } else if (_loadPolicies[moduleId] == ModuleLoadPolicy.preload) {
        result[moduleId] = ModuleLoadStatus.loading; // 선로딩 중
      } else {
        result[moduleId] = ModuleLoadStatus.notLoaded;
      }
    }
    
    return result;
  }
  
  /// 서버 설정 다시 가져오기 (원격 토글용)
  static Future<void> refreshServerConfig() async {
    await _fetchServerConfig();
    _updateLoadPoliciesFromServer();
  }
}

/// 모듈 로딩 정책
enum ModuleLoadPolicy {
  preload,  // 선로딩: 앱 시작 시 자동 로드
  lazy,     // 지연로딩: 사용자 진입 시 로드
}

/// 모듈 로딩 상태
enum ModuleLoadStatus {
  notLoaded,  // 아직 로드되지 않음
  loading,    // 로딩 중
  loaded,     // 로드 완료
  disabled,   // Feature Flag로 비활성화
  error,      // 로딩 실패
}

/// 모듈 데이터
class ModuleData {
  final String id;
  final String name;
  final String version;
  final String description;
  final String entryPoint;
  final List<String> assets;
  final List<String> permissions;
  final DateTime loadedAt;
  
  ModuleData({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.entryPoint,
    required this.assets,
    required this.permissions,
  }) : loadedAt = DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'description': description,
      'entryPoint': entryPoint,
      'assets': assets,
      'permissions': permissions,
      'loadedAt': loadedAt.toIso8601String(),
    };
  }
}