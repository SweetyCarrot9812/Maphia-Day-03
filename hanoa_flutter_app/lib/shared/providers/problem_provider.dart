import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/models/problem.dart';
import 'database_provider.dart';

/// Provides list of all problems
final problemsProvider = AsyncNotifierProvider<ProblemsNotifier, List<Problem>>(() {
  return ProblemsNotifier();
});

/// Provides problem search results
final problemSearchProvider = StateProvider<String>((ref) => '');

/// Provides filtered problems based on search query
final filteredProblemsProvider = Provider<AsyncValue<List<Problem>>>((ref) {
  final problemsAsync = ref.watch(problemsProvider);
  final searchQuery = ref.watch(problemSearchProvider);
  
  return problemsAsync.when(
    data: (problems) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(problems);
      }
      
      final filtered = problems.where((problem) {
        return problem.stem.toLowerCase().contains(searchQuery.toLowerCase()) ||
               problem.choices.any((choice) => choice.toLowerCase().contains(searchQuery.toLowerCase())) ||
               problem.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

class ProblemsNotifier extends AsyncNotifier<List<Problem>> {
  @override
  Future<List<Problem>> build() async {
    final repository = ref.read(problemRepositoryProvider);
    return await repository.getAll();
  }

  /// Create a new problem
  Future<void> createProblem(String stem, List<String> choices, int answerIndex, List<String> tags) async {
    final repository = ref.read(problemRepositoryProvider);
    
    final problem = Problem()
      ..stem = stem
      ..choices = choices
      ..answerIndex = answerIndex
      ..tags = tags;
    
    try {
      await repository.create(problem);
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update an existing problem
  Future<void> updateProblem(Problem problem) async {
    final repository = ref.read(problemRepositoryProvider);
    
    try {
      await repository.update(problem);
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Delete a problem by ID
  Future<void> deleteProblem(int id) async {
    final repository = ref.read(problemRepositoryProvider);
    
    try {
      await repository.delete(id);
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Get a specific problem by ID
  Future<Problem?> getProblemById(int id) async {
    final repository = ref.read(problemRepositoryProvider);
    return await repository.getById(id);
  }

  /// Search problems
  Future<void> searchProblems(String query) async {
    final repository = ref.read(problemRepositoryProvider);
    
    try {
      final results = await repository.search(query);
      state = AsyncValue.data(results);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Get problems by tag
  Future<void> getProblemsByTag(String tag) async {
    final repository = ref.read(problemRepositoryProvider);
    
    try {
      final results = await repository.getByTag(tag);
      state = AsyncValue.data(results);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Refresh the problems list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provides all unique tags from problems
final problemTagsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.read(problemRepositoryProvider);
  return await repository.getAllTags();
});

/// Provides problem count
final problemCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(problemRepositoryProvider);
  return await repository.count();
});