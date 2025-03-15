import 'package:cart_task/presentation/di/dependency_injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/cart_item.dart';
import 'package:cart_task/domain/repositories/cart_repository.dart';

// Provider to check if a product is in the cart
final isProductInCartProvider =
    FutureProvider.family<bool, ({int userId, int productId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(cartRepositoryProvider);
      return repository.isProductInCart(params.userId, params.productId);
    });

// Provider to get cart item by product ID and user ID
final cartItemByProductProvider = FutureProvider.family<
  CartItem?,
  ({int userId, int productId})
>((ref, params) async {
  final repository = ref.watch(cartRepositoryProvider);
  final cartItems = await repository.getCartItems(params.userId);
  try {
    return cartItems.firstWhere((item) => item.productId == params.productId);
  } catch (e) {
    // If no matching item is found, return null
    return null;
  }
});