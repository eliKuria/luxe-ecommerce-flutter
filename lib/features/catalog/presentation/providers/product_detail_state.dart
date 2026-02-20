import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected color for a product (per product ID)
final selectedColorProvider = StateProvider.family<String?, int>((ref, productId) => null);

/// Selected size for a product (per product ID)
final selectedSizeProvider = StateProvider.family<String?, int>((ref, productId) => null);

/// Quantity for add-to-cart (per product ID)
final productQuantityProvider = StateProvider.family<int, int>((ref, productId) => 1);
