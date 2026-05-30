// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeProductsHash() => r'9df065b6e2f913a445c355a6051867d3594c93ba';

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

/// See also [storeProducts].
@ProviderFor(storeProducts)
const storeProductsProvider = StoreProductsFamily();

/// See also [storeProducts].
class StoreProductsFamily extends Family<AsyncValue<List<ProductEntity>>> {
  /// See also [storeProducts].
  const StoreProductsFamily();

  /// See also [storeProducts].
  StoreProductsProvider call(
    String storeId,
  ) {
    return StoreProductsProvider(
      storeId,
    );
  }

  @override
  StoreProductsProvider getProviderOverride(
    covariant StoreProductsProvider provider,
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
  String? get name => r'storeProductsProvider';
}

/// See also [storeProducts].
class StoreProductsProvider
    extends AutoDisposeFutureProvider<List<ProductEntity>> {
  /// See also [storeProducts].
  StoreProductsProvider(
    String storeId,
  ) : this._internal(
          (ref) => storeProducts(
            ref as StoreProductsRef,
            storeId,
          ),
          from: storeProductsProvider,
          name: r'storeProductsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$storeProductsHash,
          dependencies: StoreProductsFamily._dependencies,
          allTransitiveDependencies:
              StoreProductsFamily._allTransitiveDependencies,
          storeId: storeId,
        );

  StoreProductsProvider._internal(
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
  Override overrideWith(
    FutureOr<List<ProductEntity>> Function(StoreProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StoreProductsProvider._internal(
        (ref) => create(ref as StoreProductsRef),
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
  AutoDisposeFutureProviderElement<List<ProductEntity>> createElement() {
    return _StoreProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreProductsProvider && other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StoreProductsRef on AutoDisposeFutureProviderRef<List<ProductEntity>> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _StoreProductsProviderElement
    extends AutoDisposeFutureProviderElement<List<ProductEntity>>
    with StoreProductsRef {
  _StoreProductsProviderElement(super.provider);

  @override
  String get storeId => (origin as StoreProductsProvider).storeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
