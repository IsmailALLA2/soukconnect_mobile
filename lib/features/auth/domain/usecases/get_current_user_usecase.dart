import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GetCurrentUserUseCase
// ─────────────────────────────────────────────────────────────────────────────

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  /// Returns the currently authenticated [UserEntity], or `null` if
  /// no session is active.
  ///
  /// Throws a [Failure] subclass on network / server error.
  Future<UserEntity?> call() => _repository.getCurrentUser();
}
