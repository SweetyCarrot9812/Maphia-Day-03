import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide state management for UI and navigation

/// Current screen/route state
enum AppScreen {
  onboarding,
  home,
  conceptList,
  conceptEdit,
  problemList,
  problemEdit,
  settings,
  pendingChanges,
}

/// Current app screen provider
final currentScreenProvider = StateProvider<AppScreen>((ref) => AppScreen.onboarding);

/// Onboarding completion state
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

/// Onboarding current turn (1-7)
final onboardingTurnProvider = StateProvider<int>((ref) => 1);

/// Settings state
class SettingsState {
  final bool syncEnabled;
  final bool notificationsEnabled;
  final String theme;
  
  const SettingsState({
    this.syncEnabled = false,
    this.notificationsEnabled = true,
    this.theme = 'system',
  });
  
  SettingsState copyWith({
    bool? syncEnabled,
    bool? notificationsEnabled,
    String? theme,
  }) {
    return SettingsState(
      syncEnabled: syncEnabled ?? this.syncEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      theme: theme ?? this.theme,
    );
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());
  
  void toggleSync() {
    state = state.copyWith(syncEnabled: !state.syncEnabled);
  }
  
  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }
  
  void setTheme(String theme) {
    state = state.copyWith(theme: theme);
  }
}

/// Loading states for different operations
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Error message provider for displaying errors to user
final errorMessageProvider = StateProvider<String?>((ref) => null);

/// Success message provider for displaying success messages
final successMessageProvider = StateProvider<String?>((ref) => null);