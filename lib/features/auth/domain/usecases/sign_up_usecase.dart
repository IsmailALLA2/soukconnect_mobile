import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SignUpParams — groups all registration inputs
// ─────────────────────────────────────────────────────────────────────────────

class SignUpParams {
  const SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.wilaya,
    required this.role,
  });

  final String   email;
  final String   password;
  final String   fullName;
  final String   phone;
  final String   wilaya;
  final UserRole role;
}

// ─────────────────────────────────────────────────────────────────────────────
// SignUpUseCase
// ─────────────────────────────────────────────────────────────────────────────

class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  /// Registers a new user with the given [params].
  ///
  /// Throws a [Failure] subclass on error.
  Future<UserEntity> call(SignUpParams params) => _repository.signUp(
        email:    params.email,
        password: params.password,
        fullName: params.fullName,
        phone:    params.phone,
        wilaya:   params.wilaya,
        role:     params.role,
      );
}
