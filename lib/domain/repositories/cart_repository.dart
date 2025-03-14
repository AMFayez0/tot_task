import 'package:cart_task/domain/entities/cart_item.dart';

abstract class CartRepository {
  // Get cart items for a user
  Future<List<CartItem>> getCartItems(int userId);

  // Add item to cart
  Future<CartItem> addToCart(CartItem item);

  // Update cart item quantity
  Future<CartItem> updateCartItemQuantity(int cartItemId, int quantity);

  // Remove item from cart
  Future<void> removeFromCart(int cartItemId);

  // Clear user's cart
  Future<void> clearCart(int userId);

  // Get cart total
  Future<double> getCartTotal(int userId);

  // Check if product exists in cart
  Future<bool> isProductInCart(int userId, int productId);

  // Get cart item by ID
  Future<CartItem?> getCartItem(int cartItemId);
}
