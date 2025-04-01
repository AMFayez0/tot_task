import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/presentation/providers/cart_provider.dart';
import 'package:cart_task/presentation/providers/cart_item_provider.dart';
import 'package:cart_task/presentation/providers/product_provider.dart';
import 'package:cart_task/presentation/providers/coupon_provider.dart';
import 'package:cart_task/presentation/providers/user_provider.dart';
import 'package:cart_task/domain/entities/product.dart';

class CartService {
  final WidgetRef ref;
  final BuildContext context;

  CartService(this.ref, this.context);

  // Update quantity in cart from product card
  Future<void> updateQuantityFromCard(
    int cartItemId,
    int newQuantity,
    int productId,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final cartNotifier = ref.read(
      cartNotifierProvider(currentUser.id).notifier,
    );
    await cartNotifier.updateQuantity(cartItemId, newQuantity);

    // Refresh providers to update UI
    ref.refresh(cartItemsProvider(currentUser.id));
    ref.refresh(cartTotalProvider(currentUser.id));
    ref.refresh(
      isProductInCartProvider((userId: currentUser.id, productId: productId)),
    );
    ref.refresh(
      cartItemByProductProvider((userId: currentUser.id, productId: productId)),
    );
  }

  // Remove item from cart from product card
  Future<void> removeFromCartFromCard(int cartItemId, int productId) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final removeFromCart = ref.read(removeProductFromCartProvider);
    await removeFromCart.execute(cartItemId);

    // Refresh providers to update UI
    ref.refresh(cartItemsProvider(currentUser.id));
    ref.refresh(cartTotalProvider(currentUser.id));
    ref.refresh(
      isProductInCartProvider((userId: currentUser.id, productId: productId)),
    );
    ref.refresh(
      cartItemByProductProvider((userId: currentUser.id, productId: productId)),
    );
  }

  Future<void> updateQuantity(
    int cartItemId,
    int newQuantity,
    int userId,
  ) async {
    try {
      // If new quantity is 0, remove the item from cart instead of updating
      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      final cartNotifier = ref.read(cartNotifierProvider(userId).notifier);
      await cartNotifier.updateQuantity(cartItemId, newQuantity);

      // Refresh all relevant providers to immediately update UI
      ref.refresh(cartItemsProvider(userId));
      ref.refresh(cartTotalProvider(userId));

      // Also refresh the cart notifier to ensure UI is updated
      await cartNotifier.loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating quantity: $e')));
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) return;

      final removeFromCart = ref.read(removeProductFromCartProvider);
      await removeFromCart.execute(cartItemId);

      // Refresh all relevant providers to immediately update UI
      ref.refresh(cartItemsProvider(currentUser.id));
      ref.refresh(cartTotalProvider(currentUser.id));

      // Also refresh the cart notifier to ensure UI is updated
      final cartNotifier = ref.read(
        cartNotifierProvider(currentUser.id).notifier,
      );
      await cartNotifier.loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing item: $e')));
    }
  }

  Future<void> clearCart(int userId) async {
    try {
      final cartNotifier = ref.read(cartNotifierProvider(userId).notifier);
      await cartNotifier.clearCart();
      clearAppliedCoupon();

      // Refresh all relevant providers to immediately update UI
      ref.refresh(cartItemsProvider(userId));
      ref.refresh(cartTotalProvider(userId));

      // Refresh product-related cart providers to ensure home page is updated
      final productsAsync = ref.read(productsProvider);
      if (productsAsync.hasValue) {
        for (final product in productsAsync.value!) {
          ref.refresh(
            isProductInCartProvider((userId: userId, productId: product.id)),
          );
          ref.refresh(
            cartItemByProductProvider((userId: userId, productId: product.id)),
          );
        }
      }

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart cleared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error clearing cart: $e')));
    }
  }

  Future<void> applyCoupon(String code) async {
    if (code.isEmpty) return;

    try {
      final couponNotifier = ref.read(couponNotifierProvider.notifier);
      await couponNotifier.validateAndApplyCoupon(code);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error applying coupon: $e')));
    }
  }

  void clearAppliedCoupon() {
    final couponNotifier = ref.read(couponNotifierProvider.notifier);
    couponNotifier.clearCoupon();
  }

  // Method to handle back button to refresh cart-related providers
  Future<bool> handleBackButton(int userId) async {
    // Refresh all cart-related providers when navigating back
    if (userId != 0) {
      // Refresh product-related cart providers to ensure home page is updated
      final productsAsync = ref.read(productsProvider);
      if (productsAsync.hasValue) {
        for (final product in productsAsync.value!) {
          ref.refresh(
            isProductInCartProvider((userId: userId, productId: product.id)),
          );
          ref.refresh(
            cartItemByProductProvider((userId: userId, productId: product.id)),
          );
        }
      }
      // Refresh cart providers
      ref.refresh(cartItemsProvider(userId));
      ref.refresh(cartTotalProvider(userId));
    }
    return true;
  }
}
