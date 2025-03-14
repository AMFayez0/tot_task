import 'package:cart_task/data/data_sources/local_db_service.dart';
import 'package:cart_task/domain/entities/product.dart';
import 'package:cart_task/domain/entities/user.dart';
import 'package:cart_task/domain/entities/coupon.dart';

/// This class is responsible for initializing the database with sample data
class DataInitializer {
  final LocalDBService _dbService;

  DataInitializer(this._dbService);

  /// Initialize the database with sample data
  Future<void> initializeData() async {
    await _initializeUsers();
    await _initializeProducts();
    await _initializeCoupons();
  }

  /// Initialize users
  Future<void> _initializeUsers() async {
    final users = await _dbService.query(LocalDBService.userTable);
    if (users.isEmpty) {
      await _dbService.insert(
        LocalDBService.userTable,
        User(
          id: 1,
          name: 'Demo User',
          email: 'demo@example.com',
        ).toMap(),
      );
    }
  }

  /// Initialize products
  Future<void> _initializeProducts() async {
    final products = await _dbService.query(LocalDBService.productTable);
    if (products.isEmpty) {
      final sampleProducts = [
        Product(
          id: 1,
          name: 'Premium Headphones',
          description: 'High-quality wireless headphones with noise cancellation and premium sound quality.',
          price: 199.99,
          imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        ),
        Product(
          id: 2,
          name: 'Smart Watch',
          description: 'Track your fitness, receive notifications, and more with this stylish smart watch.',
          price: 149.99,
          imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        ),
        Product(
          id: 3,
          name: 'Wireless Earbuds',
          description: 'Compact and comfortable wireless earbuds with amazing sound quality and long battery life.',
          price: 89.99,
          imageUrl: 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        ),
        Product(
          id: 4,
          name: 'Smartphone',
          description: 'Latest model smartphone with high-resolution camera, fast processor, and long-lasting battery.',
          price: 799.99,
          imageUrl: 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        ),
        Product(
          id: 5,
          name: 'Laptop',
          description: 'Powerful laptop for work and entertainment with high-performance specs and sleek design.',
          price: 1299.99,
          imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        ),
        Product(
          id: 6,
          name: 'Bluetooth Speaker',
          description: 'Portable Bluetooth speaker with rich sound and waterproof design for outdoor adventures.',
          price: 79.99,
          imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        ),
        Product(
          id: 7,
          name: 'Digital Camera',
          description: 'Professional digital camera with high-resolution sensor and advanced features for photography enthusiasts.',
          price: 649.99,
          imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        ),
        Product(
          id: 8,
          name: 'Tablet',
          description: 'Versatile tablet with vibrant display, powerful performance, and long battery life for work and entertainment.',
          price: 349.99,
          imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        ),
      ];

      for (final product in sampleProducts) {
        await _dbService.insert(
          LocalDBService.productTable,
          product.toMap(),
        );
      }
    }
  }

  /// Initialize coupons
  Future<void> _initializeCoupons() async {
    final coupons = await _dbService.query(LocalDBService.couponTable);
    if (coupons.isEmpty) {
      final sampleCoupons = [
        Coupon(
          id: 1,
          code: 'WELCOME10',
          discountPercentage: 10,
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
        ),
        Coupon(
          id: 2,
          code: 'SUMMER20',
          discountPercentage: 20,
          expiryDate: DateTime.now().add(const Duration(days: 60)),
          isActive: true,
        ),
      ];

      for (final coupon in sampleCoupons) {
        await _dbService.insert(
          LocalDBService.couponTable,
          coupon.toMap(),
        );
      }
    }
  }
}