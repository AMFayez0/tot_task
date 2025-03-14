import 'package:cart_task/domain/entities/cart_item.dart';
import 'package:cart_task/domain/repositories/cart_repository.dart';

class AddProductToCart {
  final CartRepository _cartRepository;

  AddProductToCart(this._cartRepository);

  Future<CartItem> execute({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    // Check if product already exists in cart
    final exists = await _cartRepository.isProductInCart(userId, productId);
    if (exists) {
      throw Exception('Product already exists in cart');
    }

    // Create new cart item
    final cartItem = CartItem(
      id: 0, // Will be set by database
      userId: userId,
      productId: productId,
      quantity: quantity,
      createdAt: DateTime.now(),
    );

    // Add to cart
    return await _cartRepository.addToCart(cartItem);
  }
}
