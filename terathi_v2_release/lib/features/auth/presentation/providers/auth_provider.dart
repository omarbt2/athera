import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
// Model — wraps Supabase User + profile data
// ─────────────────────────────────────────────

class AtheraUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? wilaya;
  final DateTime? joinDate;

  const AtheraUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.wilaya,
    this.joinDate,
  });

  AtheraUser copyWith({
    String? name,
    String? avatarUrl,
    String? wilaya,
  }) {
    return AtheraUser(
      id: id,
      name: name ?? this.name,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      wilaya: wilaya ?? this.wilaya,
      joinDate: joinDate,
    );
  }
}

// ─────────────────────────────────────────────
// States
// ─────────────────────────────────────────────

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AtheraUser user;
  const AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ─────────────────────────────────────────────
// Notifier — uses Supabase Auth
// ─────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _client;

  AuthNotifier(this._client) : super(const AuthInitial()) {
    _restoreSession();
    // Listen to Supabase auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        if (mounted) state = const AuthInitial();
      } else if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        _fetchAndSetUser(data.session!.user);
      } else if (data.event == AuthChangeEvent.tokenRefreshed && data.session != null) {
        _fetchAndSetUser(data.session!.user);
      }
    });
  }

  void _restoreSession() {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      _fetchAndSetUser(currentUser);
    }
  }

  Future<void> _fetchAndSetUser(User supabaseUser) async {
    try {
      // Fetch profile from Supabase
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', supabaseUser.id)
          .maybeSingle();

      final user = AtheraUser(
        id: supabaseUser.id,
        name: (profileData?['full_name'] as String?) ??
            (profileData?['username'] as String?) ??
            supabaseUser.userMetadata?['full_name'] as String? ??
            supabaseUser.email?.split('@').first ??
            'مستخدم',
        email: supabaseUser.email ?? '',
        avatarUrl: profileData?['avatar_url'] as String?,
        wilaya: profileData?['wilaya'] as String?,
        joinDate: supabaseUser.createdAt != null
            ? DateTime.tryParse(supabaseUser.createdAt!)
            : null,
      );

      if (mounted) state = AuthAuthenticated(user);
    } catch (_) {
      // Even if profile fetch fails, set authenticated with basic info
      final user = AtheraUser(
        id: supabaseUser.id,
        name: supabaseUser.userMetadata?['full_name'] as String? ??
            supabaseUser.email?.split('@').first ??
            'مستخدم',
        email: supabaseUser.email ?? '',
        joinDate: supabaseUser.createdAt != null
            ? DateTime.tryParse(supabaseUser.createdAt!)
            : null,
      );
      if (mounted) state = AuthAuthenticated(user);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);
      if (response.user != null) {
        await _fetchAndSetUser(response.user!);
      } else {
        state = const AuthError('فشل تسجيل الدخول');
      }
    } on AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
    } catch (e) {
      state = AuthError('حدث خطأ غير متوقع. حاول مجدداً.');
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://vrzfzwueemlkfewpbxjs.supabase.co/auth/v1/callback',
      );
    } on AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
    } catch (e) {
      state = const AuthError('حدث خطأ أثناء تسجيل الدخول بحساب جوجل');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      state = const AuthError('كلمتا المرور غير متطابقتين');
      return;
    }
    if (password.length < 8) {
      state = const AuthError('كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل');
      return;
    }

    state = const AuthLoading();
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (response.user != null) {
        // Create profile row
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': name,
          'email': email,
        });
        await _fetchAndSetUser(response.user!);
      } else {
        state = const AuthError('تم الإرسال — تحقق من بريدك الإلكتروني للتأكيد');
      }
    } on AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
    } catch (e) {
      state = AuthError('حدث خطأ غير متوقع. حاول مجدداً.');
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = const AuthLoading();
    try {
      await _client.auth.resetPasswordForEmail(email);
      state = const AuthInitial();
      return true;
    } on AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
      return false;
    } catch (_) {
      state = const AuthError('حدث خطأ. حاول مجدداً.');
      return false;
    }
  }

  Future<String?> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.length < 8) {
      return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل';
    }
    if (newPassword != confirmPassword) {
      return 'كلمتا المرور غير متطابقتين';
    }
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return null; // success
    } on AuthException catch (e) {
      return _mapAuthError(e.message);
    } catch (_) {
      return 'حدث خطأ. حاول مجدداً.';
    }
  }

  Future<String?> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? wilaya,
  }) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return 'غير مسجّل الدخول';

    try {
      final updates = <String, dynamic>{
        'id': currentState.user.id,
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (wilaya != null) 'wilaya': wilaya,
      };
      await _client.from('profiles').upsert(updates);

      // Optimistic update
      state = AuthAuthenticated(currentState.user.copyWith(
        name: fullName,
        avatarUrl: avatarUrl,
        wilaya: wilaya,
      ));
      return null; // success
    } catch (e) {
      return 'فشل تحديث الملف الشخصي';
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
    state = const AuthInitial();
  }

  bool get isAuthenticated => state is AuthAuthenticated;

  String _mapAuthError(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('invalid login') || m.contains('invalid credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (m.contains('email already')) return 'هذا البريد الإلكتروني مسجّل مسبقاً';
    if (m.contains('weak password')) return 'كلمة المرور ضعيفة جداً';
    if (m.contains('user not found')) return 'المستخدم غير موجود';
    if (m.contains('network')) return 'تحقق من اتصالك بالإنترنت';
    return msg;
  }
}

// ─────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(Supabase.instance.client),
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});
