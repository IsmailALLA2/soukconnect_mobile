import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/sizer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/store_entity.dart';
import '../providers/location_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NearbyStoresPage
// ─────────────────────────────────────────────────────────────────────────────

class NearbyStoresPage extends HookConsumerWidget {
  const NearbyStoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Local state ──────────────────────────────────────────────────────────
    final searchCtrl   = useTextEditingController();
    final searchQuery  = useState('');
    final isRefreshing = useState(false);

    useEffect(() {
      void onSearch() =>
          searchQuery.value = searchCtrl.text.trim().toLowerCase();
      searchCtrl.addListener(onSearch);
      return () => searchCtrl.removeListener(onSearch);
    }, const []);

    // ── Provider watches ─────────────────────────────────────────────────────
    final filteredAsync = ref.watch(filteredStoresProvider);
    final selectedCat   = ref.watch(selectedCategoryProvider);
    final locationAsync = ref.watch(locationNotifierProvider);
    final themeN        = ref.read(themeModeProvider.notifier);
    final user          = ref.watch(authNotifierProvider).valueOrNull;

    // ── Pull-to-refresh ──────────────────────────────────────────────────────
    Future<void> handleRefresh() async {
      if (isRefreshing.value) return;
      isRefreshing.value = true;
      await ref.read(nearbyStoresNotifierProvider.notifier).refresh();
      isRefreshing.value = false;
    }

    // ── Client-side search filter on top of category filter ──────────────────
    final displayedStores = filteredAsync.whenData((stores) {
      if (searchQuery.value.isEmpty) return stores;
      return stores
          .where((s) => s.name.toLowerCase().contains(searchQuery.value))
          .toList();
    });

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── AppBar ──────────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: context.colorScheme.surface,
              elevation: 0,
              scrolledUnderElevation: 1,
              title: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: AppColors.white,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'SoukConnect',
                    style: AppTextStyles.titleMedium(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              actions: [
                // Wilaya badge
                if (user != null && user.wilaya.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(right: 4.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          user.wilaya,
                          style: AppTextStyles.labelSmall(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Dark mode toggle
                IconButton(
                  onPressed: themeN.toggle,
                  icon: Icon(
                    context.isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 20.sp,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            // ── Search bar ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: TextField(
                  controller: searchCtrl,
                  style: AppTextStyles.bodyMedium(
                    color: context.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une boutique…',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20.sp,
                      color: AppColors.grey500,
                    ),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18.sp,
                              color: AppColors.grey500,
                            ),
                            onPressed: () {
                              searchCtrl.clear();
                              searchQuery.value = '';
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // ── Category filter chips ────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  children: [
                    StoreCategoryChip(
                      label: 'Tous',
                      isSelected: selectedCat == null,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .select(null),
                    ),
                    SizedBox(width: 8.w),
                    ...StoreCategory.values.map((cat) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: StoreCategoryChip(
                          label: cat.label,
                          isSelected: selectedCat == cat,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .select(cat),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ── GPS / location error banner ──────────────────────────────────
            if (locationAsync.hasError)
              SliverToBoxAdapter(
                child: LocationErrorBanner(
                  message: locationAsync.error.toString(),
                  onRetry: () =>
                      ref.read(locationNotifierProvider.notifier).refresh(),
                ),
              ),

            // ── Section header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grossistes proches',
                      style: AppTextStyles.titleSmall(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    displayedStores.whenOrNull(
                          data: (stores) => Text(
                            '${stores.length} résultat${stores.length != 1 ? 's' : ''}',
                            style: AppTextStyles.labelSmall(
                              color: AppColors.grey500,
                            ),
                          ),
                        ) ??
                        const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            // ── Store list ───────────────────────────────────────────────────
            displayedStores.when(
              loading: () => const StoreShimmerList(),
              error: (e, _) => SliverToBoxAdapter(
                child: StoreErrorState(
                  message: e.toString(),
                  onRetry: handleRefresh,
                ),
              ),
              data: (stores) {
                if (stores.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: StoreEmptyState(),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final store = stores[index];
                      return StoreCard(
                        store: store,
                        onTap: () => context.go(
                          AppRoutes.storeDetail(store.id),
                        ),
                      );
                    },
                    childCount: stores.length,
                  ),
                );
              },
            ),

            // ── Bottom padding ───────────────────────────────────────────────
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}
