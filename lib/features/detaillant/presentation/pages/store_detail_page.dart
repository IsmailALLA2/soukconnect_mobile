import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/store_entity.dart';
import '../providers/cart_provider.dart';
import '../providers/location_provider.dart';
import '../providers/product_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/store_inline_category_chip.dart';
import '../widgets/widgets.dart';

class StoreDetailPage extends HookConsumerWidget {
  const StoreDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = GoRouterState.of(context).pathParameters['storeId']!;
    final storeAsync = ref.watch(storeDetailProvider(storeId));
    final productsAsync = ref.watch(storeProductsProvider(storeId));
    final cart = ref.watch(cartNotifierProvider);
    final userPos = ref.watch(locationNotifierProvider).valueOrNull;
    final showGrid = useState(true);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              storeAsync.when(
                data: (store) => _StoreSliverAppBar(store: store),
                loading: () => _StoreSliverAppBar.loading(),
                error: (_, _) => _StoreSliverAppBar.loading(),
              ),

              storeAsync.when(
                data: (store) => _StoreInfoSection(
                  store: store,
                  userLat: userPos?.latitude,
                  userLng: userPos?.longitude,
                ),
                loading: () => const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                ),
                error: (e, _) => _StoreErrorTile(message: e.toString()),
              ),

              SliverToBoxAdapter(
                child: _ProductsHeader(
                  count: productsAsync.valueOrNull?.length ?? 0,
                  showGrid: showGrid.value,
                  onToggle: () =>
                      showGrid.value = !showGrid.value,
                ),
              ),

              productsAsync.when(
                loading: () => const ProductShimmerGrid(),
                error: (_, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 40.sp, color: AppColors.error),
                          SizedBox(height: 8.h),
                          Text(
                            'Erreur de chargement',
                            style: AppTextStyles.bodyMedium(
                                color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) return const EmptyProducts();
                  if (showGrid.value) {
                    return _ProductGrid(
                      products: products,
                      storeId: storeId,
                    );
                  }
                  return _ProductList(
                    products: products,
                    storeId: storeId,
                  );
                },
              ),

              if (cart.isNotEmpty)
                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          ),

          if (cart.isNotEmpty)
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: MediaQuery.paddingOf(context).bottom + 8.h,
              child: CartFloatingButton(
                totalItems:
                    cart.fold<int>(0, (sum, item) => sum + item.quantity),
                onTap: () => GoRouter.of(context).push('/detaillant/cart'),
              ),
            ),
        ],
      ),
    );
  }
}

// ── SliverAppBar ──────────────────────────────────────────────────────────────

class _StoreSliverAppBar extends StatelessWidget {
  const _StoreSliverAppBar({required this.store});

  final StoreEntity store;

  _StoreSliverAppBar.loading()
      : store = StoreEntity(
          id: '',
          ownerId: '',
          name: '',
          description: '',
          category: StoreCategory.autre,
          phone: '',
          wilaya: '',
          address: '',
          isActive: false,
          createdAt: DateTime(0),
        );

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240.h,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.store_rounded,
                  size: 80.sp,
                  color: AppColors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 100.h,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),
            // Store name bottom-aligned
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: AppTextStyles.headlineSmall(
                            color: AppColors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            StoreInlineCategoryChip.darkStyle(
                              label: store.category.label,
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.location_on_rounded,
                                size: 14.sp,
                                color: AppColors.white.withValues(alpha: 0.8)),
                            SizedBox(width: 3.w),
                            Text(
                              store.wilaya,
                              style: AppTextStyles.bodySmall(
                                color: AppColors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.only(left: 8.w, top: 4.h),
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 12,
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded,
                  size: 22.sp, color: AppColors.white),
              onPressed: () => GoRouter.of(context).pop(),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 8.w, top: 4.h),
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 12,
            child: SizedBox(
              width: 40.w,
              height: 40.w,
              child: IconButton(
                icon: Icon(Icons.share_outlined,
                    size: 20.sp, color: AppColors.white),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreErrorTile extends StatelessWidget {
  const _StoreErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
              SizedBox(height: 8.h),
              Text(
                'Impossible de charger la boutique',
                style: AppTextStyles.bodyMedium(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Store Info Section ────────────────────────────────────────────────────────

class _StoreInfoSection extends StatelessWidget {
  const _StoreInfoSection({
    required this.store,
    this.userLat,
    this.userLng,
  });

  final StoreEntity store;
  final double? userLat;
  final double? userLng;

  double? get _distance {
    if (userLat == null || userLng == null || !store.hasLocation) return null;
    return LocationUtils.calculateDistance(
      userLat!, userLng!, store.lat!, store.lng!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final distance = _distance;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            if (store.description.isNotEmpty) ...[
              Text(
                store.description,
                style: AppTextStyles.bodyMedium(color: AppColors.grey600),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16.h),
            ],

            // Info rows
            _InfoRow(
              icon: Icons.phone_outlined,
              iconGradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              label: 'Appeler',
              subtitle: store.phone,
              onTap: () {},
            ),
            SizedBox(height: 10.h),
            _InfoRow(
              icon: Icons.location_on_outlined,
              iconGradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
              ),
              label: store.address,
            ),
            if (distance != null) ...[
              SizedBox(height: 10.h),
              _InfoRow(
                icon: Icons.navigation_rounded,
                iconGradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
                label: '${distance.toStringAsFixed(1)} km de vous',
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: 12.sp, color: AppColors.grey400),
                onTap: () => GoRouter.of(context)
                    .push('/detaillant/map/${store.id}'),
              ),
            ],
            SizedBox(height: 14.h),

            // Map button + opening indicator
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => GoRouter.of(context)
                        .push('/detaillant/map/${store.id}'),
                    icon: Icon(Icons.map_rounded, size: 18.sp),
                    label: const Text('Voir sur la carte'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Ouvert',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    this.iconGradient,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Gradient? iconGradient;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  (iconGradient ?? const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]))
                      .createShader(bounds),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 20.sp, color: AppColors.white),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.titleSmall(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall(color: AppColors.grey500),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ── Products Header ───────────────────────────────────────────────────────────

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({
    required this.count,
    required this.showGrid,
    required this.onToggle,
  });

  final int count;
  final bool showGrid;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
      child: Row(
        children: [
          Text(
            'Produits disponibles',
            style: AppTextStyles.titleSmall(
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelSmall(color: AppColors.primary),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                _ToggleButton(
                  icon: Icons.grid_view_rounded,
                  isSelected: showGrid,
                  onTap: () {
                    if (!showGrid) onToggle();
                  },
                ),
                _ToggleButton(
                  icon: Icons.list_rounded,
                  isSelected: !showGrid,
                  onTap: () {
                    if (showGrid) onToggle();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: isSelected ? AppColors.white : AppColors.grey500,
        ),
      ),
    );
  }
}

// ── Product Grid ──────────────────────────────────────────────────────────────

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid({
    required this.products,
    required this.storeId,
  });

  final List<ProductEntity> products;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _ProductCard(
            product: products[index],
            storeId: storeId,
            index: index,
            onAdd: () => _addToCart(ref, products[index], storeId, context),
          ),
          childCount: products.length,
        ),
      ),
    );
  }
}

// ── Product List (horizontal) ─────────────────────────────────────────────────

class _ProductList extends ConsumerWidget {
  const _ProductList({
    required this.products,
    required this.storeId,
  });

  final List<ProductEntity> products;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 120.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: products.length,
          itemBuilder: (_, i) => _ProductListItem(
            product: products[i],
            storeId: storeId,
            onAdd: () => _addToCart(ref, products[i], storeId, context),
          ),
        ),
      ),
    );
  }
}

// ── Shared cart logic ─────────────────────────────────────────────────────────

void _addToCart(
  WidgetRef ref,
  ProductEntity product,
  String storeId,
  BuildContext context,
) {
  final result = ref.read(cartNotifierProvider.notifier).addItem(
        CartItem(product: product, quantity: 1, storeId: storeId),
      );
  if (result is CartAdded) {
    _showFloatingPlusOne(context);
  } else if (result is CartStoreConflict) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Changer de boutique'),
        content: const Text(
          'Votre panier contient déjà des produits d\'une autre '
          'boutique. Voulez-vous vider le panier et ajouter ce produit ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).forceClearAndAdd(
                    CartItem(product: product, quantity: 1, storeId: storeId),
                  );
              Navigator.of(ctx).pop();
              _showFloatingPlusOne(context);
            },
            child: const Text('Vider et ajouter'),
          ),
        ],
      ),
    );
  }
}

void _showFloatingPlusOne(BuildContext context) {
  final overlay = Overlay.of(context);
  final plusOneKey = GlobalKey<_FloatingPlusOneState>();

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _FloatingPlusOne(
      key: plusOneKey,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
  plusOneKey.currentState?.animate();
}

// ── Floating "+1" overlay ─────────────────────────────────────────────────────

class _FloatingPlusOne extends StatefulWidget {
  const _FloatingPlusOne({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<_FloatingPlusOne> createState() => _FloatingPlusOneState();
}

class _FloatingPlusOneState extends State<_FloatingPlusOne>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1, curve: Curves.easeOut)),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void animate() {} // called after insertion

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.paddingOf(context).bottom + 100.h,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, _slide.value.dy * 60.h),
            child: const Align(
              child: Material(
                color: Colors.transparent,
                child: Text(
                  '+1',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Product Card (grid) ───────────────────────────────────────────────────────

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.storeId,
    required this.index,
    required this.onAdd,
  });

  final ProductEntity product;
  final String storeId;
  final int index;
  final VoidCallback onAdd;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _cartBounceCtrl;
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cartBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _cartBounceCtrl.dispose();
    super.dispose();
  }

  void _onAdd() {
    _scaleCtrl.forward().then((_) => _scaleCtrl.reverse());
    _cartBounceCtrl.forward().then((_) {
      _cartBounceCtrl.reverse();
      setState(() => _added = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _added = false);
      });
    });
    widget.onAdd();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final inStock = product.inStock;
    final lowStock = product.stock > 0 && product.stock < 5;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + widget.index * 60),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleCtrl, _cartBounceCtrl]),
            builder: (_, child) => Transform.scale(
              scale: 1 - _scaleCtrl.value * 0.05,
              child: child,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.grey200),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: product.hasImage
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: context.isDark
                                  ? AppColors.grey800
                                  : AppColors.grey100,
                            ),
                            errorWidget: (_, _, _) =>
                                const _ImagePlaceholder(),
                          )
                        : const _ImagePlaceholder(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTextStyles.labelMedium(
                              color: context.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            '${product.price.toStringAsFixed(0)} MAD / ${product.unit}',
                            style: AppTextStyles.bodySmall(
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: lowStock
                                      ? AppColors.warningLight
                                      : inStock
                                          ? AppColors.successLight
                                          : AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: _StockLabel(
                                  inStock: inStock,
                                  lowStock: lowStock,
                                  stock: product.stock,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 30.w,
                                height: 30.w,
                                child: IconButton(
                                  onPressed: inStock ? _onAdd : null,
                                  padding: EdgeInsets.zero,
                                  icon: AnimatedBuilder(
                                    animation: _cartBounceCtrl,
                                    builder: (_, child) => Transform.translate(
                                      offset: Offset(
                                        0,
                                        -_cartBounceCtrl.value * 4,
                                      ),
                                      child: Icon(
                                        _added
                                            ? Icons.check_rounded
                                            : Icons.add_rounded,
                                        size: 18.sp,
                                        color: inStock
                                            ? AppColors.primary
                                            : AppColors.grey400,
                                      ),
                                    ),
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: inStock
                                        ? AppColors.primaryLight
                                            .withValues(alpha: 0.15)
                                        : AppColors.grey200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

class _StockLabel extends StatelessWidget {
  const _StockLabel({
    required this.inStock,
    required this.lowStock,
    required this.stock,
  });

  final bool inStock;
  final bool lowStock;
  final int stock;

  @override
  Widget build(BuildContext context) {
    if (!inStock) {
      return Text(
        'Rupture',
        style: AppTextStyles.labelSmall(color: AppColors.error),
      );
    }
    if (lowStock) {
      return Text(
        'Plus que $stock',
        style: AppTextStyles.labelSmall(color: AppColors.warning),
      );
    }
    return Text(
      'En stock',
      style: AppTextStyles.labelSmall(color: AppColors.success),
    );
  }
}

// ── Product List Item (horizontal) ────────────────────────────────────────────

class _ProductListItem extends StatelessWidget {
  const _ProductListItem({
    required this.product,
    required this.storeId,
    required this.onAdd,
  });

  final ProductEntity product;
  final String storeId;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;

    return GestureDetector(
      onTap: inStock ? onAdd : null,
      child: Container(
        width: 280.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(12.r),
              ),
              child: SizedBox(
                width: 100.w,
                height: 120.h,
                child: product.hasImage
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: context.isDark
                              ? AppColors.grey800
                              : AppColors.grey100,
                        ),
                        errorWidget: (_, _, _) => const _ImagePlaceholder(),
                      )
                    : const _ImagePlaceholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.titleSmall(
                        color: context.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${product.price.toStringAsFixed(0)} MAD / ${product.unit}',
                      style: AppTextStyles.bodyMedium(color: AppColors.primary),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: inStock
                                ? AppColors.successLight
                                : AppColors.errorLight,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            inStock ? 'En stock' : 'Rupture',
                            style: AppTextStyles.labelSmall(
                              color: inStock
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.add_circle_outline_rounded,
                            size: 24.sp, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.isDark ? AppColors.grey800 : AppColors.grey100,
      child: Center(
        child: Icon(Icons.image_outlined,
            size: 32.sp, color: AppColors.grey400),
      ),
    );
  }
}
