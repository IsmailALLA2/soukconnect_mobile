import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/failure.dart';
import '../../../detaillant/domain/entities/product_entity.dart';
import '../../data/models/product_params.dart';
import 'store_management_provider.dart';

part 'product_management_provider.g.dart';

@Riverpod(keepAlive: true)
class MyProductsNotifier extends _$MyProductsNotifier {
  @override
  Future<List<ProductEntity>> build(String storeId) async {
    final repo = ref.watch(grossisteRepositoryProvider);
    return repo.getMyProducts(storeId);
  }

  Future<void> addProduct(ProductCreateParams params) async {
    final repo = ref.read(grossisteRepositoryProvider);
    await repo.createProduct(params);
    ref.invalidateSelf();
  }

  Future<void> updateProduct(ProductUpdateParams params) async {
    final repo = ref.read(grossisteRepositoryProvider);
    await repo.updateProduct(params);
    ref.invalidateSelf();
  }

  Future<void> deleteProduct(String productId) async {
    final repo = ref.read(grossisteRepositoryProvider);
    await repo.deleteProduct(productId);
    ref.invalidateSelf();
  }

  Future<void> toggleAvailability(ProductEntity product) async {
    final repo = ref.read(grossisteRepositoryProvider);
    await repo.updateProduct(ProductUpdateParams(
      id: product.id,
      storeId: storeId,
      name: product.name,
      description: product.description,
      price: product.price,
      unit: product.unit,
      stock: product.stock,
      imageUrl: product.imageUrl,
      isAvailable: !product.isAvailable,
    ));
    ref.invalidateSelf();
  }
}

// ── Product form state ───────────────────────────────────────────────────

class ProductFormState {
  const ProductFormState({
    this.name = '',
    this.description = '',
    this.price = '',
    this.unit = '',
    this.stock = '',
    this.imageUrl = '',
    this.isLoading = false,
    this.errorMessage,
    this.nameError,
    this.descriptionError,
    this.priceError,
    this.unitError,
    this.stockError,
  });

  final String name;
  final String description;
  final String price;
  final String unit;
  final String stock;
  final String imageUrl;
  final bool isLoading;
  final String? errorMessage;
  final String? nameError;
  final String? descriptionError;
  final String? priceError;
  final String? unitError;
  final String? stockError;

  double? get priceValue => double.tryParse(price);
  int? get stockValue => int.tryParse(stock);

  bool get isValid =>
      nameError == null &&
      descriptionError == null &&
      priceError == null &&
      unitError == null &&
      stockError == null;

  ProductFormState copyWith({
    String? name,
    String? description,
    String? price,
    String? unit,
    String? stock,
    String? imageUrl,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Object? nameError = _sentinel,
    Object? descriptionError = _sentinel,
    Object? priceError = _sentinel,
    Object? unitError = _sentinel,
    Object? stockError = _sentinel,
  }) {
    return ProductFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      nameError:
          nameError == _sentinel ? this.nameError : nameError as String?,
      descriptionError: descriptionError == _sentinel
          ? this.descriptionError
          : descriptionError as String?,
      priceError:
          priceError == _sentinel ? this.priceError : priceError as String?,
      unitError:
          unitError == _sentinel ? this.unitError : unitError as String?,
      stockError:
          stockError == _sentinel ? this.stockError : stockError as String?,
    );
  }
}

const _sentinel = Object();

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  ProductFormNotifier() : super(const ProductFormState());

  void updateName(String value) {
    state = state.copyWith(name: value, errorMessage: null, nameError: null);
  }

  void updateDescription(String value) {
    state = state.copyWith(
      description: value,
      errorMessage: null,
      descriptionError: null,
    );
  }

  void updatePrice(String value) {
    state = state.copyWith(
      price: value,
      errorMessage: null,
      priceError: null,
    );
  }

  void updateUnit(String value) {
    state = state.copyWith(unit: value, errorMessage: null, unitError: null);
  }

  void updateStock(String value) {
    state = state.copyWith(
      stock: value,
      errorMessage: null,
      stockError: null,
    );
  }

  void updateImageUrl(String value) {
    state = state.copyWith(imageUrl: value, errorMessage: null);
  }

  bool validate() {
    final nameErr = state.name.trim().isEmpty ? 'Le nom est requis.' : null;
    final descErr =
        state.description.trim().isEmpty ? 'La description est requise.' : null;
    final priceErr = state.priceValue == null || state.priceValue! <= 0
        ? 'Prix invalide.'
        : null;
    final unitErr =
        state.unit.trim().isEmpty ? 'L\'unité est requise.' : null;
    final stockErr = state.stockValue == null || state.stockValue! < 0
        ? 'Stock invalide.'
        : null;

    state = state.copyWith(
      nameError: nameErr,
      descriptionError: descErr,
      priceError: priceErr,
      unitError: unitErr,
      stockError: stockErr,
    );
    return state.isValid;
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading, errorMessage: null);
  }

  void setError(String? message) {
    state = state.copyWith(isLoading: false, errorMessage: message);
  }

  Future<void> submit(Future<void> Function() action) async {
    if (!validate()) return;
    setLoading(true);
    try {
      await action();
    } on Failure catch (e) {
      setError(e.message);
    } catch (_) {
      setError('Une erreur inattendue est survenue.');
    } finally {
      setLoading(false);
    }
  }

  void reset() => state = const ProductFormState();
}

final productFormProvider =
    StateNotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>(
  (_) => ProductFormNotifier(),
);
