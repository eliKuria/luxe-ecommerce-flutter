import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/features/catalog/domain/product.dart';
import 'package:luxe/features/catalog/presentation/providers/product_providers.dart';

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Active category filter (null = All)
final searchCategoryProvider = StateProvider<String?>((ref) => null);

// Filtered search results
final searchResultsProvider = FutureProvider<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(searchCategoryProvider);
  final repo = ref.watch(productRepositoryProvider);

  return repo.searchProducts(query, category: category);
});
