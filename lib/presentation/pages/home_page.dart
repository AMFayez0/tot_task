import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/user.dart';
import 'package:cart_task/presentation/providers/product_provider.dart';
import 'package:cart_task/presentation/providers/user_provider.dart';
import 'package:cart_task/presentation/widgets/product_card.dart';
import 'package:cart_task/presentation/services/product_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create product service
    final productService = ProductService(ref, context);

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
                onAddToCart: () => productService.addToCart(product, userId),
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
}
