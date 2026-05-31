// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myProductsNotifierHash() =>
    r'012b860954d7ed20f01d7c8d0f9e937bf998e54a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MyProductsNotifier
    extends BuildlessAsyncNotifier<List<ProductEntity>> {
  late final String storeId;

  FutureOr<List<ProductEntity>> build(
    String storeId,
  );
}

/// See also [MyProductsNotifier].
@ProviderFor(MyProductsNotifier)
const myProductsNotifierProvider = MyProductsNotifierFamily();

/// See also [MyProductsNotifier].
class MyProductsNotifierFamily extends Family<AsyncValue<List<ProductEntity>>> {
  /// See also [MyProductsNotifier].
  const MyProductsNotifierFamily();

  /// See also [MyProductsNotifier].
  MyProductsNotifierProvider call(
    String storeId,
  ) {
    return MyProductsNotifierProvider(
      storeId,
    );
  }

  @override
  MyProductsNotifierProvider getProviderOverride(
    covariant MyProductsNotifierProvider provider,
  ) {
    return call(
      provider.storeId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myProductsNotifierProvider';
}

/// See also [MyProductsNotifier].
class MyProductsNotifierProvider
    extends AsyncNotifierProviderImpl<MyProductsNotifier, List<ProductEntity>> {
  /// See also [MyProductsNotifier].
  MyProductsNotifierProvider(
    String storeId,
  ) : this._internal(
          () => MyProductsNotifier()..storeId = storeId,
          from: myProductsNotifierProvider,
          name: r'myProductsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$myProductsNotifierHash,
          dependencies: MyProductsNotifierFamily._dependencies,
          allTransitiveDependencies:
              MyProductsNotifierFamily._allTransitiveDependencies,
          storeId: storeId,
        );

  MyProductsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storeId,
  }) : super.internal();

  final String storeId;

  @override
  FutureOr<List<ProductEntity>> runNotifierBuild(
    covariant MyProductsNotifier notifier,
  ) {
    return notifier.build(
      storeId,
    );
  }

  @override
  Override overrideWith(MyProductsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MyProductsNotifierProvider._internal(
        () => create()..storeId = storeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storeId: storeId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<MyProductsNotifier, List<ProductEntity>>
      createElement() {
    return _MyProductsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyProductsNotifierProvider && other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MyProductsNotifierRef on AsyncNotifierProviderRef<List<ProductEntity>> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _MyProductsNotifierProviderElement extends AsyncNotifierProviderElement<
    MyProductsNotifier, List<ProductEntity>> with MyProductsNotifierRef {
  _MyProductsNotifierProviderElement(super.provider);

  @override
  String get storeId => (origin as MyProductsNotifierProvider).storeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
