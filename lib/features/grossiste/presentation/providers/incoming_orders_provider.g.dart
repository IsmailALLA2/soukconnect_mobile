// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incoming_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$incomingOrdersNotifierHash() =>
    r'28010e9cd36987d22b915fd8f6f24b65a7eb07d1';

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

abstract class _$IncomingOrdersNotifier
    extends BuildlessAsyncNotifier<List<IncomingOrderEntity>> {
  late final String storeId;

  FutureOr<List<IncomingOrderEntity>> build(
    String storeId,
  );
}

/// See also [IncomingOrdersNotifier].
@ProviderFor(IncomingOrdersNotifier)
const incomingOrdersNotifierProvider = IncomingOrdersNotifierFamily();

/// See also [IncomingOrdersNotifier].
class IncomingOrdersNotifierFamily
    extends Family<AsyncValue<List<IncomingOrderEntity>>> {
  /// See also [IncomingOrdersNotifier].
  const IncomingOrdersNotifierFamily();

  /// See also [IncomingOrdersNotifier].
  IncomingOrdersNotifierProvider call(
    String storeId,
  ) {
    return IncomingOrdersNotifierProvider(
      storeId,
    );
  }

  @override
  IncomingOrdersNotifierProvider getProviderOverride(
    covariant IncomingOrdersNotifierProvider provider,
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
  String? get name => r'incomingOrdersNotifierProvider';
}

/// See also [IncomingOrdersNotifier].
class IncomingOrdersNotifierProvider extends AsyncNotifierProviderImpl<
    IncomingOrdersNotifier, List<IncomingOrderEntity>> {
  /// See also [IncomingOrdersNotifier].
  IncomingOrdersNotifierProvider(
    String storeId,
  ) : this._internal(
          () => IncomingOrdersNotifier()..storeId = storeId,
          from: incomingOrdersNotifierProvider,
          name: r'incomingOrdersNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$incomingOrdersNotifierHash,
          dependencies: IncomingOrdersNotifierFamily._dependencies,
          allTransitiveDependencies:
              IncomingOrdersNotifierFamily._allTransitiveDependencies,
          storeId: storeId,
        );

  IncomingOrdersNotifierProvider._internal(
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
  FutureOr<List<IncomingOrderEntity>> runNotifierBuild(
    covariant IncomingOrdersNotifier notifier,
  ) {
    return notifier.build(
      storeId,
    );
  }

  @override
  Override overrideWith(IncomingOrdersNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: IncomingOrdersNotifierProvider._internal(
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
  AsyncNotifierProviderElement<IncomingOrdersNotifier,
      List<IncomingOrderEntity>> createElement() {
    return _IncomingOrdersNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IncomingOrdersNotifierProvider && other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IncomingOrdersNotifierRef
    on AsyncNotifierProviderRef<List<IncomingOrderEntity>> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _IncomingOrdersNotifierProviderElement
    extends AsyncNotifierProviderElement<IncomingOrdersNotifier,
        List<IncomingOrderEntity>> with IncomingOrdersNotifierRef {
  _IncomingOrdersNotifierProviderElement(super.provider);

  @override
  String get storeId => (origin as IncomingOrdersNotifierProvider).storeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
