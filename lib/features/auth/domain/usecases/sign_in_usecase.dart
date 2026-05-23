import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SignInUseCase
// ─────────────────────────────────────────────────────────────────────────────

class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  /// Signs the user in with [email] and [password].
  ///
  /// Throws a [Failure] subclass on error.
  Future<UserEntity> call({
    required String email,
    required String password,
  }) =>
      _repository.signIn(email: email, password: password);
}
