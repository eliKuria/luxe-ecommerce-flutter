import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/features/catalog/data/product_repository_impl.dart';
import 'package:luxe/features/catalog/domain/product.dart';
import 'package:luxe/features/catalog/domain/product_repository.dart';

final productRepositoryProvider =
    Provider<ProductRepository>((ref) => ProductRepositoryImpl());

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(
        ProductListNotifier.new);

final categoriesProvider = FutureProvider<List<String>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getCategories();
});

final productDetailProvider =
    FutureProvider.family<Product, int>((ref, id) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductById(id);
});

final newArrivalsProvider = FutureProvider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getNewArrivals(limit: 6);
});

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  late final ProductRepository _repository;

  @override
  Future<List<Product>> build() async {
    _repository = ref.watch(productRepositoryProvider);
    return _repository.getProducts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getProducts());
  }
}
