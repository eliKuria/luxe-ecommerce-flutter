import 'package:luxe/core/network/supa_service.dart';
import 'package:luxe/features/catalog/domain/product.dart';
import 'package:luxe/features/catalog/domain/product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient _client = SupaService.client;

  @override
  Future<List<Product>> getProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product> getProductById(int id) async {
    final response = await _client
        .from('products')
        .select()
        .eq('id', id)
        .single();

    return Product.fromJson(response);
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await _client
        .from('products')
        .select('category')
        .order('category');

    final categories = <String>{};
    for (final row in response as List) {
      final cat = row['category'] as String?;
      if (cat != null && cat.isNotEmpty) {
        categories.add(cat);
      }
    }
    return categories.toList();
  }

  @override
  Future<List<Product>> searchProducts(String query, {String? category}) async {
    var request = _client.from('products').select();

    if (query.isNotEmpty) {
      request = request.ilike('name', '%$query%');
    }

    if (category != null && category.isNotEmpty) {
      request = request.eq('category', category);
    }

    final response = await request.order('created_at', ascending: false);

    return (response as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Product>> getNewArrivals({int limit = 5}) async {
    final response = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
