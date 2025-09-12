import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import 'models/concept.dart';
import 'models/problem.dart';
import 'models/pending_change.dart';
import 'models/user.dart';

class Database {
  static Database? _instance;
  static Isar? _isar;
  static final Logger _logger = Logger();

  Database._();

  static Database get instance {
    _instance ??= Database._();
    return _instance!;
  }

  static Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call Database.initialize() first.');
    }
    return _isar!;
  }

  /// Initialize the database
  static Future<void> initialize() async {
    if (_isar != null) {
      _logger.i('Database already initialized');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      
      _isar = await Isar.open([
        ConceptSchema,
        ProblemSchema,
        PendingChangeSchema,
        UserSchema,
      ], directory: dir.path);

      _logger.i('Database initialized successfully at: ${dir.path}');
      
      // Log database stats
      await _logDatabaseStats();
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize database', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Close the database
  static Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
      _logger.i('Database closed');
    }
  }

  /// Clear all data (for testing/debugging)
  static Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
    _logger.i('All data cleared from database');
  }

  /// Log database statistics
  static Future<void> _logDatabaseStats() async {
    try {
      final conceptCount = await isar.concepts.count();
      final problemCount = await isar.problems.count();
      final pendingChangeCount = await isar.pendingChanges.count();
      final userCount = await isar.users.count();

      _logger.i('''
Database Stats:
- Concepts: $conceptCount
- Problems: $problemCount
- Pending Changes: $pendingChangeCount
- Users: $userCount
      ''');
    } catch (e) {
      _logger.e('Failed to log database stats: $e');
    }
  }

  /// Export database to JSON (for debugging)
  static Future<Map<String, dynamic>> exportToJson() async {
    final concepts = await isar.concepts.where().findAll();
    final problems = await isar.problems.where().findAll();
    final pendingChanges = await isar.pendingChanges.where().findAll();

    return {
      'concepts': concepts.map((c) => c.toJson()).toList(),
      'problems': problems.map((p) => p.toJson()).toList(),
      'pendingChanges': pendingChanges.map((pc) => pc.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Clean up expired pending changes
  static Future<int> cleanupExpiredChanges() async {
    final expiredChanges = await isar.pendingChanges
        .filter()
        .statusEqualTo('pending')
        .findAll();

    final expired = expiredChanges.where((change) => change.isExpired).toList();
    
    if (expired.isNotEmpty) {
      await isar.writeTxn(() async {
        for (final change in expired) {
          change.status = 'expired';
          await isar.pendingChanges.put(change);
        }
      });

      _logger.i('Cleaned up ${expired.length} expired changes');
    }

    return expired.length;
  }
}