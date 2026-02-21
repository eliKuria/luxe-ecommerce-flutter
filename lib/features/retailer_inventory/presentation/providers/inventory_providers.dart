import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/features/catalog/domain/product.dart';
import 'package:luxe/features/retailer_inventory/data/retailer_inventory_repository_impl.dart';
import 'package:luxe/features/retailer_inventory/domain/retailer_inventory_repository.dart';

final retailerInventoryRepositoryProvider = Provider<RetailerInventoryRepository>(
  (ref) => RetailerInventoryRepositoryImpl(),
);

final myProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(retailerInventoryRepositoryProvider).getMyProducts();
});

final sellerOrdersProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(retailerInventoryRepositoryProvider).getSellerOrders();
});

class InventoryController extends StateNotifier<AsyncValue<void>> {
  final RetailerInventoryRepository _repository;
  final Ref _ref;

  InventoryController(this._repository, this._ref) : super(const AsyncData(null));

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    state = const AsyncLoading();
    try {
      await _repository.addProduct(productData);
      state = const AsyncData(null);
      _ref.invalidate(myProductsProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final inventoryControllerProvider = StateNotifierProvider<InventoryController, AsyncValue<void>>((ref) {
  final repository = ref.watch(retailerInventoryRepositoryProvider);
  return InventoryController(repository, ref);
});
