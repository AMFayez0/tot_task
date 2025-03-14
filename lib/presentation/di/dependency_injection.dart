import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/data/data_sources/local_db_service.dart';
import 'package:cart_task/data/data_sources/data_initializer.dart';
import 'package:cart_task/data/repositories/cart_repository_impl.dart';
import 'package:cart_task/data/repositories/coupon_repository_impl.dart';
import 'package:cart_task/data/repositories/product_repository_impl.dart';
import 'package:cart_task/data/repositories/user_repository_impl.dart';
import 'package:cart_task/domain/repositories/cart_repository.dart';
import 'package:cart_task/domain/repositories/coupon_repository.dart';
import 'package:cart_task/domain/repositories/product_repository.dart';
import 'package:cart_task/domain/repositories/user_repository.dart';

// Database service provider
final localDbServiceProvider = Provider<LocalDBService>((ref) {
  return LocalDBService.instance;
});

// Data initializer provider
final dataInitializerProvider = Provider<DataInitializer>((ref) {
  final dbService = ref.watch(localDbServiceProvider);
  return DataInitializer(dbService);
});

// Initialize data
final initializeDataProvider = FutureProvider<void>((ref) async {
  final initializer = ref.watch(dataInitializerProvider);
  await initializer.initializeData();
});

// Repository providers
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  // Initialize data when the repository is first accessed
  ref.watch(initializeDataProvider);
  final dbService = ref.watch(localDbServiceProvider);
  return ProductRepositoryImpl(dbService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dbService = ref.watch(localDbServiceProvider);
  return UserRepositoryImpl(dbService);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final dbService = ref.watch(localDbServiceProvider);
  return CartRepositoryImpl(dbService);
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  // Initialize data when the repository is first accessed
  ref.watch(initializeDataProvider);
  final dbService = ref.watch(localDbServiceProvider);
  return CouponRepositoryImpl(dbService);
});