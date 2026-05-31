import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/failure.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/green_spinner.dart';
import '../../../detaillant/domain/entities/store_entity.dart';
import '../../data/models/store_params.dart';
import '../../domain/entities/my_store_entity.dart';
import '../providers/store_management_provider.dart';

enum _SheetMode { create, edit }

final _wilayas = [
  'Casablanca-Settat',
  'Rabat-Salé-Kénitra',
  'Marrakech-Safi',
  'Fès-Meknès',
  'Tanger-Tétouan-Al Hoceïma',
  'Souss-Massa',
  'Oriental',
  'Béni Mellal-Khénifra',
  'Drâa-Tafilalet',
  'Guelmim-Oued Noun',
  'Laâyoune-Sakia El Hamra',
  'Dakhla-Oued Ed-Dahab',
];

Future<void> showCreateStoreSheet(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => const _StoreFormSheet(mode: _SheetMode.create),
  );
}

Future<void> showEditStoreSheet(
  BuildContext context,
  MyStoreEntity store,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _StoreFormSheet(mode: _SheetMode.edit, store: store),
  );
}

class _StoreFormSheet extends ConsumerStatefulWidget {
  const _StoreFormSheet({required this.mode, this.store});

  final _SheetMode mode;
  final MyStoreEntity? store;

  @override
  ConsumerState<_StoreFormSheet> createState() => _StoreFormSheetState();
}

class _StoreFormSheetState extends ConsumerState<_StoreFormSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.mode == _SheetMode.edit && widget.store != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(storeFormProvider.notifier);
        notifier.updateName(widget.store!.name);
        notifier.updateDescription(widget.store!.description);
        notifier.updateCategory(widget.store!.category);
        notifier.updatePhone(widget.store!.phone);
        notifier.updateWilaya(widget.store!.wilaya);
        notifier.updateAddress(widget.store!.address);
        notifier.updateLatLng(widget.store!.lat, widget.store!.lng);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(storeFormProvider);
    final notifier = ref.read(storeFormProvider.notifier);

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
                          ? 'Créer ma boutique'
                          : 'Modifier ma boutique',
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
                  _buildField(
                    label: 'Nom de la boutique',
                    error: form.nameError,
                    onChanged: notifier.updateName,
                    hint: 'Ex: Épicerie du Centre',
                  ),
                  SizedBox(height: 16.h),
                  _buildField(
                    label: 'Description',
                    error: form.descriptionError,
                    onChanged: notifier.updateDescription,
                    hint: 'Décrivez votre commerce...',
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),
                  _DropdownField(
                    label: 'Catégorie',
                    value: form.category.label,
                    onTap: () => _showCategoryPicker(context, notifier, form),
                  ),
                  SizedBox(height: 16.h),
                  _buildField(
                    label: 'Téléphone',
                    error: form.phoneError,
                    onChanged: notifier.updatePhone,
                    hint: '06 XX XX XX XX',
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16.h),
                  _DropdownField(
                    label: 'Wilaya / Région',
                    value: form.wilaya,
                    error: form.wilayaError,
                    onTap: () => _showWilayaPicker(context, notifier, form),
                  ),
                  SizedBox(height: 16.h),
                  _buildField(
                    label: 'Adresse',
                    error: form.addressError,
                    onChanged: notifier.updateAddress,
                    hint: 'Rue, numéro, quartier...',
                  ),
                  SizedBox(height: 16.h),
                  OutlinedButton.icon(
                    onPressed: () => _pickLocation(notifier),
                    icon: Icon(
                      form.lat != null
                          ? Icons.location_on_rounded
                          : Icons.my_location_rounded,
                      size: 18.sp,
                    ),
                    label: Text(
                      form.lat != null
                          ? 'Position définie ✓'
                          : 'Utiliser ma position actuelle',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  FilledButton(
                    onPressed: form.isLoading
                        ? null
                        : () => _save(form),
                    child: form.isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const GreenSpinner(size: 22, color: AppColors.white),
                          )
                        : Text(
                            widget.mode == _SheetMode.create
                                ? 'Créer la boutique'
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

  Widget _buildField({
    required String label,
    required String? error,
    required ValueChanged<String> onChanged,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
      ),
    );
  }

  Future<void> _pickLocation(StoreFormNotifier notifier) async {
    try {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        final granted = await Geolocator.requestPermission();
        if (granted == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition();
      notifier.updateLatLng(pos.latitude, pos.longitude);
    } catch (_) {}
  }

  void _showCategoryPicker(
    BuildContext context,
    StoreFormNotifier notifier,
    StoreFormState form,
  ) {
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
              'Choisir une catégorie',
              style: AppTextStyles.titleMedium(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ...StoreCategory.values.map(
            (c) => ListTile(
              title: Text(c.label),
              trailing: form.category == c
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                notifier.updateCategory(c);
                context.pop();
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  void _showWilayaPicker(
    BuildContext context,
    StoreFormNotifier notifier,
    StoreFormState form,
  ) {
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
              'Choisir une wilaya',
              style: AppTextStyles.titleMedium(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          SizedBox(
            height: 300.h,
            child: ListView(
              children: _wilayas
                  .map(
                    (w) => ListTile(
                      title: Text(w),
                      trailing: form.wilaya == w
                          ? const Icon(Icons.check_rounded,
                              color: AppColors.primary)
                          : null,
                      onTap: () {
                        notifier.updateWilaya(w);
                        context.pop();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Future<void> _save(StoreFormState form) async {
    final notifier = ref.read(storeFormProvider.notifier);
    if (!notifier.validate()) return;

    notifier.setLoading(true);
    try {
      if (widget.mode == _SheetMode.create) {
        await ref.read(myStoreNotifierProvider.notifier).createStore(
              StoreCreateParams(
                name: form.name.trim(),
                description: form.description.trim(),
                category: form.category,
                phone: form.phone.trim(),
                wilaya: form.wilaya.trim(),
                address: form.address.trim(),
                lat: form.lat,
                lng: form.lng,
              ),
            );
      } else {
        await ref.read(myStoreNotifierProvider.notifier).updateStore(
              StoreUpdateParams(
                id: widget.store!.id,
                name: form.name.trim(),
                description: form.description.trim(),
                category: form.category,
                phone: form.phone.trim(),
                wilaya: form.wilaya.trim(),
                address: form.address.trim(),
                lat: form.lat,
                lng: form.lng,
              ),
            );
      }
      if (mounted) context.pop();
    } on Failure catch (e) {
      notifier.setError(e.message);
    } catch (_) {
      notifier.setError('Une erreur inattendue est survenue.');
    } finally {
      notifier.setLoading(false);
    }
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    this.error,
    required this.onTap,
  });

  final String label;
  final String value;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
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
}
