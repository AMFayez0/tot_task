import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/product.dart';
import 'package:cart_task/presentation/providers/cart_provider.dart';
import 'package:cart_task/presentation/providers/cart_item_provider.dart';

class ProductService {
  final WidgetRef ref;
  final BuildContext context;

  ProductService(this.ref, this.context);

  Future<void> addToCart(Product product, int userId) async {
    try {
      final addToCart = ref.read(addProductToCartProvider);
      await addToCart.execute(
        userId: userId,
        productId: product.id,
        quantity: 1,
      );

      // Refresh all relevant providers to immediately update UI
      ref.refresh(cartItemsProvider(userId));
      ref.refresh(cartTotalProvider(userId));
      ref.refresh(
        isProductInCartProvider((userId: userId, productId: product.id)),
      );
      ref.refresh(
        cartItemByProductProvider((userId: userId, productId: product.id)),
      );

      // Also refresh the cart notifier if it's being used
      final cartNotifier = ref.read(cartNotifierProvider(userId).notifier);
      await cartNotifier.loadCartItems();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
