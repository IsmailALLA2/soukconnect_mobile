import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_config.dart';
import '../../../../core/utils/failure.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

part 'auth_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the concrete [AuthRepository] implementation.
/// Swap [AuthRepositoryImpl] for a fake/mock here during testing.
@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) =>
    AuthRepositoryImpl();

// ─────────────────────────────────────────────────────────────────────────────
// Raw Supabase auth stream — used by GoRouter's refreshListenable
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Stream<AuthState> authStateStream(AuthStateStreamRef ref) =>
    supabase.auth.onAuthStateChange;

// ─────────────────────────────────────────────────────────────────────────────
// Auth notifier — holds UserEntity? as async state
// ─────────────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  // Lazily constructed use-cases (resolved via provider).
  late final SignInUseCase       _signIn;
  late final SignUpUseCase       _signUp;
  late final SignOutUseCase      _signOut;
  late final GetCurrentUserUseCase _getUser;

  @override
  Future<UserEntity?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    _signIn  = SignInUseCase(repo);
    _signUp  = SignUpUseCase(repo);
    _signOut = SignOutUseCase(repo);
    _getUser = GetCurrentUserUseCase(repo);

    // Re-run when auth session changes (sign-in / sign-out / token refresh).
    ref.watch(authStateStreamProvider);

    return _getUser();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Signs the user in. Sets state to [AsyncLoading] then [AsyncData] or
  /// [AsyncError] wrapping a [Failure].
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _signIn(email: email, password: password),
    );
  }

  /// Registers a new user and immediately signs them in.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String wilaya,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _signUp(SignUpParams(
        email:    email,
        password: password,
        fullName: fullName,
        phone:    phone,
        wilaya:   wilaya,
        role:     role,
      )),
    );
  }

  /// Signs out and clears the state.
  Future<void> signOut() async {
    state = const AsyncLoading();
    await AsyncValue.guard(_signOut.call);
    state = const AsyncData(null);
  }

  // ── Convenience getters ───────────────────────────────────────────────────

  /// `true` when a user is currently signed in.
  bool get isAuthenticated => state.valueOrNull != null;

  /// The current [UserEntity] or `null`.
  UserEntity? get currentUser => state.valueOrNull;
}

// ─────────────────────────────────────────────────────────────────────────────
// RouterRefreshNotifier
// Notifies GoRouter to re-run redirect whenever the auth state changes.
// ─────────────────────────────────────────────────────────────────────────────

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();

  RouterRefreshNotifier(Ref ref) {
    // 1. Fires on Supabase auth events (sign-in, sign-out, token refresh).
    ref.listen<AsyncValue<AuthState>>(
      authStateStreamProvider,
      (_, __) => notifyListeners(),
    );

    // 2. Fires when authNotifierProvider finishes its initial build()
    //    (i.e. getCurrentUser() completes). Without this, the router
    //    never re-runs redirect after the splash → app gets stuck.
    ref.listen<AsyncValue<UserEntity?>>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
}
