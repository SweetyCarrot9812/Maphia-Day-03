import 'dart:convert';
import 'package:isar/isar.dart';
import '../database.dart';
import '../models/pending_change.dart';
import '../models/concept.dart';
import '../models/problem.dart';
import 'base_repository.dart';

class PendingChangeRepository extends BaseRepository<PendingChange> {
  static final PendingChangeRepository _instance = PendingChangeRepository._internal();
  factory PendingChangeRepository() => _instance;
  PendingChangeRepository._internal();

  Isar get _isar => Database.isar;

  @override
  Future<PendingChange> create(PendingChange change) async {
    try {
      logOperation('create', data: '${change.entityType}:${change.entityId} - ${change.summary}');
      
      change.createdAt = DateTime.now();
      
      await _isar.writeTxn(() async {
        await _isar.pendingChanges.put(change);
      });

      logOperation('created', data: 'ID: ${change.id}');
      return change;
    } catch (e, stackTrace) {
      logError('create', e, stackTrace);
      throw RepositoryException('Failed to create pending change', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<PendingChange?> getById(int id) async {
    try {
      logOperation('getById', data: id);
      return await _isar.pendingChanges.get(id);
    } catch (e, stackTrace) {
      logError('getById', e, stackTrace);
      throw RepositoryException('Failed to get pending change by ID', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<PendingChange>> getAll() async {
    try {
      logOperation('getAll');
      final changes = await _isar.pendingChanges.where().sortByCreatedAtDesc().findAll();
      logOperation('getAll completed', data: '${changes.length} pending changes');
      return changes;
    } catch (e, stackTrace) {
      logError('getAll', e, stackTrace);
      throw RepositoryException('Failed to get all pending changes', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<PendingChange> update(PendingChange change) async {
    try {
      logOperation('update', data: 'ID: ${change.id}, Status: ${change.status}');
      
      await _isar.writeTxn(() async {
        await _isar.pendingChanges.put(change);
      });

      logOperation('updated', data: 'ID: ${change.id}');
      return change;
    } catch (e, stackTrace) {
      logError('update', e, stackTrace);
      throw RepositoryException('Failed to update pending change', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      logOperation('delete', data: id);
      
      final success = await _isar.writeTxn(() async {
        return await _isar.pendingChanges.delete(id);
      });

      logOperation('deleted', data: 'ID: $id, Success: $success');
      return success;
    } catch (e, stackTrace) {
      logError('delete', e, stackTrace);
      throw RepositoryException('Failed to delete pending change', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<PendingChange>> search(String query) async {
    try {
      logOperation('search', data: query);
      
      if (query.trim().isEmpty) {
        return await getAll();
      }

      final changes = await _isar.pendingChanges
          .filter()
          .summaryContains(query, caseSensitive: false)
          .sortByCreatedAtDesc()
          .findAll();

      logOperation('search completed', data: '${changes.length} results for "$query"');
      return changes;
    } catch (e, stackTrace) {
      logError('search', e, stackTrace);
      throw RepositoryException('Failed to search pending changes', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<int> count() async {
    try {
      return await _isar.pendingChanges.count();
    } catch (e, stackTrace) {
      logError('count', e, stackTrace);
      throw RepositoryException('Failed to count pending changes', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Get only pending (not expired, approved, or rejected) changes
  Future<List<PendingChange>> getPending() async {
    try {
      logOperation('getPending');
      
      final changes = await _isar.pendingChanges
          .filter()
          .statusEqualTo('pending')
          .sortByCreatedAtDesc()
          .findAll();

      // Filter out expired changes
      final pendingChanges = changes.where((change) => !change.isExpired).toList();
      
      logOperation('getPending completed', data: '${pendingChanges.length} pending changes');
      return pendingChanges;
    } catch (e, stackTrace) {
      logError('getPending', e, stackTrace);
      throw RepositoryException('Failed to get pending changes', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Get pending changes count for badge display
  Future<int> getPendingCount() async {
    try {
      final pendingChanges = await getPending();
      return pendingChanges.length;
    } catch (e, stackTrace) {
      logError('getPendingCount', e, stackTrace);
      return 0; // Return 0 on error to prevent UI issues
    }
  }

  /// Get pending changes for a specific entity
  Future<List<PendingChange>> getPendingForEntity(String entityType, int entityId) async {
    try {
      logOperation('getPendingForEntity', data: '$entityType:$entityId');
      
      final changes = await _isar.pendingChanges
          .filter()
          .entityTypeEqualTo(entityType)
          .and()
          .entityIdEqualTo(entityId)
          .and()
          .statusEqualTo('pending')
          .sortByCreatedAtDesc()
          .findAll();

      // Filter out expired changes
      final pendingChanges = changes.where((change) => !change.isExpired).toList();
      
      logOperation('getPendingForEntity completed', data: '${pendingChanges.length} pending changes for $entityType:$entityId');
      return pendingChanges;
    } catch (e, stackTrace) {
      logError('getPendingForEntity', e, stackTrace);
      throw RepositoryException('Failed to get pending changes for entity', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Approve a pending change and apply it to the original entity
  Future<bool> approve(int changeId) async {
    try {
      logOperation('approve', data: changeId);
      
      final change = await getById(changeId);
      if (change == null || !change.isPending) {
        logOperation('approve failed', data: 'Change not found or not pending');
        return false;
      }

      // Parse the diff to get the updated data
      final diff = jsonDecode(change.diffJson) as Map<String, dynamic>;
      final updatedData = diff['updated'] as Map<String, dynamic>?;
      
      if (updatedData == null) {
        logOperation('approve failed', data: 'No updated data in diff');
        return false;
      }

      // Apply the changes to the original entity
      bool applied = false;
      if (change.entityType == 'concept') {
        applied = await _applyConceptChanges(change.entityId, updatedData);
      } else if (change.entityType == 'problem') {
        applied = await _applyProblemChanges(change.entityId, updatedData);
      }

      if (applied) {
        // Update the change status
        change.status = 'approved';
        await update(change);
        logOperation('approved', data: 'ID: $changeId');
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      logError('approve', e, stackTrace);
      throw RepositoryException('Failed to approve pending change', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Reject a pending change
  Future<bool> reject(int changeId) async {
    try {
      logOperation('reject', data: changeId);
      
      final change = await getById(changeId);
      if (change == null || !change.isPending) {
        logOperation('reject failed', data: 'Change not found or not pending');
        return false;
      }

      // Update the change status
      change.status = 'rejected';
      await update(change);
      
      logOperation('rejected', data: 'ID: $changeId');
      return true;
    } catch (e, stackTrace) {
      logError('reject', e, stackTrace);
      throw RepositoryException('Failed to reject pending change', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Clean up expired changes (called by background task)
  Future<int> cleanupExpired() async {
    try {
      logOperation('cleanupExpired');
      
      final pendingChanges = await _isar.pendingChanges
          .filter()
          .statusEqualTo('pending')
          .findAll();

      final expiredChanges = pendingChanges.where((change) => change.isExpired).toList();
      
      if (expiredChanges.isNotEmpty) {
        await _isar.writeTxn(() async {
          for (final change in expiredChanges) {
            change.status = 'expired';
            await _isar.pendingChanges.put(change);
          }
        });

        logOperation('cleanupExpired completed', data: '${expiredChanges.length} changes expired');
      }

      return expiredChanges.length;
    } catch (e, stackTrace) {
      logError('cleanupExpired', e, stackTrace);
      throw RepositoryException('Failed to cleanup expired changes', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Apply changes to a concept
  Future<bool> _applyConceptChanges(int conceptId, Map<String, dynamic> updatedData) async {
    try {
      final concept = await _isar.concepts.get(conceptId);
      if (concept == null) return false;

      // Apply the updated data
      if (updatedData.containsKey('title')) {
        concept.title = updatedData['title'] as String;
      }
      if (updatedData.containsKey('body')) {
        concept.body = updatedData['body'] as String;
      }
      if (updatedData.containsKey('tags')) {
        concept.tags = List<String>.from(updatedData['tags'] as List);
      }
      
      concept.updatedAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.concepts.put(concept);
      });

      return true;
    } catch (e) {
      logError('_applyConceptChanges', e, null);
      return false;
    }
  }

  /// Apply changes to a problem
  Future<bool> _applyProblemChanges(int problemId, Map<String, dynamic> updatedData) async {
    try {
      final problem = await _isar.problems.get(problemId);
      if (problem == null) return false;

      // Apply the updated data
      if (updatedData.containsKey('stem')) {
        problem.stem = updatedData['stem'] as String;
      }
      if (updatedData.containsKey('choices')) {
        problem.choices = List<String>.from(updatedData['choices'] as List);
      }
      if (updatedData.containsKey('answerIndex')) {
        problem.answerIndex = updatedData['answerIndex'] as int;
      }
      if (updatedData.containsKey('tags')) {
        problem.tags = List<String>.from(updatedData['tags'] as List);
      }
      
      problem.updatedAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.problems.put(problem);
      });

      return true;
    } catch (e) {
      logError('_applyProblemChanges', e, null);
      return false;
    }
  }

  /// Get changes by status
  Future<List<PendingChange>> getByStatus(String status) async {
    try {
      logOperation('getByStatus', data: status);
      
      final changes = await _isar.pendingChanges
          .filter()
          .statusEqualTo(status)
          .sortByCreatedAtDesc()
          .findAll();

      logOperation('getByStatus completed', data: '${changes.length} changes with status "$status"');
      return changes;
    } catch (e, stackTrace) {
      logError('getByStatus', e, stackTrace);
      throw RepositoryException('Failed to get changes by status', originalException: e, stackTrace: stackTrace);
    }
  }
}