import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_config.dart';

part 'auth_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth state stream — re-emits on every Supabase auth event
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Stream<AuthState> authStateStream(AuthStateStreamRef ref) =>
    supabase.auth.onAuthStateChange;

// ─────────────────────────────────────────────────────────────────────────────
// Current user — synchronous snapshot
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
User? currentUser(CurrentUserRef ref) {
  // Invalidate whenever auth state changes.
  ref.watch(authStateStreamProvider);
  return supabase.auth.currentUser;
}

// ─────────────────────────────────────────────────────────────────────────────
// User role — fetched once per session from the `profiles` table
// ─────────────────────────────────────────────────────────────────────────────

/// Expected values: 'detaillant' | 'grossiste'
@riverpod
Future<String?> userRole(UserRoleRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final response = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .maybeSingle();

  return response?['role'] as String?;
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth notifier — exposes sign-in / sign-out actions
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<User?> build() {
    // Mirror the current user as state.
    ref.watch(authStateStreamProvider);
    return AsyncData(supabase.auth.currentUser);
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role, // 'detaillant' | 'grossiste'
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone, 'role': role},
      );
      return response.user;
    });
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RouterRefreshNotifier
// Used by GoRouter's refreshListenable to re-run redirect on auth changes.
// ─────────────────────────────────────────────────────────────────────────────

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<AuthState>>(
      authStateStreamProvider,
      (_, __) => notifyListeners(),
    );
  }
}
