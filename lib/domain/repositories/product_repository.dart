import 'package:cart_task/domain/entities/product.dart';

abstract class ProductRepository {
  // Get product by ID
  Future<Product> getProduct(int id);

  // Get all products
  Future<List<Product>> getAllProducts();

  // Create a new product
  Future<Product> createProduct(Product product);

  // Update existing product
  Future<Product> updateProduct(Product product);

  // Delete product
  Future<void> deleteProduct(int id);

  // Search products by name
  Future<List<Product>> searchProducts(String query);

  // Get products by price range
  Future<List<Product>> getProductsByPriceRange(
    double minPrice,
    double maxPrice,
  );
}
