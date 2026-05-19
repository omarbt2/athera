import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton pattern
  SupabaseService._privateConstructor();
  static final SupabaseService _instance = SupabaseService._privateConstructor();
  static SupabaseService get instance => _instance;

  // Expose supabase client getter
  final SupabaseClient client = Supabase.instance.client;

  // Sign In
  Future<String?> signInWithEmail({required String email, required String password}) async {
    try {
      await client.auth.signInWithPassword(email: email, password: password);
      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred during sign in.';
    }
  }

  // Sign Up
  Future<String?> signUpWithEmail({required String email, required String password}) async {
    try {
      await client.auth.signUp(email: email, password: password);
      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred during sign up.';
    }
  }

  // Sign Out
  Future<String?> signOut() async {
    try {
      await client.auth.signOut();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred during sign out.';
    }
  }

  // Get Current User
  User? getCurrentUser() {
    return client.auth.currentUser;
  }
}
