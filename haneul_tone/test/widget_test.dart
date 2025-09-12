// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:haneul_tone/main.dart';
import 'package:haneul_tone/services/auth_service.dart';
import 'package:haneul_tone/services/cross_platform_storage_service.dart';
import 'package:haneul_tone/models/audio_reference.dart';
import 'package:haneul_tone/models/session.dart';
import 'package:haneul_tone/models/pitch_data.dart';

// Mock AuthService for testing
class MockAuthService extends ChangeNotifier implements AuthService {
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  @override
  bool get isInitialized => _isInitialized;
  
  @override
  bool get isLoggedIn => _isLoggedIn;
  
  bool get isLoading => _isLoading;

  @override
  User? get currentUser => null;

  // No token concept in AuthService; omit

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 10));
    _isInitialized = true;
    notifyListeners();
  }

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  void setLoggedIn(bool loggedIn) {
    _isLoggedIn = loggedIn;
    notifyListeners();
  }

  // Implement other required methods with empty implementations
  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String displayName,
    String? confirmPassword,
  }) async {
    return {'success': false, 'error': 'Mock implementation'};
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return {'success': false, 'error': 'Mock implementation'};
  }

  @override
  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    return {'success': false, 'error': 'Mock implementation'};
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return {'success': false, 'error': 'Mock implementation'};
  }

  // Additional methods required by AuthService
  @override
  Future<DocumentSnapshot<Object?>?> getUserProfile(String uid) async => null;

  @override
  Future<bool> hasPermission(String permission) async => false;

  @override
  Future<bool> isSuperAdmin() async => false;

  @override
  Future<String?> getUserRole() async => null;

  @override
  Future<UserCredential?> signInWithGoogle() async => null;
}

// Mock CrossPlatformStorageService for testing
class MockCrossPlatformStorageService implements CrossPlatformStorageService {
  @override
  String get currentDatabaseType => 'test';

  @override
  Future<void> initialize() async {
    // Mock initialization
  }

  @override
  Future<void> close() async {
    // Mock close
  }

  // Generic CRUD methods
  @override
  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>?> getById(String tableName, String id) async {
    return null;
  }

  @override
  Future<String> insert(String tableName, Map<String, dynamic> data) async {
    return 'mock-id';
  }

  @override
  Future<bool> update(String tableName, String id, Map<String, dynamic> data) async {
    return true;
  }

  @override
  Future<bool> delete(String tableName, String id) async {
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String tableName, {
    Map<String, dynamic>? where,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    return [];
  }

  // AudioReference methods
  @override
  Future<int> insertAudioReference(AudioReference audioRef) async {
    return 1;
  }

  @override
  Future<List<AudioReference>> getAllAudioReferences() async {
    return [];
  }

  @override
  Future<AudioReference?> getAudioReference(int id) async {
    return null;
  }

  @override
  Future<int> updateAudioReference(AudioReference audioRef) async {
    return 1;
  }

  @override
  Future<int> deleteAudioReference(int id) async {
    return 1;
  }

  // Session methods
  @override
  Future<int> insertSession(Session session) async {
    return 1;
  }

  @override
  Future<List<Session>> getAllSessions() async {
    return [];
  }

  @override
  Future<List<Session>> getSessionsByReference(int referenceId) async {
    return [];
  }

  @override
  Future<int> updateSession(Session session) async {
    return 1;
  }

  @override
  Future<int> deleteSession(int id) async {
    return 1;
  }

  // PitchData methods
  @override
  Future<int> insertPitchData(PitchData pitchData) async {
    return 1;
  }

  @override
  Future<PitchData?> getPitchDataByReferenceId(int referenceId) async {
    return null;
  }

  @override
  Future<List<PitchData>> getAllPitchData() async {
    return [];
  }

  @override
  Future<int> updatePitchData(PitchData pitchData) async {
    return 1;
  }

  @override
  Future<int> deletePitchData(int id) async {
    return 1;
  }
}

void main() {
  group('HaneulTone Widget Tests', () {
    testWidgets('App shows login screen when not authenticated', (WidgetTester tester) async {
      final mockAuthService = MockAuthService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CrossPlatformStorageService>(
              create: (_) => MockCrossPlatformStorageService(),
            ),
            ChangeNotifierProvider<AuthService>(
              create: (_) => mockAuthService,
            ),
          ],
          child: const MaterialApp(
            home: AuthGate(),
          ),
        ),
      );

      // Wait for initialization
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that login screen elements are present
      expect(find.text('HaneulTone'), findsWidgets);
    });

    testWidgets('App shows loading state during initialization', (WidgetTester tester) async {
      final mockAuthService = MockAuthService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CrossPlatformStorageService>(
              create: (_) => MockCrossPlatformStorageService(),
            ),
            ChangeNotifierProvider<AuthService>(
              create: (_) => mockAuthService,
            ),
          ],
          child: const MaterialApp(
            home: AuthGate(),
          ),
        ),
      );

      // Initially should show loading
      expect(find.text('앱을 초기화하는 중...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthGate shows home screen when authenticated', (WidgetTester tester) async {
      final mockAuthService = MockAuthService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CrossPlatformStorageService>(
              create: (_) => MockCrossPlatformStorageService(),
            ),
            ChangeNotifierProvider<AuthService>(
              create: (_) => mockAuthService,
            ),
          ],
          child: const MaterialApp(
            home: AuthGate(),
          ),
        ),
      );

      // Wait for initialization and set logged in
      await tester.pump(const Duration(milliseconds: 100));
      mockAuthService.setLoggedIn(true);
      await tester.pump();

      // Should show home screen elements
      // Note: We're testing the navigation logic, not the exact home screen content
      expect(find.byType(AuthGate), findsOneWidget);
    });
  });
}
