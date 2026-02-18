import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/features/catalog/domain/product.dart';

// Simulating a network delay for now
final productListProvider = AsyncNotifierProvider<ProductListNotifier, List<Product>>(() {
  return ProductListNotifier();
});

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Return dummy data for UI testing until Supabase is connected
    return [
      const Product(
        id: '1',
        name: 'Premium Leather Sneakers',
        description: 'Hand-crafted Italian leather sneakers with a minimalist design.',
        price: 199.00,
        images: ['https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=800&q=80'],
        sizes: ['40', '41', '42', '43', '44'],
        colors: ['White', 'Black', 'Tan'],
        inStock: true,
        rating: 4.8,
        reviewCount: 124,
      ),
      const Product(
        id: '2',
        name: 'Minimalist Wristwatch',
        description: 'Clean dial, sapphire crystal, and genuine leather strap.',
        price: 149.50,
        images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80'],
        sizes: [],
        colors: ['Silver', 'Gold'],
        inStock: true,
        rating: 4.9,
        reviewCount: 89,
      ),
      const Product(
        id: '3',
        name: 'Leather Tote Bag',
        description: 'Spacious and durable, perfect for daily essentials.',
        price: 245.00,
        images: ['https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=800&q=80'],
        sizes: [],
        colors: ['Brown', 'Black'],
        inStock: true,
        rating: 4.7,
        reviewCount: 56,
      ),
      const Product(
        id: '4',
        name: 'Wireless Headphones',
        description: 'Active noise cancellation with 30-hour battery life.',
        price: 299.00,
        images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80'],
        sizes: [],
        colors: ['Black', 'Silver'],
        inStock: true,
        rating: 4.6,
        reviewCount: 201,
      ),
      const Product(
        id: '5',
        name: 'Smart Desk Lamp',
        description: 'Adjustable color temperature and brightness via app.',
        price: 89.00,
        images: ['https://images.unsplash.com/photo-1507473888900-52e1ad14592d?auto=format&fit=crop&w=800&q=80'],
        sizes: [],
        colors: ['White', 'Black'],
        inStock: false,
        rating: 4.5,
        reviewCount: 34,
      ),
    ];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
      return build();
    });
  }
}
