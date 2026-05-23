import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Failure — clean error types that cross the domain boundary
//
// The data layer catches raw exceptions (SupabaseException, SocketException…)
// and converts them to Failure subclasses. The domain and presentation layers
// only ever see these clean types — no Supabase/http imports needed.
// ─────────────────────────────────────────────────────────────────────────────

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

// ── Auth failures ─────────────────────────────────────────────────────────────

/// Wrong email / password, expired session, etc.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// User is not authenticated when a protected resource is accessed.
final class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure()
      : super('Utilisateur non connecté.');
}

/// Signup attempted with an email that is already registered.
final class EmailAlreadyUsedFailure extends Failure {
  const EmailAlreadyUsedFailure()
      : super('Cette adresse e-mail est déjà utilisée.');
}

// ── Network failures ──────────────────────────────────────────────────────────

/// No internet or server unreachable.
final class NetworkFailure extends Failure {
  const NetworkFailure()
      : super('Vérifiez votre connexion internet et réessayez.');
}

// ── Server / data failures ────────────────────────────────────────────────────

/// Supabase returned an unexpected error or data was malformed.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Une erreur serveur est survenue.']);
}

/// A required database row was not found.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable.']);
}

// ── Generic ───────────────────────────────────────────────────────────────────

/// Catch-all for unexpected errors.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inattendue est survenue.']);
}
