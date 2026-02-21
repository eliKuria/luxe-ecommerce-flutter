import 'package:luxe/features/catalog/domain/product.dart';

abstract class RetailerInventoryRepository {
  Future<List<Product>> getMyProducts();
  Future<void> addProduct(Map<String, dynamic> productData);
  Future<void> deleteProduct(int id);
  Future<List<dynamic>> getSellerOrders();
}
