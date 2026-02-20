import 'package:luxe/features/cart/domain/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(int productId, {int quantity = 1});
  Future<void> updateQuantity(int cartItemId, int quantity);
  Future<void> removeFromCart(int cartItemId);
}
