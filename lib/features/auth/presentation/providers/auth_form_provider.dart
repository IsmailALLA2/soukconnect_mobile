import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../../../../core/extensions/string_extensions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthFormState — immutable form state
// ─────────────────────────────────────────────────────────────────────────────

class AuthFormState {
  const AuthFormState({
    this.email        = '',
    this.password     = '',
    this.fullName     = '',
    this.phone        = '',
    this.wilaya       = '',
    this.role         = UserRole.detaillant,
    this.isLoading    = false,
    this.errorMessage,
    this.emailError,
    this.passwordError,
    this.fullNameError,
    this.phoneError,
    this.wilayaError,
  });

  final String    email;
  final String    password;
  final String    fullName;
  final String    phone;
  final String    wilaya;
  final UserRole  role;
  final bool      isLoading;

  /// A global error message (e.g. from a failed API call).
  final String? errorMessage;

  /// Per-field validation errors — null means the field is valid.
  final String? emailError;
  final String? passwordError;
  final String? fullNameError;
  final String? phoneError;
  final String? wilayaError;

  // ── Computed ──────────────────────────────────────────────────────────────

  /// `true` when there are no per-field validation errors.
  bool get isValid =>
      emailError    == null &&
      passwordError == null &&
      fullNameError == null &&
      phoneError    == null &&
      wilayaError   == null;

  /// `true` if any field has an active error shown to the user.
  bool get hasErrors =>
      emailError    != null ||
      passwordError != null ||
      fullNameError != null ||
      phoneError    != null ||
      wilayaError   != null;

  // ── copyWith ──────────────────────────────────────────────────────────────

  AuthFormState copyWith({
    String?   email,
    String?   password,
    String?   fullName,
    String?   phone,
    String?   wilaya,
    UserRole? role,
    bool?     isLoading,
    // Use Object? sentinel to allow explicit null clears
    Object?   errorMessage  = _sentinel,
    Object?   emailError    = _sentinel,
    Object?   passwordError = _sentinel,
    Object?   fullNameError = _sentinel,
    Object?   phoneError    = _sentinel,
    Object?   wilayaError   = _sentinel,
  }) {
    return AuthFormState(
      email:         email        ?? this.email,
      password:      password     ?? this.password,
      fullName:      fullName     ?? this.fullName,
      phone:         phone        ?? this.phone,
      wilaya:        wilaya       ?? this.wilaya,
      role:          role         ?? this.role,
      isLoading:     isLoading    ?? this.isLoading,
      errorMessage:  errorMessage  == _sentinel ? this.errorMessage  : errorMessage  as String?,
      emailError:    emailError    == _sentinel ? this.emailError    : emailError    as String?,
      passwordError: passwordError == _sentinel ? this.passwordError : passwordError as String?,
      fullNameError: fullNameError == _sentinel ? this.fullNameError : fullNameError as String?,
      phoneError:    phoneError    == _sentinel ? this.phoneError    : phoneError    as String?,
      wilayaError:   wilayaError   == _sentinel ? this.wilayaError   : wilayaError   as String?,
    );
  }
}

// Sentinel used to distinguish "not provided" from explicit null in copyWith.
const _sentinel = Object();

// ─────────────────────────────────────────────────────────────────────────────
// AuthFormNotifier — StateNotifier driving the form
// ─────────────────────────────────────────────────────────────────────────────

class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier() : super(const AuthFormState());

  // ── Field updates ─────────────────────────────────────────────────────────

  void updateEmail(String value) {
    state = state.copyWith(
      email:        value,
      errorMessage: null,
      emailError:   null,
    );
  }

  void updatePassword(String value) {
    state = state.copyWith(
      password:      value,
      errorMessage:  null,
      passwordError: null,
    );
  }

  void updateFullName(String value) {
    state = state.copyWith(
      fullName:      value,
      errorMessage:  null,
      fullNameError: null,
    );
  }

  void updatePhone(String value) {
    state = state.copyWith(
      phone:        value,
      errorMessage: null,
      phoneError:   null,
    );
  }

  void updateWilaya(String value) {
    state = state.copyWith(
      wilaya:       value,
      errorMessage: null,
      wilayaError:  null,
    );
  }

  void updateRole(UserRole role) {
    state = state.copyWith(role: role, errorMessage: null);
  }

  // ── Global error / loading ────────────────────────────────────────────────

  void setError(String? message) {
    state = state.copyWith(
      isLoading:    false,
      errorMessage: message,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(
      isLoading:    loading,
      errorMessage: null,
    );
  }

  void clearError() => state = state.copyWith(errorMessage: null);

  // ── Validation ────────────────────────────────────────────────────────────

  /// Validates all fields for the **sign-in** form.
  /// Returns `true` if valid.
  bool validateSignIn() {
    final emailErr    = _validateEmail(state.email);
    final passwordErr = _validatePassword(state.password);

    state = state.copyWith(
      emailError:    emailErr,
      passwordError: passwordErr,
    );
    return emailErr == null && passwordErr == null;
  }

  /// Validates all fields for the **sign-up** form.
  /// Returns `true` if valid.
  bool validateSignUp() {
    final emailErr    = _validateEmail(state.email);
    final passwordErr = _validatePassword(state.password);
    final nameErr     = _validateFullName(state.fullName);
    final phoneErr    = _validatePhone(state.phone);
    final wilayaErr   = _validateWilaya(state.wilaya);

    state = state.copyWith(
      emailError:    emailErr,
      passwordError: passwordErr,
      fullNameError: nameErr,
      phoneError:    phoneErr,
      wilayaError:   wilayaErr,
    );
    return emailErr    == null &&
           passwordErr == null &&
           nameErr     == null &&
           phoneErr    == null &&
           wilayaErr   == null;
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  /// Resets the form to its initial empty state.
  void reset() => state = const AuthFormState();

  // ── Private validators ────────────────────────────────────────────────────

  static String? _validateEmail(String value) {
    if (value.isBlank) return 'L\'e-mail est requis.';
    if (!value.isValidEmail) return 'Adresse e-mail invalide.';
    return null;
  }

  static String? _validatePassword(String value) {
    if (value.isBlank) return 'Le mot de passe est requis.';
    if (value.length < 8) return 'Minimum 8 caractères.';
    return null;
  }

  static String? _validateFullName(String value) {
    if (value.isBlank) return 'Le nom complet est requis.';
    if (value.trim().length < 3) return 'Minimum 3 caractères.';
    return null;
  }

  static String? _validatePhone(String value) {
    if (value.isBlank) return 'Le numéro de téléphone est requis.';
    if (!value.isValidPhone) {
      return 'Numéro marocain invalide (ex: 0612345678).';
    }
    return null;
  }

  static String? _validateWilaya(String value) {
    if (value.isBlank) return 'La wilaya est requise.';
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Form state provider — auto-dispose so the form resets when the
/// screen leaves the widget tree.
final authFormProvider =
    StateNotifierProvider.autoDispose<AuthFormNotifier, AuthFormState>(
  (_) => AuthFormNotifier(),
);
