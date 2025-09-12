import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/models/concept.dart';
import 'database_provider.dart';

/// Provides list of all concepts
final conceptsProvider = AsyncNotifierProvider<ConceptsNotifier, List<Concept>>(() {
  return ConceptsNotifier();
});

/// Provides concept search results
final conceptSearchProvider = StateProvider<String>((ref) => '');

/// Provides filtered concepts based on search query
final filteredConceptsProvider = Provider<AsyncValue<List<Concept>>>((ref) {
  final conceptsAsync = ref.watch(conceptsProvider);
  final searchQuery = ref.watch(conceptSearchProvider);
  
  return conceptsAsync.when(
    data: (concepts) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(concepts);
      }
      
      final filtered = concepts.where((concept) {
        return concept.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
               concept.body.toLowerCase().contains(searchQuery.toLowerCase()) ||
               concept.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

class ConceptsNotifier extends AsyncNotifier<List<Concept>> {
  @override
  Future<List<Concept>> build() async {
    final repository = ref.read(conceptRepositoryProvider);
    return await repository.getAll();
  }

  /// Create a new concept
  Future<void> createConcept(String title, String body, List<String> tags) async {
    final repository = ref.read(conceptRepositoryProvider);
    
    final concept = Concept()
      ..title = title
      ..body = body
      ..tags = tags;
    
    try {
      await repository.create(concept);
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update an existing concept
  Future<void> updateConcept(Concept concept) async {
    final repository = ref.read(conceptRepositoryProvider);
    
    try {
      await repository.update(concept);
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Delete a concept by ID
  Future<void> deleteConcept(int id) async {
    final repository = ref.read(conceptRepositoryProvider);
    
    try {
      await repository.delete(id);
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Get a specific concept by ID
  Future<Concept?> getConceptById(int id) async {
    final repository = ref.read(conceptRepositoryProvider);
    return await repository.getById(id);
  }

  /// Search concepts
  Future<void> searchConcepts(String query) async {
    final repository = ref.read(conceptRepositoryProvider);
    
    try {
      final results = await repository.search(query);
      state = AsyncValue.data(results);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Get concepts by tag
  Future<void> getConceptsByTag(String tag) async {
    final repository = ref.read(conceptRepositoryProvider);
    
    try {
      final results = await repository.getByTag(tag);
      state = AsyncValue.data(results);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Refresh the concepts list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provides all unique tags from concepts
final conceptTagsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.read(conceptRepositoryProvider);
  return await repository.getAllTags();
});

/// Provides concept count
final conceptCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(conceptRepositoryProvider);
  return await repository.count();
});