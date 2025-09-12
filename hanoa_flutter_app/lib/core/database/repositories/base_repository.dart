import 'package:logger/logger.dart';

/// Base repository interface for common CRUD operations
abstract class BaseRepository<T> {
  static final Logger logger = Logger();

  /// Create a new entity
  Future<T> create(T entity);

  /// Get entity by ID
  Future<T?> getById(int id);

  /// Get all entities
  Future<List<T>> getAll();

  /// Update an entity
  Future<T> update(T entity);

  /// Delete an entity by ID
  Future<bool> delete(int id);

  /// Search entities
  Future<List<T>> search(String query);

  /// Get count of entities
  Future<int> count();
}

/// Repository exception for error handling
class RepositoryException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const RepositoryException(
    this.message, {
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'RepositoryException: $message';
  }
}

/// Extension for logging repository operations
extension RepositoryLogger on BaseRepository {
  void logOperation(String operation, {Object? data}) {
    print('Repository ${runtimeType}: $operation${data != null ? ' - $data' : ''}');
  }

  void logError(String operation, dynamic error, StackTrace? stackTrace) {
    print('Repository ${runtimeType}: $operation failed - $error');
  }
}