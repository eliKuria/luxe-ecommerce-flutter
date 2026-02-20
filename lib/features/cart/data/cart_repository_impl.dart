import 'package:luxe/core/network/supa_service.dart';
import 'package:luxe/features/cart/domain/cart_item.dart';
import 'package:luxe/features/cart/domain/cart_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartRepositoryImpl implements CartRepository {
  final SupabaseClient _client = SupaService.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Please log in to access your cart.');
    return user.id;
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    final response = await _client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addToCart(int productId, {int quantity = 1}) async {
    // Check if item already in cart
    final existing = await _client
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', _userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      // Increment quantity
      await _client.from('cart_items').update({
        'quantity': (existing['quantity'] as int) + quantity,
      }).eq('id', existing['id']);
    } else {
      await _client.from('cart_items').insert({
        'user_id': _userId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  @override
  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  @override
  Future<void> removeFromCart(int cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }
}
