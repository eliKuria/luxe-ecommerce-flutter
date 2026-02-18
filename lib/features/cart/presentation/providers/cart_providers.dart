import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/features/cart/domain/cart_item.dart';
import 'package:luxe/features/catalog/domain/product.dart';

// Dummy data for now
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [
      const CartItem(
        product: Product(
          id: '1',
          name: 'Premium Leather Sneakers',
          description: 'Size: 42',
          price: 199.00,
          images: ['https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=800&q=80'],
          sizes: ['42'],
          colors: ['White'],
          inStock: true,
          rating: 4.8,
          reviewCount: 124,
        ),
        quantity: 1,
      ),
      const CartItem(
        product: Product(
          id: '2',
          name: 'Minimalist Wristwatch',
          description: 'Color: Silver',
          price: 149.50,
          images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80'],
          sizes: [],
          colors: ['Silver'],
          inStock: true,
          rating: 4.9,
          reviewCount: 89,
        ),
        quantity: 1,
      ),
    ];
  }

  void increment(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrement(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          if (item.quantity > 1)
            item.copyWith(quantity: item.quantity - 1)
          else
            item // Should probably remove if 0, but keeping simple for now
        else
          item,
    ];
  }
}
