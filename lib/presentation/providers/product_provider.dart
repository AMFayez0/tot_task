import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/product.dart';
import 'package:cart_task/domain/repositories/product_repository.dart';

// Provider for the product repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  // This will be overridden in the DISetup widget
  throw UnimplementedError('ProductRepository provider not implemented');
});

// Provider for all products
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getAllProducts();
});

// Provider for products by price range
final productsByPriceRangeProvider = FutureProvider.family<List<Product>, ({double min, double max})>(
  (ref, range) async {
    final repository = ref.watch(productRepositoryProvider);
    return repository.getProductsByPriceRange(range.min, range.max);
  },
);

// Provider for product search
final productSearchProvider = FutureProvider.family<List<Product>, String>(
  (ref, query) async {
    final repository = ref.watch(productRepositoryProvider);
    return repository.searchProducts(query);
  },
);

// Provider for a single product by ID
final productByIdProvider = FutureProvider.family<Product, int>(
  (ref, id) async {
    final repository = ref.watch(productRepositoryProvider);
    return repository.getProduct(id);
  },
);