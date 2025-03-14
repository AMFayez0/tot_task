import 'package:cart_task/domain/repositories/cart_repository.dart';

class RemoveProductFromCart {
  final CartRepository _cartRepository;

  RemoveProductFromCart(this._cartRepository);

  Future<void> execute(int cartItemId) async {
    // Check if cart item exists
    final cartItem = await _cartRepository.getCartItem(cartItemId);
    if (cartItem == null) {
      throw Exception('Cart item not found');
    }

    // Remove from cart
    await _cartRepository.removeFromCart(cartItemId);
  }
}
