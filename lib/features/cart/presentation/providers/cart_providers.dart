import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/features/cart/data/cart_repository_impl.dart';
import 'package:luxe/features/cart/domain/cart_item.dart';
import 'package:luxe/features/cart/domain/cart_repository.dart';

final cartRepositoryProvider =
    Provider<CartRepository>((ref) => CartRepositoryImpl());

final cartProvider =
    AsyncNotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  late final CartRepository _repository;

  @override
  Future<List<CartItem>> build() async {
    _repository = ref.watch(cartRepositoryProvider);
    return _repository.getCartItems();
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    await _repository.addToCart(productId, quantity: quantity);
    state = await AsyncValue.guard(() => _repository.getCartItems());
  }

  Future<void> increment(int cartItemId, int currentQty) async {
    await _repository.updateQuantity(cartItemId, currentQty + 1);
    state = await AsyncValue.guard(() => _repository.getCartItems());
  }

  Future<void> decrement(int cartItemId, int currentQty) async {
    if (currentQty <= 1) {
      await _repository.removeFromCart(cartItemId);
    } else {
      await _repository.updateQuantity(cartItemId, currentQty - 1);
    }
    state = await AsyncValue.guard(() => _repository.getCartItems());
  }

  Future<void> remove(int cartItemId) async {
    await _repository.removeFromCart(cartItemId);
    state = await AsyncValue.guard(() => _repository.getCartItems());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getCartItems());
  }
}
