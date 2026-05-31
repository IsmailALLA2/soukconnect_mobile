import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/product_management_provider.dart';
import '../providers/store_management_provider.dart';
import '../widgets/widgets.dart';

class MyProductsPage extends HookConsumerWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(myStoreNotifierProvider);
    final store = storeAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Produits')),
      body: store == null
          ? const Center(child: CircularProgressIndicator())
          : ref.watch(myProductsNotifierProvider(store.id)).when(
              loading: () => const ProductShimmerList(),
              error: (e, _) => Center(child: Text('$e')),
              data: (products) => products.isEmpty
                  ? const ProductEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 8),
                      itemCount: products.length,
                      itemBuilder: (_, i) =>
                          ProductListItem(product: products[i]),
                    ),
            ),
      floatingActionButton: store != null
          ? FloatingActionButton(
              onPressed: () => showCreateProductSheet(context, store.id),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
