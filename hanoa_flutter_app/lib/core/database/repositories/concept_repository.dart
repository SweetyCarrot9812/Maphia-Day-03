import 'dart:convert';
import 'package:isar/isar.dart';
import '../database.dart';
import '../models/concept.dart';
import '../models/pending_change.dart';
import 'base_repository.dart';

class ConceptRepository extends BaseRepository<Concept> {
  static final ConceptRepository _instance = ConceptRepository._internal();
  factory ConceptRepository() => _instance;
  ConceptRepository._internal();

  Isar get _isar => Database.isar;

  @override
  Future<Concept> create(Concept concept) async {
    try {
      logOperation('create', data: concept.title);
      
      concept.updatedAt = DateTime.now();
      
      await _isar.writeTxn(() async {
        await _isar.concepts.put(concept);
      });

      logOperation('created', data: 'ID: ${concept.id}');
      return concept;
    } catch (e, stackTrace) {
      logError('create', e, stackTrace);
      throw RepositoryException('Failed to create concept', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<Concept?> getById(int id) async {
    try {
      logOperation('getById', data: id);
      return await _isar.concepts.get(id);
    } catch (e, stackTrace) {
      logError('getById', e, stackTrace);
      throw RepositoryException('Failed to get concept by ID', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<Concept>> getAll() async {
    try {
      logOperation('getAll');
      final concepts = await _isar.concepts.where().sortByUpdatedAtDesc().findAll();
      logOperation('getAll completed', data: '${concepts.length} concepts');
      return concepts;
    } catch (e, stackTrace) {
      logError('getAll', e, stackTrace);
      throw RepositoryException('Failed to get all concepts', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<Concept> update(Concept concept) async {
    try {
      logOperation('update', data: 'ID: ${concept.id}, Title: ${concept.title}');
      
      // Get the original concept for comparison
      final original = await getById(concept.id);
      
      concept.updatedAt = DateTime.now();
      
      await _isar.writeTxn(() async {
        await _isar.concepts.put(concept);
      });

      // Check if we need to create a PendingChange
      if (original != null) {
        await _checkAndCreatePendingChange(original, concept);
      }

      logOperation('updated', data: 'ID: ${concept.id}');
      return concept;
    } catch (e, stackTrace) {
      logError('update', e, stackTrace);
      throw RepositoryException('Failed to update concept', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      logOperation('delete', data: id);
      
      final success = await _isar.writeTxn(() async {
        return await _isar.concepts.delete(id);
      });

      // Also delete related pending changes
      if (success) {
        await _deleteRelatedPendingChanges(id);
      }

      logOperation('deleted', data: 'ID: $id, Success: $success');
      return success;
    } catch (e, stackTrace) {
      logError('delete', e, stackTrace);
      throw RepositoryException('Failed to delete concept', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<Concept>> search(String query) async {
    try {
      logOperation('search', data: query);
      
      if (query.trim().isEmpty) {
        return await getAll();
      }

      final concepts = await _isar.concepts
          .filter()
          .titleContains(query, caseSensitive: false)
          .or()
          .bodyContains(query, caseSensitive: false)
          .sortByUpdatedAtDesc()
          .findAll();

      logOperation('search completed', data: '${concepts.length} results for "$query"');
      return concepts;
    } catch (e, stackTrace) {
      logError('search', e, stackTrace);
      throw RepositoryException('Failed to search concepts', originalException: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<int> count() async {
    try {
      return await _isar.concepts.count();
    } catch (e, stackTrace) {
      logError('count', e, stackTrace);
      throw RepositoryException('Failed to count concepts', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Get concepts by tag
  Future<List<Concept>> getByTag(String tag) async {
    try {
      logOperation('getByTag', data: tag);
      
      final concepts = await _isar.concepts
          .filter()
          .tagsElementContains(tag, caseSensitive: false)
          .sortByUpdatedAtDesc()
          .findAll();

      logOperation('getByTag completed', data: '${concepts.length} concepts with tag "$tag"');
      return concepts;
    } catch (e, stackTrace) {
      logError('getByTag', e, stackTrace);
      throw RepositoryException('Failed to get concepts by tag', originalException: e, stackTrace: stackTrace);
    }
  }

  /// Get all unique tags
  Future<List<String>> getAllTags() async {
    try {
      logOperation('getAllTags');
      
      final concepts = await _isar.concepts.where().findAll();
      final Set<String> tagSet = {};
      
      for (final concept in concepts) {
        tagSet.addAll(concept.tags);
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
  Future<void> _checkAndCreatePendingChange(Concept original, Concept updated) async {
    try {
      // Rule 1: Same title but significant body change
      if (original.title == updated.title) {
        final originalBodyLength = original.body.length;
        final updatedBodyLength = updated.body.length;
        
        // Consider it significant if body changed by more than 20% or added/removed more than 50 characters
        final lengthDiff = (originalBodyLength - updatedBodyLength).abs();
        final percentChange = originalBodyLength > 0 ? lengthDiff / originalBodyLength : 1.0;
        
        if (percentChange > 0.2 || lengthDiff > 50) {
          await _createPendingChange(
            updated.id,
            'Body content significantly changed',
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

  /// Create a PendingChange
  Future<void> _createPendingChange(int entityId, String summary, String diffJson) async {
    // Check if there's already a pending change for this entity today
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final existingChanges = await _isar.pendingChanges
        .filter()
        .entityTypeEqualTo('concept')
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
      ..entityType = 'concept'
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

  /// Create diff JSON between two concepts
  String _createDiff(Concept original, Concept updated) {
    return jsonEncode({
      'original': {
        'title': original.title,
        'body': original.body,
        'tags': original.tags,
      },
      'updated': {
        'title': updated.title,
        'body': updated.body,
        'tags': updated.tags,
      },
      'changes': {
        'titleChanged': original.title != updated.title,
        'bodyChanged': original.body != updated.body,
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

  /// Delete related pending changes when a concept is deleted
  Future<void> _deleteRelatedPendingChanges(int conceptId) async {
    try {
      final relatedChanges = await _isar.pendingChanges
          .filter()
          .entityTypeEqualTo('concept')
          .and()
          .entityIdEqualTo(conceptId)
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