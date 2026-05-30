// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeRepositoryHash() => r'83b2d50b6f950d31c967235f6e74925a8b66888c';

/// Provides the concrete [StoreRepository] implementation.
/// Swap [StoreRepositoryImpl] for a fake/mock here during testing.
///
/// Copied from [storeRepository].
@ProviderFor(storeRepository)
final storeRepositoryProvider = Provider<StoreRepository>.internal(
  storeRepository,
  name: r'storeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StoreRepositoryRef = ProviderRef<StoreRepository>;
String _$filteredStoresHash() => r'ddcb4c9524effb30131289eb59c10b1c02512869';

/// See also [filteredStores].
@ProviderFor(filteredStores)
final filteredStoresProvider =
    AutoDisposeProvider<AsyncValue<List<StoreEntity>>>.internal(
  filteredStores,
  name: r'filteredStoresProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredStoresHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredStoresRef
    = AutoDisposeProviderRef<AsyncValue<List<StoreEntity>>>;
String _$storesByCategoryHash() => r'dd2c9d4c953b9284b8ec1c4b88cd308b883345a0';

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

/// See also [storesByCategory].
@ProviderFor(storesByCategory)
const storesByCategoryProvider = StoresByCategoryFamily();

/// See also [storesByCategory].
class StoresByCategoryFamily extends Family<AsyncValue<List<StoreEntity>>> {
  /// See also [storesByCategory].
  const StoresByCategoryFamily();

  /// See also [storesByCategory].
  StoresByCategoryProvider call(
    StoreCategory category,
  ) {
    return StoresByCategoryProvider(
      category,
    );
  }

  @override
  StoresByCategoryProvider getProviderOverride(
    covariant StoresByCategoryProvider provider,
  ) {
    return call(
      provider.category,
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
  String? get name => r'storesByCategoryProvider';
}

/// See also [storesByCategory].
class StoresByCategoryProvider
    extends AutoDisposeFutureProvider<List<StoreEntity>> {
  /// See also [storesByCategory].
  StoresByCategoryProvider(
    StoreCategory category,
  ) : this._internal(
          (ref) => storesByCategory(
            ref as StoresByCategoryRef,
            category,
          ),
          from: storesByCategoryProvider,
          name: r'storesByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$storesByCategoryHash,
          dependencies: StoresByCategoryFamily._dependencies,
          allTransitiveDependencies:
              StoresByCategoryFamily._allTransitiveDependencies,
          category: category,
        );

  StoresByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final StoreCategory category;

  @override
  Override overrideWith(
    FutureOr<List<StoreEntity>> Function(StoresByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StoresByCategoryProvider._internal(
        (ref) => create(ref as StoresByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<StoreEntity>> createElement() {
    return _StoresByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoresByCategoryProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StoresByCategoryRef on AutoDisposeFutureProviderRef<List<StoreEntity>> {
  /// The parameter `category` of this provider.
  StoreCategory get category;
}

class _StoresByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<StoreEntity>>
    with StoresByCategoryRef {
  _StoresByCategoryProviderElement(super.provider);

  @override
  StoreCategory get category => (origin as StoresByCategoryProvider).category;
}

String _$storeDetailHash() => r'09f1e736c9c991cfe93ef8d386da17ceaa9dc142';

/// See also [storeDetail].
@ProviderFor(storeDetail)
const storeDetailProvider = StoreDetailFamily();

/// See also [storeDetail].
class StoreDetailFamily extends Family<AsyncValue<StoreEntity>> {
  /// See also [storeDetail].
  const StoreDetailFamily();

  /// See also [storeDetail].
  StoreDetailProvider call(
    String storeId,
  ) {
    return StoreDetailProvider(
      storeId,
    );
  }

  @override
  StoreDetailProvider getProviderOverride(
    covariant StoreDetailProvider provider,
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
  String? get name => r'storeDetailProvider';
}

/// See also [storeDetail].
class StoreDetailProvider extends AutoDisposeFutureProvider<StoreEntity> {
  /// See also [storeDetail].
  StoreDetailProvider(
    String storeId,
  ) : this._internal(
          (ref) => storeDetail(
            ref as StoreDetailRef,
            storeId,
          ),
          from: storeDetailProvider,
          name: r'storeDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$storeDetailHash,
          dependencies: StoreDetailFamily._dependencies,
          allTransitiveDependencies:
              StoreDetailFamily._allTransitiveDependencies,
          storeId: storeId,
        );

  StoreDetailProvider._internal(
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
    FutureOr<StoreEntity> Function(StoreDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StoreDetailProvider._internal(
        (ref) => create(ref as StoreDetailRef),
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
  AutoDisposeFutureProviderElement<StoreEntity> createElement() {
    return _StoreDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreDetailProvider && other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StoreDetailRef on AutoDisposeFutureProviderRef<StoreEntity> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _StoreDetailProviderElement
    extends AutoDisposeFutureProviderElement<StoreEntity> with StoreDetailRef {
  _StoreDetailProviderElement(super.provider);

  @override
  String get storeId => (origin as StoreDetailProvider).storeId;
}

String _$nearbyStoresNotifierHash() =>
    r'556650c19e1605bbbb9d3f519e38a985644c5ef9';

/// See also [NearbyStoresNotifier].
@ProviderFor(NearbyStoresNotifier)
final nearbyStoresNotifierProvider = AutoDisposeAsyncNotifierProvider<
    NearbyStoresNotifier, List<StoreEntity>>.internal(
  NearbyStoresNotifier.new,
  name: r'nearbyStoresNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nearbyStoresNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NearbyStoresNotifier = AutoDisposeAsyncNotifier<List<StoreEntity>>;
String _$selectedCategoryHash() => r'ba6aff4c5281105150fa61a32c5f211d2ba6275a';

/// See also [SelectedCategory].
@ProviderFor(SelectedCategory)
final selectedCategoryProvider =
    AutoDisposeNotifierProvider<SelectedCategory, StoreCategory?>.internal(
  SelectedCategory.new,
  name: r'selectedCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedCategory = AutoDisposeNotifier<StoreCategory?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
