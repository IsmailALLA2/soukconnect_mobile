// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateStreamHash() => r'f7c1e1ca98d46722704fe3472c27202abc5ad4da';

/// See also [authStateStream].
@ProviderFor(authStateStream)
final authStateStreamProvider = AutoDisposeStreamProvider<AuthState>.internal(
  authStateStream,
  name: r'authStateStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateStreamRef = AutoDisposeStreamProviderRef<AuthState>;
String _$currentUserHash() => r'f1cb3911ab7b60e5b7e1b669a393245d886eb187';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$userRoleHash() => r'9d8d64669a8c8322e1427343e3e3eba55bc73895';

/// Expected values: 'detaillant' | 'grossiste'
///
/// Copied from [userRole].
@ProviderFor(userRole)
final userRoleProvider = AutoDisposeFutureProvider<String?>.internal(
  userRole,
  name: r'userRoleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userRoleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserRoleRef = AutoDisposeFutureProviderRef<String?>;
String _$authNotifierHash() => r'e535aad0da2defac53854053b709cf090b055d80';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AsyncValue<User?>>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeNotifier<AsyncValue<User?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
