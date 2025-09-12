import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 웹이 아닌 플랫폼에서만 import
import 'package:isar/isar.dart' if (dart.library.html) 'dart:html';
import '../../core/database/database.dart' if (dart.library.html) '../../core/database/database_web.dart';

// 웹이 아닌 플랫폼에서만 repository import
import '../../core/database/repositories/concept_repository.dart' if (dart.library.html) '../stubs/concept_repository_stub.dart';
import '../../core/database/repositories/problem_repository.dart' if (dart.library.html) '../stubs/problem_repository_stub.dart';
import '../../core/database/repositories/pending_change_repository.dart' if (dart.library.html) '../stubs/pending_change_repository_stub.dart';

/// Provides access to the database instance
final databaseProvider = Provider<dynamic>((ref) {
  if (kIsWeb) {
    return null; // 웹에서는 null 반환
  }
  return Database.isar;
});

/// Provides access to the concept repository
final conceptRepositoryProvider = Provider<dynamic>((ref) {
  return ConceptRepository();
});

/// Provides access to the problem repository  
final problemRepositoryProvider = Provider<dynamic>((ref) {
  return ProblemRepository();
});

/// Provides access to the pending change repository
final pendingChangeRepositoryProvider = Provider<dynamic>((ref) {
  return PendingChangeRepository();
});