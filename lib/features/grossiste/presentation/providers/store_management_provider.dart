import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/failure.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../detaillant/domain/entities/store_entity.dart';
import '../../data/models/store_params.dart';
import '../../data/repositories/grossiste_repository_impl.dart';
import '../../domain/entities/my_store_entity.dart';
import '../../domain/repositories/grossiste_repository.dart';

part 'store_management_provider.g.dart';

@Riverpod(keepAlive: true)
GrossisteRepository grossisteRepository(GrossisteRepositoryRef ref) =>
    GrossisteRepositoryImpl();

@Riverpod(keepAlive: true)
class MyStoreNotifier extends _$MyStoreNotifier {
  @override
  Future<MyStoreEntity?> build() async {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.valueOrNull;
    if (user == null) return null;
    final repo = ref.watch(grossisteRepositoryProvider);
    return repo.getMyStore(user.id);
  }

  Future<void> createStore(StoreCreateParams params) async {
    final repo = ref.read(grossisteRepositoryProvider);
    await repo.createStore(params);
    ref.invalidateSelf();
  }

  Future<void> updateStore(StoreUpdateParams params) async {
    final repo = ref.read(grossisteRepositoryProvider);
    await repo.updateStore(params);
    ref.invalidateSelf();
  }
}

// ── Store form state ─────────────────────────────────────────────────────

class StoreFormState {
  const StoreFormState({
    this.name = '',
    this.description = '',
    this.category = StoreCategory.alimentation,
    this.phone = '',
    this.wilaya = '',
    this.address = '',
    this.lat,
    this.lng,
    this.isLoading = false,
    this.errorMessage,
    this.nameError,
    this.descriptionError,
    this.phoneError,
    this.wilayaError,
    this.addressError,
  });

  final String name;
  final String description;
  final StoreCategory category;
  final String phone;
  final String wilaya;
  final String address;
  final double? lat;
  final double? lng;
  final bool isLoading;
  final String? errorMessage;
  final String? nameError;
  final String? descriptionError;
  final String? phoneError;
  final String? wilayaError;
  final String? addressError;

  bool get isValid =>
      nameError == null &&
      descriptionError == null &&
      phoneError == null &&
      wilayaError == null &&
      addressError == null;

  StoreFormState copyWith({
    String? name,
    String? description,
    StoreCategory? category,
    String? phone,
    String? wilaya,
    String? address,
    Object? lat = _sentinel,
    Object? lng = _sentinel,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Object? nameError = _sentinel,
    Object? descriptionError = _sentinel,
    Object? phoneError = _sentinel,
    Object? wilayaError = _sentinel,
    Object? addressError = _sentinel,
  }) {
    return StoreFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      wilaya: wilaya ?? this.wilaya,
      address: address ?? this.address,
      lat: lat == _sentinel ? this.lat : lat as double?,
      lng: lng == _sentinel ? this.lng : lng as double?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      nameError:
          nameError == _sentinel ? this.nameError : nameError as String?,
      descriptionError: descriptionError == _sentinel
          ? this.descriptionError
          : descriptionError as String?,
      phoneError:
          phoneError == _sentinel ? this.phoneError : phoneError as String?,
      wilayaError:
          wilayaError == _sentinel ? this.wilayaError : wilayaError as String?,
      addressError: addressError == _sentinel
          ? this.addressError
          : addressError as String?,
    );
  }
}

const _sentinel = Object();

class StoreFormNotifier extends StateNotifier<StoreFormState> {
  StoreFormNotifier() : super(const StoreFormState());

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

  void updateCategory(StoreCategory value) {
    state = state.copyWith(category: value, errorMessage: null);
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value, errorMessage: null, phoneError: null);
  }

  void updateWilaya(String value) {
    state = state.copyWith(
      wilaya: value,
      errorMessage: null,
      wilayaError: null,
    );
  }

  void updateAddress(String value) {
    state = state.copyWith(
      address: value,
      errorMessage: null,
      addressError: null,
    );
  }

  void updateLatLng(double? lat, double? lng) {
    state = state.copyWith(lat: lat, lng: lng, errorMessage: null);
  }

  bool validate() {
    final nameErr = state.name.trim().isEmpty ? 'Le nom est requis.' : null;
    final descErr =
        state.description.trim().isEmpty ? 'La description est requise.' : null;
    final phoneErr = state.phone.trim().isEmpty
        ? 'Le téléphone est requis.'
        : null;
    final wilayaErr =
        state.wilaya.trim().isEmpty ? 'La wilaya est requise.' : null;
    final addrErr =
        state.address.trim().isEmpty ? 'L\'adresse est requise.' : null;

    state = state.copyWith(
      nameError: nameErr,
      descriptionError: descErr,
      phoneError: phoneErr,
      wilayaError: wilayaErr,
      addressError: addrErr,
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

  void reset() => state = const StoreFormState();
}

final storeFormProvider =
    StateNotifierProvider.autoDispose<StoreFormNotifier, StoreFormState>(
  (_) => StoreFormNotifier(),
);
