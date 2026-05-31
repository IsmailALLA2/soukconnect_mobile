import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/green_spinner.dart';
import '../../../detaillant/domain/entities/product_entity.dart';
import '../providers/product_management_provider.dart';
import '../providers/store_management_provider.dart';
import '../widgets/product_empty_state.dart';
import '../widgets/widgets.dart';

enum _ViewMode { list, grid }

enum _SortMode { name, price, stock }

class MyProductsPage extends HookConsumerWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(myStoreNotifierProvider);
    final store = storeAsync.valueOrNull;
    final storeId = store?.id;

    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');
    final isSearching = useState(false);
    final sortMode = useState<_SortMode>(_SortMode.name);
    final sortAsc = useState(true);
    final viewMode = useState<_ViewMode>(_ViewMode.list);

    final searchFocusNode = useFocusNode();

    useEffect(() {
      void onSearch() =>
          searchQuery.value = searchCtrl.text.trim().toLowerCase();
      searchCtrl.addListener(onSearch);
      return () => searchCtrl.removeListener(onSearch);
    }, const []);

    useEffect(() {
      if (isSearching.value) {
        searchFocusNode.requestFocus();
      }
      return null;
    }, [isSearching.value]);

    if (storeId == null) {
      return Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: const Center(child: GreenSpinner()),
      );
    }

    final productsAsync = ref.watch(myProductsNotifierProvider(storeId));

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: _buildAppBar(
        context: context,
        ref: ref,
        productsAsync: productsAsync,
        isSearching: isSearching,
        searchCtrl: searchCtrl,
        searchFocusNode: searchFocusNode,
        searchQuery: searchQuery,
        sortMode: sortMode,
        sortAsc: sortAsc,
        viewMode: viewMode,
      ),
      body: productsAsync.when(
        loading: () => const ProductShimmerList(),
        error: (e, _) => Center(child: Text('$e')),
        data: (products) {
          final filtered = _filterAndSort(products, searchQuery.value, sortMode.value, sortAsc.value);
          if (products.isEmpty) return ProductEmptyState(
            onAddProduct: () => showCreateProductSheet(context, storeId),
          );
          return Column(
            children: [
              _StatsStrip(products: products),
              Expanded(
                child: viewMode.value == _ViewMode.list
                    ? _ProductListView(products: filtered, sortAsc: sortAsc, sortMode: sortMode)
                    : _ProductGridView(products: filtered),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateProductSheet(context, storeId),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<List<ProductEntity>> productsAsync,
    required ValueNotifier<bool> isSearching,
    required TextEditingController searchCtrl,
    required FocusNode searchFocusNode,
    required ValueNotifier<String> searchQuery,
    required ValueNotifier<_SortMode> sortMode,
    required ValueNotifier<bool> sortAsc,
    required ValueNotifier<_ViewMode> viewMode,
  }) {
    final productCount = productsAsync.valueOrNull?.length ?? 0;

    if (isSearching.value) {
      return AppBar(
        backgroundColor: context.colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colorScheme.onSurface),
          onPressed: () {
            isSearching.value = false;
            searchCtrl.clear();
            searchQuery.value = '';
          },
        ),
        title: TextField(
          controller: searchCtrl,
          focusNode: searchFocusNode,
          autofocus: true,
          style: AppTextStyles.bodyMedium(color: context.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Rechercher un produit\u2026',
            hintStyle: AppTextStyles.bodyMedium(color: AppColors.grey500),
            border: InputBorder.none,
            filled: false,
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: context.colorScheme.surface,
      scrolledUnderElevation: 1,
      title: Row(
        children: [
          Text('Mes Produits'),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$productCount',
              style: AppTextStyles.labelSmall(color: AppColors.primary),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            size: 20.sp,
            color: context.colorScheme.onSurface,
          ),
          onPressed: () => isSearching.value = true,
        ),
        IconButton(
          icon: Icon(
            Icons.sort_rounded,
            size: 20.sp,
            color: context.colorScheme.onSurface,
          ),
          onPressed: () => _showSortSheet(context, sortMode, sortAsc),
        ),
        IconButton(
          icon: Icon(
            viewMode.value == _ViewMode.list
                ? Icons.grid_view_rounded
                : Icons.view_list_rounded,
            size: 20.sp,
            color: context.colorScheme.onSurface,
          ),
          onPressed: () => viewMode.value = viewMode.value == _ViewMode.list
              ? _ViewMode.grid
              : _ViewMode.list,
        ),
      ],
    );
  }

  void _showSortSheet(
    BuildContext context,
    ValueNotifier<_SortMode> sortMode,
    ValueNotifier<bool> sortAsc,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _SortSheet(
        currentMode: sortMode.value,
        currentAsc: sortAsc.value,
        onApply: (mode, asc) {
          sortMode.value = mode;
          sortAsc.value = asc;
        },
      ),
    );
  }

  List<ProductEntity> _filterAndSort(
    List<ProductEntity> products,
    String query,
    _SortMode mode,
    bool asc,
  ) {
    var result = products;
    if (query.isNotEmpty) {
      result = result
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }
    result.sort((a, b) {
      final cmp = switch (mode) {
        _SortMode.name => a.name.compareTo(b.name),
        _SortMode.price => a.price.compareTo(b.price),
        _SortMode.stock => a.stock.compareTo(b.stock),
      };
      return asc ? cmp : -cmp;
    });
    return result;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatsStrip — horizontal scroll of stat pills
// ─────────────────────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.products});

  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    final total = products.length;
    final available = products.where((p) => p.isAvailable && p.stock > 0).length;
    final outOfStock = products.where((p) => p.stock == 0).length;

    return Container(
      height: 44.h,
      color: context.colorScheme.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          _Pill(label: 'Total: $total', color: AppColors.grey700, bgColor: AppColors.grey100),
          SizedBox(width: 8.w),
          _Pill(
            label: 'Disponibles: $available',
            color: AppColors.success,
            bgColor: AppColors.successLight,
          ),
          SizedBox(width: 8.w),
          _Pill(
            label: 'Rupture: $outOfStock',
            color: outOfStock > 0 ? AppColors.error : AppColors.grey500,
            bgColor: outOfStock > 0 ? AppColors.errorLight : AppColors.grey100,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductListView — list mode with redesigned ProductListItem
// ─────────────────────────────────────────────────────────────────────────────

class _ProductListView extends StatelessWidget {
  const _ProductListView({
    required this.products,
    required this.sortAsc,
    required this.sortMode,
  });

  final List<ProductEntity> products;
  final ValueNotifier<bool> sortAsc;
  final ValueNotifier<_SortMode> sortMode;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 48.sp, color: AppColors.grey400),
            SizedBox(height: 12.h),
            Text(
              'Aucun résultat',
              style: AppTextStyles.bodyMedium(color: AppColors.grey500),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(top: 4.h, bottom: 80.h),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductListItem(product: products[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductGridView — grid mode with ProductGridCard
// ─────────────────────────────────────────────────────────────────────────────

class _ProductGridView extends StatelessWidget {
  const _ProductGridView({required this.products});

  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 48.sp, color: AppColors.grey400),
            SizedBox(height: 12.h),
            Text(
              'Aucun résultat',
              style: AppTextStyles.bodyMedium(color: AppColors.grey500),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
      child: GridView.builder(
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 4,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (_, i) => ProductGridCard(product: products[i]),
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// _SortSheet — bottom sheet for sort options
// ─────────────────────────────────────────────────────────────────────────────

class _SortSheet extends StatefulWidget {
  const _SortSheet({
    required this.currentMode,
    required this.currentAsc,
    required this.onApply,
  });

  final _SortMode currentMode;
  final bool currentAsc;
  final void Function(_SortMode mode, bool asc) onApply;

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late _SortMode _mode;
  late bool _asc;

  @override
  void initState() {
    super.initState();
    _mode = widget.currentMode;
    _asc = widget.currentAsc;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Trier par',
            style: AppTextStyles.titleMedium(
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          _SortOption(
            icon: Icons.sort_by_alpha_rounded,
            label: 'Nom',
            isSelected: _mode == _SortMode.name,
            onTap: () => setState(() => _mode = _SortMode.name),
          ),
          _SortOption(
            icon: Icons.attach_money_rounded,
            label: 'Prix',
            isSelected: _mode == _SortMode.price,
            onTap: () => setState(() => _mode = _SortMode.price),
          ),
          _SortOption(
            icon: Icons.inventory_2_rounded,
            label: 'Stock',
            isSelected: _mode == _SortMode.stock,
            onTap: () => setState(() => _mode = _SortMode.stock),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Text(
                'Ordre',
                style: AppTextStyles.labelMedium(
                  color: context.colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 12.w),
              ChoiceChip(
                label: Text(
                  'Croissant',
                  style: AppTextStyles.labelSmall(
                    color: _asc ? AppColors.white : AppColors.grey700,
                  ),
                ),
                selected: _asc,
                selectedColor: AppColors.primary,
                onSelected: (_) => setState(() => _asc = true),
              ),
              SizedBox(width: 8.w),
              ChoiceChip(
                label: Text(
                  'Décroissant',
                  style: AppTextStyles.labelSmall(
                    color: !_asc ? AppColors.white : AppColors.grey700,
                  ),
                ),
                selected: !_asc,
                selectedColor: AppColors.primary,
                onSelected: (_) => setState(() => _asc = false),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_mode, _asc);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: const Text('Appliquer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.grey600,
        size: 20.sp,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium(
          color: isSelected
              ? AppColors.primary
              : context.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: AppColors.primary, size: 20.sp)
          : null,
      onTap: onTap,
      dense: true,
    );
  }
}
