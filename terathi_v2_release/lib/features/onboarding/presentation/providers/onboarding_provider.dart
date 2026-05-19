import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

class OnboardingState {
  final bool isCompleted;
  final bool isLoading;

  const OnboardingState({
    required this.isCompleted,
    required this.isLoading,
  });

  OnboardingState copyWith({bool? isCompleted, bool? isLoading}) =>
      OnboardingState(
        isCompleted: isCompleted ?? this.isCompleted,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const _prefKey = 'onboarding_done';

  OnboardingNotifier()
      : super(const OnboardingState(isCompleted: false, isLoading: true)) {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_prefKey) ?? false;
    state = OnboardingState(isCompleted: done, isLoading: false);
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    state = state.copyWith(isCompleted: true);
  }

  /// For testing: reset onboarding flag.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    state = state.copyWith(isCompleted: false);
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
