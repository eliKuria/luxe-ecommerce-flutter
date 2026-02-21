import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luxe/core/network/supa_service.dart';
import 'package:luxe/features/catalog/domain/product.dart';
import 'package:luxe/features/retailer_inventory/domain/retailer_inventory_repository.dart';

class RetailerInventoryRepositoryImpl implements RetailerInventoryRepository {
  final SupabaseClient _client = SupaService.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Authentication required');
    return user.id;
  }

  @override
  Future<List<Product>> getMyProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('seller_id', _userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load my products: $e');
    }
  }

  @override
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final data = {
        ...productData,
        'seller_id': _userId,
        'created_at': DateTime.now().toIso8601String(),
      };
      await _client.from('products').insert(data);
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _client
          .from('products')
          .delete()
          .eq('id', id)
          .eq('seller_id', _userId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<List<dynamic>> getSellerOrders() async {
    try {
      // Fetch order items sold by this seller, including order info
      final response = await _client
          .from('order_items')
          .select('*, orders(*), products(*)')
          .eq('seller_id', _userId)
          .order('created_at', ascending: false);

      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch seller orders: $e');
    }
  }
}
