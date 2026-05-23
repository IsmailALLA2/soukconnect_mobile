import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_config.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthRepositoryImpl — Supabase implementation of [AuthRepository]
// ─────────────────────────────────────────────────────────────────────────────

class AuthRepositoryImpl implements AuthRepository {
  // ── Sign in ───────────────────────────────────────────────────────────────

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw const AuthFailure('Connexion échouée. Veuillez réessayer.');
      }

      return _fetchProfile(userId);
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  // ── Sign up ───────────────────────────────────────────────────────────────

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String wilaya,
    required UserRole role,
  }) async {
    try {
      // 1. Create the auth user and store extra data in raw_user_meta_data.
      //    A Supabase trigger (or the client below) will create the profile row.
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName,
          'phone':     phone,
          'wilaya':    wilaya,
          'role':      role.value,
        },
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw const AuthFailure("L'inscription a échoué. Veuillez réessayer.");
      }

      // 2. Upsert the profile row in public.profiles.
      //    This covers cases where no DB trigger is configured.
      await supabase.from('profiles').upsert({
        'id':        userId,
        'full_name': fullName,
        'phone':     phone,
        'wilaya':    wilaya,
        'role':      role.value,
      });

      // 3. Fetch and return the freshly created profile.
      return _fetchProfile(userId);
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered')) {
        throw const EmailAlreadyUsedFailure();
      }
      throw _mapAuthException(e);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  // ── Get current user ──────────────────────────────────────────────────────

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return null;
      return _fetchProfile(authUser.id);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Fetches the `public.profiles` row for [userId] and returns a [UserModel].
  Future<UserModel> _fetchProfile(String userId) async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Row not found — profile may not exist yet (edge case after signUp)
        throw const NotFoundFailure('Profil introuvable.');
      }
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  /// Maps a [AuthException] to a [Failure] with a French message.
  static Failure _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login') ||
        msg.contains('invalid credentials') ||
        msg.contains('wrong password')) {
      return const AuthFailure('Email ou mot de passe incorrect.');
    }
    if (msg.contains('email not confirmed')) {
      return const AuthFailure(
          'Veuillez confirmer votre adresse e-mail avant de vous connecter.');
    }
    if (msg.contains('too many requests')) {
      return const AuthFailure(
          'Trop de tentatives. Veuillez patienter avant de réessayer.');
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return const NetworkFailure();
    }

    return AuthFailure(e.message);
  }
}
