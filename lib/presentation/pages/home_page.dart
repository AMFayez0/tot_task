import 'package:cart_task/presentation/providers/cart_item_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/product.dart';
import 'package:cart_task/domain/entities/user.dart';
import 'package:cart_task/presentation/providers/product_provider.dart';
import 'package:cart_task/presentation/providers/user_provider.dart';
import 'package:cart_task/presentation/providers/cart_provider.dart';
import 'package:cart_task/presentation/widgets/product_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For demo purposes, we'll use a hardcoded user ID
    // In a real app, this would come from authentication
    const int userId = 1;

    // Initialize the current user if it's not set
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      // Use a post-frame callback to avoid setting state during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentUserProvider.notifier).state = User(
          id: userId,
          name: 'Demo User',
          email: 'demo@example.com',
        );
      });
    }

    // Watch the products provider
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search not implemented yet')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onAddToCart: () => _addToCart(context, ref, product, userId),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) =>
                Center(child: Text('Error loading products: $error')),
      ),
    );
  }

  void _addToCart(
    BuildContext context,
    WidgetRef ref,
    Product product,
    int userId,
  ) async {
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

      if (context.mounted) {
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
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}