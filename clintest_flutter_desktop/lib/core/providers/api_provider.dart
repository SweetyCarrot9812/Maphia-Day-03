import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

// API 클라이언트 프로바이더
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// 앱 상태 관리
class AppState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  const AppState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setUser(Map<String, dynamic>? user) {
    state = state.copyWith(user: user);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// 앱 상태 프로바이더
final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});