// auth_state_provider.dart
// Convenience provider: returns AtheraUser? (null if not logged in)
// This makes it easy to just listen to the user object directly.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// Export AtheraUser and AuthState for easy imports across the app
export 'auth_provider.dart' show AtheraUser, AuthState, AuthAuthenticated,
    AuthInitial, AuthLoading, AuthError;

final authStateProvider = Provider<AtheraUser?>((ref) {
  final state = ref.watch(authProvider);
  if (state is AuthAuthenticated) return state.user;
  return null;
});
