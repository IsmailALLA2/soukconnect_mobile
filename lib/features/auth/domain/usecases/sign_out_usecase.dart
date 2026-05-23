import '../repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SignOutUseCase
// ─────────────────────────────────────────────────────────────────────────────

class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  /// Signs out the current user and invalidates the session.
  Future<void> call() => _repository.signOut();
}
