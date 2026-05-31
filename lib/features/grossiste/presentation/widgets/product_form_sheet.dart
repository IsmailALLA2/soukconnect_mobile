import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/failure.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/green_spinner.dart';
import '../../../detaillant/domain/entities/product_entity.dart';
import '../../data/models/product_params.dart';
import '../providers/product_management_provider.dart';

enum _SheetMode { create, edit }

final _units = ['unité', 'carton', 'kg', 'litre', 'douzaine', 'sac'];

Future<void> showCreateProductSheet(
  BuildContext context,
  String storeId,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _ProductFormSheet(
      mode: _SheetMode.create,
      storeId: storeId,
    ),
  );
}

Future<void> showEditProductSheet(
  BuildContext context,
  ProductEntity product,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _ProductFormSheet(
      mode: _SheetMode.edit,
      storeId: product.storeId,
      product: product,
    ),
  );
}

class _ProductFormSheet extends ConsumerStatefulWidget {
  const _ProductFormSheet({
    required this.mode,
    required this.storeId,
    this.product,
  });

  final _SheetMode mode;
  final String storeId;
  final ProductEntity? product;

  @override
  ConsumerState<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<_ProductFormSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.mode == _SheetMode.edit && widget.product != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final n = ref.read(productFormProvider.notifier);
        final p = widget.product!;
        n.updateName(p.name);
        n.updateDescription(p.description);
        n.updatePrice(p.price.toStringAsFixed(2));
        n.updateUnit(p.unit);
        n.updateStock(p.stock.toString());
        if (p.hasImage) n.updateImageUrl(p.imageUrl!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(productFormProvider);
    final notifier = ref.read(productFormProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.mode == _SheetMode.create
                          ? 'Ajouter un produit'
                          : 'Modifier le produit',
                      style: AppTextStyles.titleLarge(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            if (form.errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 18.sp, color: AppColors.error),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          form.errorMessage!,
                          style:
                              AppTextStyles.bodySmall(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.all(16.w),
                children: [
                  TextField(
                    onChanged: notifier.updateName,
                    decoration: InputDecoration(
                      labelText: 'Nom du produit',
                      hintText: 'Ex: Huile d\'olive 5L',
                      errorText: form.nameError,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    onChanged: notifier.updateDescription,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description (optionnelle)',
                      hintText: 'Description du produit...',
                      errorText: form.descriptionError,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    onChanged: notifier.updatePrice,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Prix (MAD)',
                      hintText: '120',
                      errorText: form.priceError,
                      suffixText: 'MAD',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _UnitDropdown(
                    value: form.unit,
                    error: form.unitError,
                    onChanged: notifier.updateUnit,
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    onChanged: notifier.updateStock,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Stock',
                      hintText: '50',
                      errorText: form.stockError,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    onChanged: notifier.updateImageUrl,
                    decoration: InputDecoration(
                      labelText: 'URL de l\'image (optionnelle)',
                      hintText: 'https://...',
                    ),
                  ),
                  SizedBox(height: 24.h),
                  FilledButton(
                    onPressed:
                        form.isLoading ? null : () => _save(context, form),
                    child: form.isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const GreenSpinner(size: 22, color: AppColors.white),
                          )
                        : Text(
                            widget.mode == _SheetMode.create
                                ? 'Ajouter'
                                : 'Enregistrer',
                          ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, ProductFormState form) async {
    final notifier = ref.read(productFormProvider.notifier);
    if (!notifier.validate()) return;

    final navigator = Navigator.of(context);
    notifier.setLoading(true);
    try {
      if (widget.mode == _SheetMode.create) {
        await ref
            .read(myProductsNotifierProvider(widget.storeId).notifier)
            .addProduct(ProductCreateParams(
              storeId: widget.storeId,
              name: form.name.trim(),
              description: form.description.trim(),
              price: form.priceValue!,
              unit: form.unit.trim(),
              stock: form.stockValue!,
              imageUrl: form.imageUrl.trim().isEmpty
                  ? null
                  : form.imageUrl.trim(),
            ));
      } else {
        await ref
            .read(myProductsNotifierProvider(widget.storeId).notifier)
            .updateProduct(ProductUpdateParams(
              id: widget.product!.id,
              storeId: widget.storeId,
              name: form.name.trim(),
              description: form.description.trim(),
              price: form.priceValue!,
              unit: form.unit.trim(),
              stock: form.stockValue!,
              imageUrl: form.imageUrl.trim().isEmpty
                  ? null
                  : form.imageUrl.trim(),
            ));
      }
      if (mounted) navigator.pop();
    } on Failure catch (e) {
      notifier.setError(e.message);
    } catch (_) {
      notifier.setError('Une erreur inattendue est survenue.');
    } finally {
      notifier.setLoading(false);
    }
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.value,
    this.error,
    required this.onChanged,
  });

  final String value;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(12.r),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Unité',
          errorText: error,
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
        ),
        child: Text(
          value.isEmpty ? 'Sélectionner...' : value,
          style: AppTextStyles.bodyMedium(
            color: value.isEmpty ? AppColors.grey500 : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Choisir une unité',
              style: AppTextStyles.titleMedium(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ..._units.map(
            (u) => ListTile(
              title: Text(u),
              trailing: value == u
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                onChanged(u);
                context.pop();
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
