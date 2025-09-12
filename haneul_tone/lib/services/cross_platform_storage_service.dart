import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/audio_reference.dart';
import '../models/session.dart';
import '../models/pitch_data.dart';
import 'database_service.dart';

/// 크로스 플랫폼 데이터 저장 서비스
/// 웹: Hive (IndexedDB 기반)
/// 모바일: SQLite 또는 Hive
class CrossPlatformStorageService {
  static const String audioReferencesBoxName = 'audio_references';
  static const String sessionsBoxName = 'sessions';
  static const String pitchDataBoxName = 'pitch_data';
  
  static Box<Map>? _audioReferencesBox;
  static Box<Map>? _sessionsBox;
  static Box<Map>? _pitchDataBox;
  
  static final CrossPlatformStorageService _instance = CrossPlatformStorageService._internal();
  factory CrossPlatformStorageService() => _instance;
  CrossPlatformStorageService._internal();
  
  bool _isInitialized = false;
  DatabaseService? _sqliteService;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      if (kIsWeb) {
        await _initializeHive();
      } else {
        // 모바일에서는 SQLite 우선, 실패 시 Hive
        try {
          _sqliteService = DatabaseService();
          await _sqliteService!.database;
          print('SQLite 데이터베이스 초기화 성공');
        } catch (e) {
          print('SQLite 초기화 실패, Hive로 fallback: $e');
          await _initializeHive();
        }
      }
      
      _isInitialized = true;
      print('크로스 플랫폼 데이터베이스 초기화 완료');
    } catch (e) {
      print('데이터베이스 초기화 오류: $e');
      rethrow;
    }
  }
  
  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    
    _audioReferencesBox = await Hive.openBox<Map>(audioReferencesBoxName);
    _sessionsBox = await Hive.openBox<Map>(sessionsBoxName);
    _pitchDataBox = await Hive.openBox<Map>(pitchDataBoxName);
  }

  /// Audio Reference 저장
  Future<int> insertAudioReference(AudioReference audioRef) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.insertAudioReference(audioRef);
    } else {
      final id = DateTime.now().millisecondsSinceEpoch;
      final audioRefWithId = AudioReference(
        id: id,
        title: audioRef.title,
        filePath: audioRef.filePath,
        key: audioRef.key,
        scaleType: audioRef.scaleType,
        octaves: audioRef.octaves,
        a4Freq: audioRef.a4Freq,
        createdAt: audioRef.createdAt,
      );
      
      await _audioReferencesBox!.put(id, audioRefWithId.toMap());
      return id;
    }
  }

  /// 모든 Audio Reference 조회
  Future<List<AudioReference>> getAllAudioReferences() async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.getAllAudioReferences();
    } else {
      final List<AudioReference> audioRefs = [];
      
      for (var entry in _audioReferencesBox!.toMap().entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value);
          audioRefs.add(AudioReference.fromMap(map));
        } catch (e) {
          print('Audio Reference 파싱 오류: $e');
        }
      }
      
      // 생성일 순 정렬
      audioRefs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return audioRefs;
    }
  }

  /// Audio Reference 조회 (ID)
  Future<AudioReference?> getAudioReference(int id) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.getAudioReference(id);
    } else {
      final data = _audioReferencesBox!.get(id);
      if (data != null) {
        return AudioReference.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    }
  }

  /// Audio Reference 업데이트
  Future<int> updateAudioReference(AudioReference audioRef) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.updateAudioReference(audioRef);
    } else {
      await _audioReferencesBox!.put(audioRef.id!, audioRef.toMap());
      return 1;
    }
  }

  /// Audio Reference 삭제
  Future<int> deleteAudioReference(int id) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.deleteAudioReference(id);
    } else {
      await _audioReferencesBox!.delete(id);
      return 1;
    }
  }

  /// Session 저장
  Future<int> insertSession(Session session) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.insertSession(session);
    } else {
      final id = DateTime.now().millisecondsSinceEpoch;
      final sessionWithId = Session(
        id: id,
        referenceId: session.referenceId,
        accuracyMean: session.accuracyMean,
        stabilitySd: session.stabilitySd,
        weakSteps: session.weakSteps,
        aiFeedback: session.aiFeedback,
        createdAt: session.createdAt,
      );
      
      await _sessionsBox!.put(id, sessionWithId.toMap());
      return id;
    }
  }

  /// 모든 Session 조회
  Future<List<Session>> getAllSessions() async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.getAllSessions();
    } else {
      final List<Session> sessions = [];
      
      for (var entry in _sessionsBox!.toMap().entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value);
          sessions.add(Session.fromMap(map));
        } catch (e) {
          print('Session 파싱 오류: $e');
        }
      }
      
      // 생성일 순 정렬
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sessions;
    }
  }

  /// Reference ID로 Session 조회
  Future<List<Session>> getSessionsByReference(int referenceId) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.getSessionsByReference(referenceId);
    } else {
      final allSessions = await getAllSessions();
      return allSessions.where((s) => s.referenceId == referenceId).toList();
    }
  }

  /// Session 업데이트
  Future<int> updateSession(Session session) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.updateSession(session);
    } else {
      await _sessionsBox!.put(session.id!, session.toMap());
      return 1;
    }
  }

  /// Session 삭제
  Future<int> deleteSession(int id) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.deleteSession(id);
    } else {
      await _sessionsBox!.delete(id);
      return 1;
    }
  }

  /// PitchData 저장
  Future<int> insertPitchData(PitchData pitchData) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.insertPitchData(pitchData);
    } else {
      final id = DateTime.now().millisecondsSinceEpoch;
      final pitchDataWithId = PitchData(
        id: id,
        audioReferenceId: pitchData.audioReferenceId,
        pitchCurve: pitchData.pitchCurve,
        timestamps: pitchData.timestamps,
        noteSegments: pitchData.noteSegments,
        sampleRate: pitchData.sampleRate,
        createdAt: pitchData.createdAt,
      );
      
      await _pitchDataBox!.put(id, pitchDataWithId.toMap());
      return id;
    }
  }

  /// Reference ID로 PitchData 조회
  Future<PitchData?> getPitchDataByReferenceId(int referenceId) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.getPitchDataByReferenceId(referenceId);
    } else {
      for (var entry in _pitchDataBox!.toMap().entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value);
          final pitchData = PitchData.fromMap(map);
          if (pitchData.audioReferenceId == referenceId) {
            return pitchData;
          }
        } catch (e) {
          print('PitchData 파싱 오류: $e');
        }
      }
      return null;
    }
  }

  /// 모든 PitchData 조회
  Future<List<PitchData>> getAllPitchData() async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.getAllPitchData();
    } else {
      final List<PitchData> pitchDataList = [];
      
      for (var entry in _pitchDataBox!.toMap().entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value);
          pitchDataList.add(PitchData.fromMap(map));
        } catch (e) {
          print('PitchData 파싱 오류: $e');
        }
      }
      
      // 생성일 순 정렬
      pitchDataList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return pitchDataList;
    }
  }

  /// PitchData 업데이트
  Future<int> updatePitchData(PitchData pitchData) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.updatePitchData(pitchData);
    } else {
      await _pitchDataBox!.put(pitchData.id!, pitchData.toMap());
      return 1;
    }
  }

  /// PitchData 삭제
  Future<int> deletePitchData(int id) async {
    if (!_isInitialized) await initialize();
    
    if (_sqliteService != null) {
      return await _sqliteService!.deletePitchData(id);
    } else {
      await _pitchDataBox!.delete(id);
      return 1;
    }
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    if (_sqliteService != null) {
      await _sqliteService!.close();
    } else {
      await _audioReferencesBox?.close();
      await _sessionsBox?.close();
      await _pitchDataBox?.close();
    }
  }

  /// 현재 사용 중인 데이터베이스 타입
  String get currentDatabaseType {
    if (_sqliteService != null) return 'SQLite';
    return 'Hive';
  }
}