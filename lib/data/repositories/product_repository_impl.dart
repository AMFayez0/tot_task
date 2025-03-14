import 'package:cart_task/data/data_sources/local_db_service.dart';
import 'package:cart_task/domain/entities/product.dart';
import 'package:cart_task/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final LocalDBService _dbService;

  ProductRepositoryImpl(this._dbService);

  @override
  Future<Product> createProduct(Product product) async {
    final id = await _dbService.insert(
      LocalDBService.productTable,
      product.toMap(),
    );
    return product.copyWith(id: id);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _dbService.delete(
      LocalDBService.productTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final maps = await _dbService.query(LocalDBService.productTable);
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  @override
  Future<Product> getProduct(int id) async {
    final maps = await _dbService.query(
      LocalDBService.productTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Product not found');
    }

    return Product.fromMap(maps.first);
  }

  @override
  Future<List<Product>> getProductsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    final maps = await _dbService.query(
      LocalDBService.productTable,
      where: 'price BETWEEN ? AND ?',
      whereArgs: [minPrice, maxPrice],
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final maps = await _dbService.query(
      LocalDBService.productTable,
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await _dbService.update(
      LocalDBService.productTable,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    return product;
  }
}
