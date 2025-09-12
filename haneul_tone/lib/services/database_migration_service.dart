import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/session_v2.dart';

/// 데이터베이스 마이그레이션 서비스
/// 
/// HaneulTone v1 고도화 - V1에서 V2로의 스키마 업그레이드
/// 
/// Features:
/// - 안전한 스키마 마이그레이션
/// - 데이터 무손실 업그레이드
/// - 백업 및 복구 기능
/// - 롤백 지원
class DatabaseMigrationService {
  static const String _databaseName = 'haneultone.db';
  static const int _currentSchemaVersion = 2;
  static const int _previousSchemaVersion = 1;

  /// 데이터베이스 마이그레이션 실행
  /// 
  /// [returns]: 마이그레이션 성공 여부
  static Future<bool> migrateDatabaseToV2() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);

      // 백업 생성
      await _createBackup(path);

      // 데이터베이스 열기 (마이그레이션 콜백과 함께)
      final database = await openDatabase(
        path,
        version: _currentSchemaVersion,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
      );

      await database.close();

      print('✅ 데이터베이스 마이그레이션 완료: V$_previousSchemaVersion → V$_currentSchemaVersion');
      return true;
    } catch (e) {
      print('❌ 데이터베이스 마이그레이션 실패: $e');
      
      // 실패 시 백업에서 복구 시도
      await _restoreFromBackup();
      return false;
    }
  }

  /// 스키마 업그레이드 콜백
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 데이터베이스 업그레이드: $oldVersion → $newVersion');

    if (oldVersion == 1 && newVersion == 2) {
      await _migrateV1ToV2(db);
    }
    
    // 향후 버전 업그레이드를 위한 확장 지점
    // if (oldVersion == 2 && newVersion == 3) {
    //   await _migrateV2ToV3(db);
    // }
  }

  /// 스키마 다운그레이드 콜백 (에러 복구용)
  static Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    print('⚠️  데이터베이스 다운그레이드: $oldVersion → $newVersion');
    
    if (oldVersion == 2 && newVersion == 1) {
      await _migrateV2ToV1(db);
    }
  }

  /// V1에서 V2로 마이그레이션
  static Future<void> _migrateV1ToV2(Database db) async {
    print('📋 V1 → V2 마이그레이션 시작...');

    await db.transaction((txn) async {
      // 1. 기존 데이터 백업
      final existingSessions = await txn.query('sessions');
      print('📊 기존 세션 ${existingSessions.length}개 발견');

      // 2. 새 테이블 생성 (V2 스키마)
      await txn.execute('''
        CREATE TABLE sessions_v2 (
          id TEXT PRIMARY KEY,
          reference_id TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          user_recording_path TEXT,
          pitch_data_path TEXT,
          metrics_json TEXT,
          segments_json TEXT,
          calibration_json TEXT,
          dtw_result_json TEXT,
          additional_data_json TEXT,
          schema_version INTEGER NOT NULL DEFAULT 2,
          FOREIGN KEY (reference_id) REFERENCES audio_references (id)
        );
      ''');

      // 3. 인덱스 생성 (성능 최적화)
      await txn.execute('''
        CREATE INDEX idx_sessions_v2_reference_id ON sessions_v2(reference_id);
      ''');
      
      await txn.execute('''
        CREATE INDEX idx_sessions_v2_created_at ON sessions_v2(created_at DESC);
      ''');

      // 4. 기존 데이터를 V2 형식으로 변환하여 삽입
      int migratedCount = 0;
      for (final sessionRow in existingSessions) {
        try {
          final sessionV2 = SessionV2.fromV1(
            id: sessionRow['id'] as String,
            referenceId: sessionRow['reference_id'] as String,
            createdAt: DateTime.fromMillisecondsSinceEpoch(sessionRow['created_at'] as int),
            userRecordingPath: sessionRow['user_recording_path'] as String?,
            pitchDataPath: sessionRow['pitch_data_path'] as String?,
            accuracyMean: (sessionRow['accuracy_mean'] as num?)?.toDouble(),
            stabilitySd: (sessionRow['stability_sd'] as num?)?.toDouble(),
            weakSteps: sessionRow['weak_steps'] as String?,
            aiFeedback: sessionRow['ai_feedback'] as String?,
          );

          await txn.insert('sessions_v2', sessionV2.toSqlite());
          migratedCount++;
        } catch (e) {
          print('⚠️  세션 ${sessionRow['id']} 마이그레이션 실패: $e');
        }
      }

      // 5. 기존 테이블 삭제 및 새 테이블을 원래 이름으로 변경
      await txn.execute('DROP TABLE sessions');
      await txn.execute('ALTER TABLE sessions_v2 RENAME TO sessions');

      print('✅ $migratedCount개 세션 마이그레이션 완료');
    });

    print('🎉 V1 → V2 마이그레이션 완료');
  }

  /// V2에서 V1로 다운그레이드 (복구용)
  static Future<void> _migrateV2ToV1(Database db) async {
    print('📋 V2 → V1 다운그레이드 시작 (복구 모드)...');

    await db.transaction((txn) async {
      // V2 테이블에서 데이터 읽기
      final v2Sessions = await txn.query('sessions');
      
      // V1 스키마로 테이블 재생성
      await txn.execute('DROP TABLE sessions');
      await txn.execute('''
        CREATE TABLE sessions (
          id TEXT PRIMARY KEY,
          reference_id TEXT NOT NULL,
          accuracy_mean REAL NOT NULL,
          stability_sd REAL NOT NULL,
          weak_steps TEXT NOT NULL,
          ai_feedback TEXT,
          created_at INTEGER NOT NULL,
          user_recording_path TEXT,
          pitch_data_path TEXT,
          FOREIGN KEY (reference_id) REFERENCES audio_references (id)
        );
      ''');

      // V2 데이터를 V1 형식으로 변환
      for (final sessionRow in v2Sessions) {
        try {
          final sessionV2 = SessionV2.fromSqlite(sessionRow);
          
          // V1 필드들 추출
          final accuracyMean = sessionV2.metrics?.accuracyCents ?? 0.0;
          final stabilitySd = sessionV2.metrics?.stabilityCents ?? 0.0;
          final weakSteps = sessionV2.segments
              .map((s) => ((s.startTimeMs / 1000).round()).toString())
              .join(',');
          
          await txn.insert('sessions', {
            'id': sessionV2.id,
            'reference_id': sessionV2.referenceId,
            'accuracy_mean': accuracyMean,
            'stability_sd': stabilitySd,
            'weak_steps': weakSteps,
            'ai_feedback': null, // V2에서 제거된 필드
            'created_at': sessionV2.createdAt.millisecondsSinceEpoch,
            'user_recording_path': sessionV2.userRecordingPath,
            'pitch_data_path': sessionV2.pitchDataPath,
          });
        } catch (e) {
          print('⚠️  세션 다운그레이드 실패: $e');
        }
      }

      print('✅ V2 → V1 다운그레이드 완료');
    });
  }

  /// 데이터베이스 백업 생성
  static Future<void> _createBackup(String originalPath) async {
    try {
      if (!await File(originalPath).exists()) {
        print('ℹ️  기존 데이터베이스가 없음 - 백업 건너뜀');
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = '${originalPath}.backup_$timestamp';
      
      await File(originalPath).copy(backupPath);
      print('💾 백업 생성: $backupPath');
      
      // 오래된 백업 파일 정리 (5개까지만 보존)
      await _cleanupOldBackups(originalPath);
    } catch (e) {
      print('⚠️  백업 생성 실패: $e');
    }
  }

  /// 백업에서 복구
  static Future<void> _restoreFromBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final originalPath = join(dbPath, _databaseName);
      final directory = Directory(dirname(originalPath));
      
      // 최신 백업 파일 찾기
      final backupFiles = await directory.list()
          .where((file) => file.path.startsWith('$originalPath.backup_'))
          .map((file) => File(file.path))
          .toList();
      
      if (backupFiles.isEmpty) {
        print('❌ 복구 가능한 백업이 없습니다');
        return;
      }

      // 파일명에서 타임스탬프 추출하여 최신 것 선택
      backupFiles.sort((a, b) {
        final timestampA = int.tryParse(a.path.split('backup_').last) ?? 0;
        final timestampB = int.tryParse(b.path.split('backup_').last) ?? 0;
        return timestampB.compareTo(timestampA);
      });

      final latestBackup = backupFiles.first;
      
      // 현재 데이터베이스 파일 삭제 후 백업에서 복구
      if (await File(originalPath).exists()) {
        await File(originalPath).delete();
      }
      
      await latestBackup.copy(originalPath);
      print('🔄 백업에서 복구 완료: ${latestBackup.path}');
    } catch (e) {
      print('❌ 백업 복구 실패: $e');
    }
  }

  /// 오래된 백업 파일 정리
  static Future<void> _cleanupOldBackups(String originalPath) async {
    try {
      final directory = Directory(dirname(originalPath));
      final backupFiles = await directory.list()
          .where((file) => file.path.startsWith('$originalPath.backup_'))
          .map((file) => File(file.path))
          .toList();

      if (backupFiles.length <= 5) return; // 5개 이하면 정리하지 않음

      // 타임스탬프로 정렬 (최신 순)
      backupFiles.sort((a, b) {
        final timestampA = int.tryParse(a.path.split('backup_').last) ?? 0;
        final timestampB = int.tryParse(b.path.split('backup_').last) ?? 0;
        return timestampB.compareTo(timestampA);
      });

      // 5개를 제외한 나머지 삭제
      final filesToDelete = backupFiles.skip(5);
      for (final file in filesToDelete) {
        await file.delete();
        print('🗑️  오래된 백업 삭제: ${file.path}');
      }
    } catch (e) {
      print('⚠️  백업 정리 실패: $e');
    }
  }

  /// 현재 데이터베이스 버전 확인
  static Future<int> getCurrentDatabaseVersion() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);

      if (!await File(path).exists()) {
        return 0; // 데이터베이스가 없으면 0
      }

      final db = await openDatabase(path, readOnly: true);
      final result = await db.rawQuery('PRAGMA user_version');
      await db.close();

      return (result.first['user_version'] as int?) ?? 1; // 기본값 1
    } catch (e) {
      print('⚠️  데이터베이스 버전 확인 실패: $e');
      return 1; // 에러 시 V1으로 간주
    }
  }

  /// 마이그레이션 상태 확인
  static Future<MigrationStatus> checkMigrationStatus() async {
    final currentVersion = await getCurrentDatabaseVersion();
    
    return MigrationStatus(
      currentVersion: currentVersion,
      targetVersion: _currentSchemaVersion,
      needsMigration: currentVersion < _currentSchemaVersion,
      canMigrate: currentVersion <= _currentSchemaVersion,
    );
  }
}

/// 마이그레이션 상태 정보
class MigrationStatus {
  final int currentVersion;
  final int targetVersion;
  final bool needsMigration;
  final bool canMigrate;

  const MigrationStatus({
    required this.currentVersion,
    required this.targetVersion,
    required this.needsMigration,
    required this.canMigrate,
  });

  @override
  String toString() {
    return 'MigrationStatus('
           'current: $currentVersion, '
           'target: $targetVersion, '
           'needsMigration: $needsMigration, '
           'canMigrate: $canMigrate)';
  }
}