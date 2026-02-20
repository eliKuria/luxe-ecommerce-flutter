import 'package:luxe/features/catalog/domain/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductById(int id);
  Future<List<String>> getCategories();
  Future<List<Product>> searchProducts(String query, {String? category});
}
