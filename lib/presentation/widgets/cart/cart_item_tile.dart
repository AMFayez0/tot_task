import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/cart_item.dart';
import 'package:cart_task/presentation/providers/product_provider.dart';

class CartItemTile extends ConsumerWidget {
  final CartItem cartItem;
  final Function(int) onUpdateQuantity;
  final Function(int) onRemoveItem;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get product details
    final productAsync = ref.watch(productByIdProvider(cartItem.productId));

    return productAsync.when(
      data: (product) {
        return Dismissible(
          key: Key('cart_item_${cartItem.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onRemoveItem(cartItem.id),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            title: Text(product.name),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => onUpdateQuantity(cartItem.quantity - 1),
                ),
                Text('${cartItem.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => onUpdateQuantity(cartItem.quantity + 1),
                ),
              ],
            ),
          ),
        );
      },
      loading:
          () => const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Loading...'),
          ),
      error:
          (error, stackTrace) =>
              ListTile(title: Text('Error loading product: $error')),
    );
  }
}
