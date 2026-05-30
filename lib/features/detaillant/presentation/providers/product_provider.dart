import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_store_products_usecase.dart';
import 'store_provider.dart';

part 'product_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// storeProductsProvider — fetches products for a given store
//
// This is a family provider: each [storeId] maintains its own async state
// and is auto-disposed when the StoreDetailPage leaves the stack.
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<List<ProductEntity>> storeProducts(
  StoreProductsRef ref,
  String storeId,
) {
  final repo    = ref.watch(storeRepositoryProvider);
  final useCase = GetStoreProductsUseCase(repo);
  return useCase(storeId);
}
