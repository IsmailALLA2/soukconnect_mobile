import '../entities/user_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthRepository — domain contract
//
// Implementations live in the data layer. This interface never imports
// Supabase, http, or any external package.
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class AuthRepository {
  /// Signs in with [email] and [password].
  ///
  /// Returns the authenticated [UserEntity] on success.
  /// Throws a [Failure] subclass on error.
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Creates a new account and profile row in `public.profiles`.
  ///
  /// [role] must be 'detaillant' or 'grossiste'.
  /// Throws a [Failure] subclass on error.
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String wilaya,
    required UserRole role,
  });

  /// Signs out the currently authenticated user.
  Future<void> signOut();

  /// Returns the currently authenticated [UserEntity], or `null` if
  /// no session is active. Fetches the full profile from `public.profiles`.
  Future<UserEntity?> getCurrentUser();
}
