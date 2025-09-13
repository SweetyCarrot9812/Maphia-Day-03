import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../models/problem.dart';
import '../models/quiz_session.dart';
import '../models/user_progress.dart';
import '../models/job_queue.dart';
import '../models/usage_log.dart';
import '../models/usage_daily.dart';
import '../models/pricing_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  
  DatabaseService._internal();

  Isar? _isar;
  final Logger _logger = Logger();

  /// Get the Isar instance, initializing if necessary
  Future<Isar> get _isarInstance async {
    if (_isar == null || !_isar!.isOpen) {
      await initialize();
    }
    return _isar!;
  }

  /// Initialize the database
  Future<Isar> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      
      _isar = await Isar.open([
        ProblemSchema,
        QuizSessionSchema,
        UserProgressSchema,
        JobQueueSchema,
        UsageLogSchema,
        UsageDailySchema,
        PricingModelSchema,
      ], directory: dir.path);
      
      _logger.i('Database initialized successfully');
      return _isar!;
    } catch (e, stackTrace) {
      _logger.e('Database initialization failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Problem Operations
  Future<void> createProblem(Problem problem) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.problems.put(problem);
    });
  }

  Future<List<Problem>> getProblems() async {
    final isar = await _isarInstance;
    return await isar.problems.where().sortByCreatedAtDesc().findAll();
  }

  Future<Problem?> getProblem(int id) async {
    final isar = await _isarInstance;
    return await isar.problems.get(id);
  }

  Future<Problem?> getProblemByProblemId(String problemId) async {
    final isar = await _isarInstance;
    return await isar.problems.filter().problemIdEqualTo(problemId).findFirst();
  }

  Future<List<Problem>> getProblemsByType(ProblemType type) async {
    final isar = await _isarInstance;
    return await isar.problems.filter().typeEqualTo(type).findAll();
  }

  Future<List<Problem>> getProblemsByStatus(ProblemStatus status) async {
    final isar = await _isarInstance;
    return await isar.problems.filter().statusEqualTo(status).findAll();
  }

  Future<List<Problem>> getProblemsByDifficulty(Difficulty difficulty) async {
    final isar = await _isarInstance;
    return await isar.problems.filter().difficultyEqualTo(difficulty).findAll();
  }

  Future<void> updateProblem(Problem problem) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.problems.put(problem);
    });
  }

  Future<void> deleteProblem(int id) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.problems.delete(id);
    });
  }

  /// Job Queue Operations
  Future<void> createJob(JobQueue job) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.jobQueues.put(job);
    });
  }

  Future<List<JobQueue>> getJobs() async {
    final isar = await _isarInstance;
    return await isar.jobQueues.where().sortByCreatedAtDesc().findAll();
  }

  Future<JobQueue?> getJob(int id) async {
    final isar = await _isarInstance;
    return await isar.jobQueues.get(id);
  }

  Future<JobQueue?> getJobByJobId(String jobId) async {
    final isar = await _isarInstance;
    return await isar.jobQueues.filter().jobIdEqualTo(jobId).findFirst();
  }

  Future<List<JobQueue>> getJobsByStatus(JobStatus status) async {
    final isar = await _isarInstance;
    return await isar.jobQueues.filter().statusEqualTo(status).findAll();
  }

  Future<List<JobQueue>> getJobsByType(JobType type) async {
    final isar = await _isarInstance;
    return await isar.jobQueues.filter().typeEqualTo(type).findAll();
  }

  Future<void> updateJob(JobQueue job) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.jobQueues.put(job);
    });
  }

  Future<void> deleteJob(int id) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.jobQueues.delete(id);
    });
  }

  /// Quiz Session Operations
  Future<void> createQuizSession(QuizSession session) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.quizSessions.put(session);
    });
  }

  Future<List<QuizSession>> getQuizSessions() async {
    final isar = await _isarInstance;
    return await isar.quizSessions.where().sortByCreatedAtDesc().findAll();
  }

  Future<QuizSession?> getQuizSession(int id) async {
    final isar = await _isarInstance;
    return await isar.quizSessions.get(id);
  }

  Future<QuizSession?> getQuizSessionBySessionId(String sessionId) async {
    final isar = await _isarInstance;
    return await isar.quizSessions.filter().sessionIdEqualTo(sessionId).findFirst();
  }

  Future<List<QuizSession>> getActiveQuizSessions() async {
    final isar = await _isarInstance;
    return await isar.quizSessions.filter().statusEqualTo(SessionStatus.active).findAll();
  }

  Future<List<QuizSession>> getCompletedQuizSessions() async {
    final isar = await _isarInstance;
    return await isar.quizSessions.filter().statusEqualTo(SessionStatus.completed).findAll();
  }

  Future<void> updateQuizSession(QuizSession session) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.quizSessions.put(session);
    });
  }

  Future<void> deleteQuizSession(int id) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.quizSessions.delete(id);
    });
  }

  /// User Progress Operations
  Future<void> createUserProgress(UserProgress progress) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.userProgress.put(progress);
    });
  }

  Future<UserProgress> getUserProgress([String userId = 'default_user']) async {
    final isar = await _isarInstance;
    var progress = await isar.userProgress.filter().userIdEqualTo(userId).findFirst();
    
    if (progress == null) {
      // Create default user progress
      progress = UserProgress()
        ..userId = userId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      
      await isar.writeTxn(() async {
        await isar.userProgress.put(progress!);
      });
    }
    
    return progress;
  }

  Future<void> updateUserProgress(UserProgress progress) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.userProgress.put(progress);
    });
  }

  Future<void> deleteUserProgress(int id) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.userProgress.delete(id);
    });
  }

  /// Search Operations
  Future<List<Problem>> searchProblems(String query) async {
    if (query.isEmpty) return getProblems();
    
    final isar = await _isarInstance;
    return await isar.problems
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .findAll();
  }

  /// Statistics Operations
  Future<Map<String, int>> getProblemStatistics() async {
    final allProblems = await getProblems();
    final stats = <String, int>{};
    
    for (final type in ProblemType.values) {
      stats[type.name] = allProblems.where((p) => p.type == type).length;
    }
    
    return stats;
  }

  Future<Map<String, dynamic>> getJobStatistics() async {
    final allJobs = await getJobs();
    return {
      'total': allJobs.length,
      'pending': allJobs.where((j) => j.status == JobStatus.pending).length,
      'running': allJobs.where((j) => j.status == JobStatus.running).length,
      'completed': allJobs.where((j) => j.status == JobStatus.completed).length,
      'failed': allJobs.where((j) => j.status == JobStatus.failed).length,
    };
  }

  Future<Map<String, int>> getQuizStatistics() async {
    final allSessions = await getQuizSessions();
    final stats = <String, int>{};
    
    for (final status in SessionStatus.values) {
      stats[status.name] = allSessions.where((s) => s.status == status).length;
    }
    
    return stats;
  }

  /// Maintenance Operations
  Future<void> clearAllData() async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.clear();
    });
    _logger.i('Database cleared successfully');
  }

  Future<void> exportData() async {
    try {
      // Implementation for data export
      _logger.i('Data export started');
      // TODO: Implement data export functionality
    } catch (e, stackTrace) {
      _logger.e('Data export failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> importData(String filePath) async {
    try {
      // Implementation for data import
      _logger.i('Data import started from: $filePath');
      // TODO: Implement data import functionality
    } catch (e, stackTrace) {
      _logger.e('Data import failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Backup Operations
  Future<void> createBackup() async {
    try {
      _logger.i('Creating database backup');
      // TODO: Implement backup functionality
    } catch (e, stackTrace) {
      _logger.e('Backup creation failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> restoreBackup(String backupPath) async {
    try {
      _logger.i('Restoring database from backup: $backupPath');
      // TODO: Implement restore functionality
    } catch (e, stackTrace) {
      _logger.e('Backup restoration failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Usage Log Operations
  Future<void> createUsageLog(UsageLog log) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.usageLogs.put(log);
    });
  }

  Future<List<UsageLog>> getUsageLogs() async {
    final isar = await _isarInstance;
    return await isar.usageLogs.where().sortByTimestampDesc().findAll();
  }

  Future<List<UsageLog>> getUsageLogsForDateRange(DateTime start, DateTime end) async {
    final isar = await _isarInstance;
    return await isar.usageLogs.filter()
        .timestampBetween(start, end)
        .findAll();
  }

  /// Usage Daily Operations
  Future<void> createUsageDaily(UsageDaily daily) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.usageDailys.put(daily);
    });
  }

  Future<List<UsageDaily>> getUsageDaily() async {
    final isar = await _isarInstance;
    return await isar.usageDailys.where().sortByDateDesc().findAll();
  }

  Future<List<UsageDaily>> getUsageDailyForDateRange(String startDate, String endDate) async {
    final isar = await _isarInstance;
    return await isar.usageDailys.filter()
        .dateBetween(startDate, endDate)
        .findAll();
  }

  /// Pricing Model Operations
  Future<void> createPricingModel(PricingModel model) async {
    final isar = await _isarInstance;
    await isar.writeTxn(() async {
      await isar.pricingModels.put(model);
    });
  }

  Future<List<PricingModel>> getPricingModels() async {
    final isar = await _isarInstance;
    return await isar.pricingModels.where().findAll();
  }

  Future<PricingModel?> getPricingModel(String provider, String model) async {
    final isar = await _isarInstance;
    return await isar.pricingModels.filter()
        .providerEqualTo(provider)
        .and()
        .modelEqualTo(model)
        .findFirst();
  }

  /// Close database connection
  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _logger.i('Database connection closed');
    }
  }
}