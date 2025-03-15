import 'package:cart_task/presentation/providers/cart_item_provider.dart';
import 'package:cart_task/presentation/providers/cart_provider.dart';
import 'package:cart_task/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:cart_task/domain/entities/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
    builder:
        (context, ref, _) => Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Product details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _buildCartControls(context, ref),
                  ],
                ),
              ),
            ],
          ),
        ),
  );

  // Update quantity in cart
  void _updateQuantity(WidgetRef ref, int cartItemId, int newQuantity) async {
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
      isProductInCartProvider((userId: currentUser.id, productId: product.id)),
    );
    ref.refresh(
      cartItemByProductProvider((
        userId: currentUser.id,
        productId: product.id,
      )),
    );
  }

  // Remove item from cart
  void _removeFromCart(WidgetRef ref, int cartItemId) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final removeFromCart = ref.read(removeProductFromCartProvider);
    await removeFromCart.execute(cartItemId);

    // Refresh providers to update UI
    ref.refresh(cartItemsProvider(currentUser.id));
    ref.refresh(cartTotalProvider(currentUser.id));
    ref.refresh(
      isProductInCartProvider((userId: currentUser.id, productId: product.id)),
    );
    ref.refresh(
      cartItemByProductProvider((
        userId: currentUser.id,
        productId: product.id,
      )),
    );
  }

  Widget _buildCartControls(BuildContext context, WidgetRef ref) {
    // Get current user
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    // Check if product is in cart
    final isInCartAsync = ref.watch(
      isProductInCartProvider((userId: currentUser.id, productId: product.id)),
    );
    final cartItemAsync = ref.watch(
      cartItemByProductProvider((
        userId: currentUser.id,
        productId: product.id,
      )),
    );

    return isInCartAsync.when(
      data: (isInCart) {
        if (!isInCart) {
          // Show Add to Cart button if not in cart
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddToCart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              child: const Text('ADD TO CART'),
            ),
          );
        } else {
          // Show quantity controls if in cart
          return cartItemAsync.when(
            data: (cartItem) {
              if (cartItem == null) return const SizedBox.shrink();

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed:
                          cartItem.quantity > 1
                              ? () => _updateQuantity(
                                ref,
                                cartItem.id,
                                cartItem.quantity - 1,
                              )
                              : () => _removeFromCart(ref, cartItem.id),
                    ),
                    Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed:
                          () => _updateQuantity(
                            ref,
                            cartItem.id,
                            cartItem.quantity + 1,
                          ),
                    ),
                  ],
                ),
              );
            },
            loading:
                () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            error: (_, __) => const SizedBox.shrink(),
          );
        }
      },
      loading:
          () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}