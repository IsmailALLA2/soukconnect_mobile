// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$grossisteRepositoryHash() =>
    r'646f45180d6e44f86d31051f0dc19e5f4dd5a1e7';

/// See also [grossisteRepository].
@ProviderFor(grossisteRepository)
final grossisteRepositoryProvider = Provider<GrossisteRepository>.internal(
  grossisteRepository,
  name: r'grossisteRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$grossisteRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GrossisteRepositoryRef = ProviderRef<GrossisteRepository>;
String _$myStoreNotifierHash() => r'b1fa8a494c6ac4837cc548eabf25e4691478fa75';

/// See also [MyStoreNotifier].
@ProviderFor(MyStoreNotifier)
final myStoreNotifierProvider =
    AsyncNotifierProvider<MyStoreNotifier, MyStoreEntity?>.internal(
  MyStoreNotifier.new,
  name: r'myStoreNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myStoreNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyStoreNotifier = AsyncNotifier<MyStoreEntity?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
