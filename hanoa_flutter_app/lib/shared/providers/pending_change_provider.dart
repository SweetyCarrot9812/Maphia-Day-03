import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/models/pending_change.dart';
import 'database_provider.dart';
import 'concept_provider.dart';
import 'problem_provider.dart';

/// Provides list of all pending changes
final pendingChangesProvider = AsyncNotifierProvider<PendingChangesNotifier, List<PendingChange>>(() {
  return PendingChangesNotifier();
});

/// Provides only pending (not expired, approved, or rejected) changes
final activePendingChangesProvider = FutureProvider<List<PendingChange>>((ref) async {
  final repository = ref.read(pendingChangeRepositoryProvider);
  return await repository.getPending();
});

/// Provides pending changes count for badge display
final pendingChangesCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(pendingChangeRepositoryProvider);
  return await repository.getPendingCount();
});

/// Provides pending changes for a specific entity
final entityPendingChangesProvider = FutureProviderFamily<List<PendingChange>, ({String entityType, int entityId})>((ref, params) async {
  final repository = ref.read(pendingChangeRepositoryProvider);
  return await repository.getPendingForEntity(params.entityType, params.entityId);
});

class PendingChangesNotifier extends AsyncNotifier<List<PendingChange>> {
  @override
  Future<List<PendingChange>> build() async {
    final repository = ref.read(pendingChangeRepositoryProvider);
    return await repository.getAll();
  }

  /// Create a new pending change (usually done automatically by repositories)
  Future<void> createPendingChange(String entityType, int entityId, String summary, String diffJson) async {
    final repository = ref.read(pendingChangeRepositoryProvider);
    
    final pendingChange = PendingChange()
      ..entityType = entityType
      ..entityId = entityId
      ..summary = summary
      ..diffJson = diffJson
      ..createdAt = DateTime.now()
      ..status = 'pending';
    
    try {
      await repository.create(pendingChange);
      await refresh();
      // Also refresh the pending count
      ref.invalidate(pendingChangesCountProvider);
      ref.invalidate(activePendingChangesProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Approve a pending change and apply it to the original entity
  Future<bool> approvePendingChange(int changeId) async {
    final repository = ref.read(pendingChangeRepositoryProvider);
    
    try {
      final success = await repository.approve(changeId);
      if (success) {
        await refresh();
        // Refresh related providers
        ref.invalidate(pendingChangesCountProvider);
        ref.invalidate(activePendingChangesProvider);
        // Refresh the entities that might have been modified
        ref.invalidate(conceptsProvider);
        ref.invalidate(problemsProvider);
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Reject a pending change
  Future<bool> rejectPendingChange(int changeId) async {
    final repository = ref.read(pendingChangeRepositoryProvider);
    
    try {
      final success = await repository.reject(changeId);
      if (success) {
        await refresh();
        // Refresh related providers
        ref.invalidate(pendingChangesCountProvider);
        ref.invalidate(activePendingChangesProvider);
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Get a specific pending change by ID
  Future<PendingChange?> getPendingChangeById(int id) async {
    final repository = ref.read(pendingChangeRepositoryProvider);
    return await repository.getById(id);
  }

  /// Search pending changes by summary
  Future<void> searchPendingChanges(String query) async {
    final repository = ref.read(pendingChangeRepositoryProvider);
    
    try {
      final results = await repository.search(query);
      state = AsyncValue.data(results);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Get pending changes by status
  Future<void> getPendingChangesByStatus(String status) async {
    final repository = ref.read(pendingChangeRepositoryProvider);
    
    try {
      final results = await repository.getByStatus(status);
      state = AsyncValue.data(results);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Clean up expired changes (this should be called periodically)
  Future<int> cleanupExpiredChanges() async {
    final repository = ref.read(pendingChangeRepositoryProvider);
    
    try {
      final expiredCount = await repository.cleanupExpired();
      if (expiredCount > 0) {
        await refresh();
        // Refresh related providers
        ref.invalidate(pendingChangesCountProvider);
        ref.invalidate(activePendingChangesProvider);
      }
      return expiredCount;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return 0;
    }
  }

  /// Refresh the pending changes list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider for managing periodic cleanup of expired changes
final pendingChangeCleanupProvider = Provider<void>((ref) {
  // This could be used to schedule periodic cleanup
  // For now, it's just a placeholder
  // In a real app, you might use a Timer or background service
  return;
});