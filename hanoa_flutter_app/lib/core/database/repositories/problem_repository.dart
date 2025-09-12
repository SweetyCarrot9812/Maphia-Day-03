import 'dart:convert';
import 'package:isar/isar.dart';
import '../database.dart';
import '../models/problem.dart';
import '../models/pending_change.dart';
import 'base_repository.dart';

class ProblemRepository extends BaseRepository<Problem> {
  static final ProblemRepository _instance = ProblemRepository._internal();
  factory ProblemRepository() => _instance;
  ProblemRepository._internal();

  Isar get _isar => Database.isar;

  @override
  Future<Problem> create(Problem problem) async {
    try {
      logOperation('create', data: problem.stem);
      
      problem.updatedAt = DateTime.now();
      
      await _isar.writeTxn(() async {
        await _isar.problems.put(problem);
      });

      logOperation('created', data: 'ID: ${problem.id}');
      return problem;
    } catch (e, stackTrace) {
      logError('create', e, stackTrace);
      throw RepositoryException('Failed to create problem', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<Problem?> getById(int id) async {
    try {
      logOperation('getById', data: id);
      return await _isar.problems.get(id);
    } catch (e, stackTrace) {
      logError('getById', e, stackTrace);
      throw RepositoryException('Failed to get problem by ID', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<Problem>> getAll() async {
    try {
      logOperation('getAll');
      final problems = await _isar.problems.where().sortByUpdatedAtDesc().findAll();
      logOperation('getAll completed', data: '${problems.length} problems');
      return problems;
    } catch (e, stackTrace) {
      logError('getAll', e, stackTrace);
      throw RepositoryException('Failed to get all problems', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<Problem> update(Problem problem) async {
    try {
      logOperation('update', data: 'ID: ${problem.id}, Stem: ${problem.stem.substring(0, problem.stem.length > 50 ? 50 : problem.stem.length)}');
      
      // Get the original problem for comparison
      final original = await getById(problem.id);
      
      problem.updatedAt = DateTime.now();
      
      await _isar.writeTxn(() async {
        await _isar.problems.put(problem);
      });

      // Check if we need to create a PendingChange
      if (original != null) {
        await _checkAndCreatePendingChange(original, problem);
      }

      logOperation('updated', data: 'ID: ${problem.id}');
      return problem;
    } catch (e, stackTrace) {
      logError('update', e, stackTrace);
      throw RepositoryException('Failed to update problem', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      logOperation('delete', data: id);
      
      final success = await _isar.writeTxn(() async {
        return await _isar.problems.delete(id);
      });

      // Also delete related pending changes
      if (success) {
        await _deleteRelatedPendingChanges(id);
      }

      logOperation('deleted', data: 'ID: $id, Success: $success');
      return success;
    } catch (e, stackTrace) {
      logError('delete', e, stackTrace);
      throw RepositoryException('Failed to delete problem', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<Problem>> search(String query) async {
    try {
      logOperation('search', data: query);
      
      if (query.trim().isEmpty) {
        return await getAll();
      }

      final problems = await _isar.problems
          .filter()
          .stemContains(query, caseSensitive: false)
          .sortByUpdatedAtDesc()
          .findAll();

      logOperation('search completed', data: '${problems.length} results for "$query"');
      return problems;
    } catch (e, stackTrace) {
      logError('search', e, stackTrace);
      throw RepositoryException('Failed to search problems', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<int> count() async {
    try {
      return await _isar.problems.count();
    } catch (e, stackTrace) {
      logError('count', e, stackTrace);
      throw RepositoryException('Failed to count problems', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Get problems by tag
  Future<List<Problem>> getByTag(String tag) async {
    try {
      logOperation('getByTag', data: tag);
      
      final problems = await _isar.problems
          .filter()
          .tagsElementContains(tag, caseSensitive: false)
          .sortByUpdatedAtDesc()
          .findAll();

      logOperation('getByTag completed', data: '${problems.length} problems with tag "$tag"');
      return problems;
    } catch (e, stackTrace) {
      logError('getByTag', e, stackTrace);
      throw RepositoryException('Failed to get problems by tag', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Get all unique tags
  Future<List<String>> getAllTags() async {
    try {
      logOperation('getAllTags');
      
      final problems = await _isar.problems.where().findAll();
      final Set<String> tagSet = {};
      
      for (final problem in problems) {
        tagSet.addAll(problem.tags);
      }
      
      final tags = tagSet.toList()..sort();
      logOperation('getAllTags completed', data: '${tags.length} unique tags');
      return tags;
    } catch (e, stackTrace) {
      logError('getAllTags', e, stackTrace);
      throw RepositoryException('Failed to get all tags', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Check if we need to create a PendingChange for this update
  Future<void> _checkAndCreatePendingChange(Problem original, Problem updated) async {
    try {
      // Rule 1: Same stem but significant changes in content
      if (_stemsSimilar(original.stem, updated.stem)) {
        // Check if choices changed significantly
        if (!_listsEqual(original.choices, updated.choices) || 
            original.answerIndex != updated.answerIndex) {
          await _createPendingChange(
            updated.id,
            'Problem choices or correct answer changed',
            _createDiff(original, updated),
          );
          return;
        }
      }

      // Rule 2: Tags added
      final newTags = updated.tags.where((tag) => !original.tags.contains(tag)).toList();
      if (newTags.isNotEmpty) {
        await _createPendingChange(
          updated.id,
          'New tags added: ${newTags.join(', ')}',
          _createDiff(original, updated),
        );
      }
    } catch (e) {
      logError('_checkAndCreatePendingChange', e, null);
      // Don't throw here - pending change creation should not block the main operation
    }
  }

  /// Check if two stems are similar (for pending change detection)
  bool _stemsSimilar(String stem1, String stem2) {
    // Simple similarity check - you can make this more sophisticated
    final cleanStem1 = stem1.trim().toLowerCase();
    final cleanStem2 = stem2.trim().toLowerCase();
    
    // If they're exactly the same
    if (cleanStem1 == cleanStem2) return true;
    
    // If one contains the other and they're both reasonably long
    if (cleanStem1.length > 20 && cleanStem2.length > 20) {
      return cleanStem1.contains(cleanStem2) || cleanStem2.contains(cleanStem1);
    }
    
    return false;
  }

  /// Create a PendingChange
  Future<void> _createPendingChange(int entityId, String summary, String diffJson) async {
    // Check if there's already a pending change for this entity today
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final existingChanges = await _isar.pendingChanges
        .filter()
        .entityTypeEqualTo('problem')
        .and()
        .entityIdEqualTo(entityId)
        .and()
        .statusEqualTo('pending')
        .and()
        .createdAtBetween(startOfDay, endOfDay)
        .findAll();

    if (existingChanges.isNotEmpty) {
      logOperation('_createPendingChange', data: 'Skipped - already exists for today');
      return;
    }

    final pendingChange = PendingChange()
      ..entityType = 'problem'
      ..entityId = entityId
      ..summary = summary
      ..diffJson = diffJson
      ..createdAt = DateTime.now()
      ..status = 'pending';

    await _isar.writeTxn(() async {
      await _isar.pendingChanges.put(pendingChange);
    });

    logOperation('_createPendingChange', data: 'Created for entity $entityId: $summary');
  }

  /// Create diff JSON between two problems
  String _createDiff(Problem original, Problem updated) {
    return jsonEncode({
      'original': {
        'stem': original.stem,
        'choices': original.choices,
        'answerIndex': original.answerIndex,
        'tags': original.tags,
      },
      'updated': {
        'stem': updated.stem,
        'choices': updated.choices,
        'answerIndex': updated.answerIndex,
        'tags': updated.tags,
      },
      'changes': {
        'stemChanged': original.stem != updated.stem,
        'choicesChanged': !_listsEqual(original.choices, updated.choices),
        'answerChanged': original.answerIndex != updated.answerIndex,
        'tagsChanged': !_listsEqual(original.tags, updated.tags),
      },
    });
  }

  /// Check if two lists are equal
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  /// Delete related pending changes when a problem is deleted
  Future<void> _deleteRelatedPendingChanges(int problemId) async {
    try {
      final relatedChanges = await _isar.pendingChanges
          .filter()
          .entityTypeEqualTo('problem')
          .and()
          .entityIdEqualTo(problemId)
          .findAll();

      if (relatedChanges.isNotEmpty) {
        await _isar.writeTxn(() async {
          for (final change in relatedChanges) {
            await _isar.pendingChanges.delete(change.id);
          }
        });

        logOperation('_deleteRelatedPendingChanges', data: '${relatedChanges.length} changes deleted');
      }
    } catch (e) {
      logError('_deleteRelatedPendingChanges', e, null);
      // Don't throw - this is cleanup operation
    }
  }
}