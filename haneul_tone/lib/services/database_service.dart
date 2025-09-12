import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/audio_reference.dart';
import '../models/session.dart';
import '../models/pitch_data.dart';
import 'progress_tracking_service.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'haneul_tone.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Audio References 테이블 생성
    await db.execute('''
      CREATE TABLE audio_references (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        key TEXT NOT NULL,
        scale_type TEXT NOT NULL,
        octaves INTEGER NOT NULL,
        a4_freq REAL NOT NULL DEFAULT 440.0,
        created_at INTEGER NOT NULL
      )
    ''');

    // Sessions 테이블 생성
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference_id INTEGER NOT NULL,
        accuracy_mean REAL NOT NULL,
        stability_sd REAL NOT NULL,
        weak_steps TEXT NOT NULL,
        ai_feedback TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (reference_id) REFERENCES audio_references (id)
      )
    ''');

    // Pitch Data 테이블 생성
    await db.execute('''
      CREATE TABLE pitch_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        audio_reference_id INTEGER NOT NULL,
        pitch_curve TEXT NOT NULL,
        timestamps TEXT NOT NULL,
        note_segments TEXT NOT NULL,
        sample_rate REAL NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (audio_reference_id) REFERENCES audio_references (id)
      )
    ''');
    
    // Progress Tracking 테이블 생성
    await ProgressTrackingService.createTable(db);
  }

  // Audio Reference CRUD 작업
  Future<int> insertAudioReference(AudioReference audioRef) async {
    final db = await database;
    return await db.insert('audio_references', audioRef.toMap());
  }

  Future<List<AudioReference>> getAllAudioReferences() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audio_references',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => AudioReference.fromMap(map)).toList();
  }

  Future<AudioReference?> getAudioReference(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audio_references',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AudioReference.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAudioReference(AudioReference audioRef) async {
    final db = await database;
    return await db.update(
      'audio_references',
      audioRef.toMap(),
      where: 'id = ?',
      whereArgs: [audioRef.id],
    );
  }

  Future<int> deleteAudioReference(int id) async {
    final db = await database;
    return await db.delete(
      'audio_references',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Session CRUD 작업
  Future<int> insertSession(Session session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  Future<List<Session>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  Future<List<Session>> getSessionsByReference(int referenceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'reference_id = ?',
      whereArgs: [referenceId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  Future<Session?> getSession(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Session.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSession(Session session) async {
    final db = await database;
    return await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Pitch Data CRUD 작업
  Future<int> insertPitchData(PitchData pitchData) async {
    final db = await database;
    final pitchDataWithoutId = PitchData(
      id: 0, // 자동 생성됨
      audioReferenceId: pitchData.audioReferenceId,
      pitchCurve: pitchData.pitchCurve,
      timestamps: pitchData.timestamps,
      noteSegments: pitchData.noteSegments,
      sampleRate: pitchData.sampleRate,
      createdAt: pitchData.createdAt,
    );
    return await db.insert('pitch_data', pitchDataWithoutId.toMap());
  }

  Future<PitchData?> getPitchDataByReferenceId(int referenceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pitch_data',
      where: 'audio_reference_id = ?',
      whereArgs: [referenceId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return PitchData.fromMap(maps.first);
    }
    return null;
  }

  // 호환성을 위한 별칭
  Future<PitchData?> getPitchDataByAudioId(int audioId) async {
    return await getPitchDataByReferenceId(audioId);
  }

  Future<List<PitchData>> getAllPitchData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pitch_data',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PitchData.fromMap(map)).toList();
  }

  Future<int> updatePitchData(PitchData pitchData) async {
    final db = await database;
    return await db.update(
      'pitch_data',
      pitchData.toMap(),
      where: 'id = ?',
      whereArgs: [pitchData.id],
    );
  }

  Future<int> deletePitchData(int id) async {
    final db = await database;
    return await db.delete(
      'pitch_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePitchDataByReferenceId(int referenceId) async {
    final db = await database;
    return await db.delete(
      'pitch_data',
      where: 'audio_reference_id = ?',
      whereArgs: [referenceId],
    );
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}