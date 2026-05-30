// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_orders_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderRepositoryHash() => r'd5127ff2b0496c97e7236fd27fa57064b4321a2e';

/// See also [_orderRepository].
@ProviderFor(_orderRepository)
final _orderRepositoryProvider = AutoDisposeProvider<OrderRepository>.internal(
  _orderRepository,
  name: r'_orderRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _OrderRepositoryRef = AutoDisposeProviderRef<OrderRepository>;
String _$myOrdersListHash() => r'1ad18ea5374c3dd472288398716ea4a0dfe01f58';

/// See also [myOrdersList].
@ProviderFor(myOrdersList)
final myOrdersListProvider =
    AutoDisposeFutureProvider<List<OrderEntity>>.internal(
  myOrdersList,
  name: r'myOrdersListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myOrdersListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyOrdersListRef = AutoDisposeFutureProviderRef<List<OrderEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
