import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/sizer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../providers/cart_provider.dart';
import '../widgets/widgets.dart';

class CartPage extends HookConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartNotifierProvider.notifier).totalPrice;
    final notesController = useTextEditingController();
    final isSubmitting = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_rounded, size: 20.sp),
              onPressed: () => ref.read(cartNotifierProvider.notifier).clearCart(),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const CartEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                    itemCount: cart.length,
                    separatorBuilder: (_, _) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) =>
                        CartItemTile(item: cart[index]),
                  ),
                ),
                CartBottomBar(
                  total: total,
                  notesController: notesController,
                  isSubmitting: isSubmitting.value,
                  onSubmit: () async {
                    isSubmitting.value = true;
                    try {
                      final user =
                          ref.read(authNotifierProvider.notifier).currentUser;
                      if (user == null) return;

                      final params = PlaceOrderParams(
                        detaillantId: user.id,
                        storeId: cart.first.storeId,
                        items: cart,
                        total: total,
                        notes: notesController.text.isNotEmpty
                            ? notesController.text
                            : null,
                      );

                      await ref.read(placeOrderUseCaseProvider)(params);

                      if (context.mounted) {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            title: const Text('Commande envoyée'),
                            content: const Text(
                              'Votre commande a été transmise au grossiste. '
                              'Vous serez notifié de sa confirmation.',
                            ),
                            actions: [
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ref
                                      .read(cartNotifierProvider.notifier)
                                      .clearCart();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de la commande'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } finally {
                      isSubmitting.value = false;
                    }
                  },
                ),
              ],
            ),
    );
  }
}
