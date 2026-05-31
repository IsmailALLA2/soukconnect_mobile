import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/store_entity.dart';
import '../providers/location_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/location_error_banner.dart';
import '../widgets/store_empty_state.dart';
import '../widgets/store_error_state.dart';
import '../widgets/store_shimmer_list.dart';

class NearbyStoresPage extends HookConsumerWidget {
  const NearbyStoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');
    final isRefreshing = useState(false);
    final filterRadius = useState(10.0);

    useEffect(() {
      void onSearch() =>
          searchQuery.value = searchCtrl.text.trim().toLowerCase();
      searchCtrl.addListener(onSearch);
      return () => searchCtrl.removeListener(onSearch);
    }, const []);

    final filteredAsync = ref.watch(filteredStoresProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final locationAsync = ref.watch(locationNotifierProvider);
    final themeN = ref.read(themeModeProvider.notifier);
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final firstName = user?.fullName.split(' ').first ?? '';

    Future<void> handleRefresh() async {
      if (isRefreshing.value) return;
      isRefreshing.value = true;
      await ref.read(nearbyStoresNotifierProvider.notifier).refresh();
      isRefreshing.value = false;
    }

    final displayedStores = filteredAsync.whenData((stores) {
      if (searchQuery.value.isEmpty) return stores;
      return stores
          .where((s) => s.name.toLowerCase().contains(searchQuery.value))
          .toList();
    });

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: AppRefreshIndicator(
        onRefresh: handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _AppBar(
              firstName: firstName,
              userWilaya: user?.wilaya,
              themeN: themeN,
            ),
            ...displayedStores.when(
              loading: () => _loadingSlivers(),
              error: (e, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: StoreErrorState(
                      message: e.toString(),
                      onRetry: handleRefresh,
                    ),
                  ),
                ),
              ],
              data: (stores) => _dataSlivers(
                context: context,
                ref: ref,
                stores: stores,
                searchCtrl: searchCtrl,
                searchQuery: searchQuery.value,
                selectedCat: selectedCat,
                locationAsync: locationAsync,
                filterRadius: filterRadius,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }

  List<Widget> _loadingSlivers() {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: Row(
            children: List.generate(3, (i) => _ShimmerStatCard()),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: SizedBox(
            height: 40.h,
            child: Row(
              children: List.generate(
                4,
                (_) => Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Container(
                    width: 80.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      const StoreShimmerList(),
    ];
  }

  List<Widget> _dataSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required List<StoreEntity> stores,
    required TextEditingController searchCtrl,
    required String searchQuery,
    required StoreCategory? selectedCat,
    required AsyncValue<dynamic> locationAsync,
    required ValueNotifier<double> filterRadius,
  }) {
    final totalDist = stores
        .map((s) => s.distanceInKm)
        .whereType<double>()
        .toList();
    final avgDistance = totalDist.isEmpty
        ? 0.0
        : totalDist.reduce((a, b) => a + b) / totalDist.length;
    final categoryCount =
        stores.map((s) => s.category).toSet().length;

    return [
      _StatsSection(
        storeCount: stores.length,
        avgDistance: avgDistance,
        categoryCount: categoryCount,
      ),
      _SearchSection(
        searchCtrl: searchCtrl,
        hasQuery: searchQuery.isNotEmpty,
        onClear: () {
          searchCtrl.clear();
        },
        onFilterTap: () => _showFilterSheet(context, ref, filterRadius),
      ),
      _CategoryChipsSection(
        selectedCat: selectedCat,
        onSelect: (cat) =>
            ref.read(selectedCategoryProvider.notifier).select(cat),
      ),
      if (locationAsync.hasError)
        SliverToBoxAdapter(
          child: LocationErrorBanner(
            message: locationAsync.error.toString(),
            onRetry: () =>
                ref.read(locationNotifierProvider.notifier).refresh(),
          ),
        ),
      _SectionHeader(stores: stores),
      _StoreList(stores: stores),
    ];
  }

  void _showFilterSheet(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<double> filterRadius,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _FilterSheetContent(
        initialRadius: filterRadius.value,
        selectedCat: ref.read(selectedCategoryProvider),
        onApply: (radius, category) {
          filterRadius.value = radius;
          ref.read(selectedCategoryProvider.notifier).select(category);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppBar — SliverAppBar with expanded gradient + greeting
// ─────────────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.firstName,
    required this.userWilaya,
    required this.themeN,
  });

  final String firstName;
  final String? userWilaya;
  final ThemeModeNotifier themeN;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      expandedHeight: 160.h,
      backgroundColor: context.colorScheme.surface,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: AppColors.primary,
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
        if (userWilaya != null && userWilaya!.isNotEmpty)
          Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 12.sp,
                  color: AppColors.white,
                ),
                SizedBox(width: 3.w),
                Text(
                  userWilaya!,
                  style: AppTextStyles.labelSmall(color: AppColors.white),
                ),
              ],
            ),
          ),
        IconButton(
          onPressed: themeN.toggle,
          icon: Icon(
            context.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            size: 20.sp,
            color: AppColors.white,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryDiagonal,
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 8.w,
                top: kToolbarHeight + 8.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour $firstName! \u{1F44B}',
                    style: AppTextStyles.headlineSmall(color: AppColors.white),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Trouvez vos fournisseurs proches',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (userWilaya != null && userWilaya!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14.sp,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            userWilaya!,
                            style: AppTextStyles.labelSmall(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatsSection — 3 quick stat cards in a Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.storeCount,
    required this.avgDistance,
    required this.categoryCount,
  });

  final int storeCount;
  final double avgDistance;
  final int categoryCount;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Row(
          children: [
            Expanded(
              child: GradientCard(
                gradient: AppColors.gradient1,
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
                borderRadius: 14,
                child: _StatContent(
                  icon: Icons.storefront_rounded,
                  value: storeCount.toDouble(),
                  label: 'grossistes',
                  decimals: 0,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: GradientCard(
                gradient: AppColors.gradient2,
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
                borderRadius: 14,
                child: _StatContent(
                  icon: Icons.near_me_rounded,
                  value: avgDistance,
                  label: 'km moyen',
                  decimals: 1,
                  prefix: '~',
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: GradientCard(
                gradient: AppColors.gradient3,
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
                borderRadius: 14,
                child: _StatContent(
                  icon: Icons.category_rounded,
                  value: categoryCount.toDouble(),
                  label: 'catégories',
                  decimals: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatContent extends StatelessWidget {
  const _StatContent({
    required this.icon,
    required this.value,
    required this.label,
    required this.decimals,
    this.prefix,
  });

  final IconData icon;
  final double value;
  final String label;
  final int decimals;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.white, size: 20.sp),
        SizedBox(height: 6.h),
        AnimatedCounter(
          targetValue: value,
          prefix: prefix,
          decimals: decimals,
          style: AppTextStyles.titleLarge(color: AppColors.white),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.labelSmall(color: AppColors.white),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchSection — redesigned search bar with filter icon
// ─────────────────────────────────────────────────────────────────────────────

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.searchCtrl,
    required this.hasQuery,
    required this.onClear,
    required this.onFilterTap,
  });

  final TextEditingController searchCtrl;
  final bool hasQuery;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: TextField(
            controller: searchCtrl,
            style: AppTextStyles.bodyMedium(
              color: context.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Rechercher une boutique\u2026',
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20.sp,
                color: AppColors.grey500,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasQuery)
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: AppColors.grey500,
                      ),
                      onPressed: onClear,
                    ),
                  Container(
                    width: 1,
                    height: 24.h,
                    color: AppColors.grey200,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                    onPressed: onFilterTap,
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: context.colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CategoryChipsSection — horizontal scroll with icons + gradient select
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChipsSection extends StatelessWidget {
  const _CategoryChipsSection({
    required this.selectedCat,
    required this.onSelect,
  });

  final StoreCategory? selectedCat;
  final void Function(StoreCategory?) onSelect;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          children: [
            _CategoryChip(
              icon: Icons.all_inclusive_rounded,
              label: 'Tous',
              isSelected: selectedCat == null,
              onTap: () => onSelect(null),
            ),
            SizedBox(width: 10.w),
            ...StoreCategory.values.map((cat) => Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: _CategoryChip(
                    icon: _categoryIcon(cat),
                    label: cat.label,
                    isSelected: selectedCat == cat,
                    onTap: () => onSelect(cat),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(StoreCategory cat) => switch (cat) {
        StoreCategory.alimentation => Icons.restaurant_rounded,
        StoreCategory.cosmetique => Icons.face_retouching_natural,
        StoreCategory.hygiene => Icons.sanitizer_rounded,
        StoreCategory.electromenager => Icons.electrical_services_rounded,
        StoreCategory.autre => Icons.category_rounded,
      };
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.gradient1 : null,
          color: isSelected
              ? null
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.grey300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected ? AppColors.white : AppColors.grey600,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyles.labelSmall(
                color: isSelected ? AppColors.white : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader — "Grossistes à proximité" + count badge
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.stores});

  final List<StoreEntity> stores;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
        child: Row(
          children: [
            Text(
              'Grossistes à proximité',
              style: AppTextStyles.titleSmall(
                color: context.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${stores.length}',
                style: AppTextStyles.labelSmall(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StoreList — redesigned card with category icon + staggered animation
// ─────────────────────────────────────────────────────────────────────────────

class _StoreList extends StatelessWidget {
  const _StoreList({required this.stores});

  final List<StoreEntity> stores;

  @override
  Widget build(BuildContext context) {
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
          final staggerDelay = index * 0.05;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Interval(
              staggerDelay.clamp(0.0, 0.6),
              1.0,
              curve: Curves.easeOutCubic,
            ),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 24.h * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _StoreCard(
              store: store,
              onTap: () => context.go(AppRoutes.storeDetail(store.id)),
            ),
          );
        },
        childCount: stores.length,
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.onTap});

  final StoreEntity store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Material(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        elevation: 1,
        shadowColor: AppColors.shadow,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                _CategoryIcon(category: store.category),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              style: AppTextStyles.titleSmall(
                                color: context.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (store.distanceInKm != null) ...[
                            SizedBox(width: 8.w),
                            _DistanceBadge(km: store.distanceInKm!),
                          ],
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          _MiniCategoryChip(label: store.category.label),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.location_on_outlined,
                            size: 11.sp,
                            color: AppColors.grey500,
                          ),
                          SizedBox(width: 2.w),
                          Flexible(
                            child: Text(
                              store.wilaya,
                              style: AppTextStyles.bodySmall(
                                color: AppColors.grey500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});

  final StoreCategory category;

  @override
  Widget build(BuildContext context) {
    final (icon, gradient) = switch (category) {
      StoreCategory.alimentation => (
        Icons.restaurant_rounded,
        const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF4C8C4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      StoreCategory.cosmetique => (
        Icons.face_retouching_natural,
        const LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFFCE93D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      StoreCategory.hygiene => (
        Icons.sanitizer_rounded,
        const LinearGradient(
          colors: [Color(0xFF0277BD), Color(0xFF4FC3F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      StoreCategory.electromenager => (
        Icons.electrical_services_rounded,
        const LinearGradient(
          colors: [Color(0xFFE65100), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      StoreCategory.autre => (
        Icons.category_rounded,
        const LinearGradient(
          colors: [Color(0xFF616161), Color(0xFFBDBDBD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    };

    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(icon, color: AppColors.white, size: 24.sp),
    );
  }
}

class _MiniCategoryChip extends StatelessWidget {
  const _MiniCategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColors.secondaryDark),
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.km});

  final double km;

  @override
  Widget build(BuildContext context) {
    final label = km < 1
        ? '${(km * 1000).round()} m'
        : '${km.toStringAsFixed(1)} km';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me_rounded, size: 10.sp, color: AppColors.primary),
          SizedBox(width: 3.w),
          Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FilterSheetContent — filter bottom sheet with radius + category
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSheetContent extends StatefulWidget {
  const _FilterSheetContent({
    required this.initialRadius,
    required this.selectedCat,
    required this.onApply,
  });

  final double initialRadius;
  final StoreCategory? selectedCat;
  final void Function(double radius, StoreCategory? category) onApply;

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late double _radius;
  late StoreCategory? _category;

  @override
  void initState() {
    super.initState();
    _radius = widget.initialRadius;
    _category = widget.selectedCat;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtres',
                style: AppTextStyles.titleMedium(
                  color: context.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _radius = 10.0;
                    _category = null;
                  });
                },
                child: Text(
                  'Réinitialiser',
                  style: AppTextStyles.labelSmall(color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Rayon de recherche',
            style: AppTextStyles.labelMedium(
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '5 km',
                style: AppTextStyles.bodySmall(color: AppColors.grey500),
              ),
              Expanded(
                child: Slider(
                  value: _radius,
                  min: 5,
                  max: 50,
                  divisions: 9,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.grey300,
                  label: '${_radius.round()} km',
                  onChanged: (v) => setState(() => _radius = v),
                ),
              ),
              Text(
                '50 km',
                style: AppTextStyles.bodySmall(color: AppColors.grey500),
              ),
            ],
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${_radius.round()} km',
                style: AppTextStyles.labelMedium(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Catégorie',
            style: AppTextStyles.labelMedium(
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _FilterCategoryChip(
                icon: Icons.all_inclusive_rounded,
                label: 'Toutes',
                isSelected: _category == null,
                onTap: () => setState(() => _category = null),
              ),
              ...StoreCategory.values.map(
                (cat) => _FilterCategoryChip(
                  icon: _filterCategoryIcon(cat),
                  label: cat.label,
                  isSelected: _category == cat,
                  onTap: () => setState(() => _category = cat),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_radius, _category);
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
              child: Text(
                'Appliquer',
                style: AppTextStyles.labelLarge(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _filterCategoryIcon(StoreCategory cat) => switch (cat) {
        StoreCategory.alimentation => Icons.restaurant_rounded,
        StoreCategory.cosmetique => Icons.face_retouching_natural,
        StoreCategory.hygiene => Icons.sanitizer_rounded,
        StoreCategory.electromenager => Icons.electrical_services_rounded,
        StoreCategory.autre => Icons.category_rounded,
      };
}

class _FilterCategoryChip extends StatelessWidget {
  const _FilterCategoryChip({
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.gradient1 : null,
          color: isSelected ? null : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.grey300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected ? AppColors.white : AppColors.grey600,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyles.labelSmall(
                color: isSelected ? AppColors.white : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShimmerStatCard — loading placeholder for stat cards
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 90.h,
        margin: EdgeInsets.only(right: 10.w),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 50.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
