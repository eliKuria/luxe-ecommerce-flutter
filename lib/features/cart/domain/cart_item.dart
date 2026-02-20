import 'package:luxe/features/catalog/domain/product.dart';

class CartItem {
  final int id;
  final Product product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    int? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      product: Product.fromJson(json['products'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
