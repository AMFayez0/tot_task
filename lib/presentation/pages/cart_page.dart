import 'package:cart_task/presentation/providers/cart_item_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/cart_item.dart';
import 'package:cart_task/presentation/providers/cart_provider.dart';
import 'package:cart_task/presentation/providers/product_provider.dart';
import 'package:cart_task/presentation/providers/coupon_provider.dart';
import 'package:cart_task/presentation/providers/user_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCouponCode;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current user ID
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    // Watch cart items
    final cartItemsAsync = ref.watch(cartItemsProvider(currentUser.id));
    // Watch cart total
    final cartTotalAsync = ref.watch(cartTotalProvider(currentUser.id));
    // Watch applied coupon
    final appliedCouponAsync = ref.watch(couponNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        // Refresh all cart-related providers when navigating back
        if (currentUser != null) {
          // Refresh product-related cart providers to ensure home page is updated
          final productsAsync = ref.read(productsProvider);
          if (productsAsync.hasValue) {
            for (final product in productsAsync.value!) {
              ref.refresh(
                isProductInCartProvider((
                  userId: currentUser.id,
                  productId: product.id,
                )),
              );
              ref.refresh(
                cartItemByProductProvider((
                  userId: currentUser.id,
                  productId: product.id,
                )),
              );
            }
          }
          // Refresh cart providers
          ref.refresh(cartItemsProvider(currentUser.id));
          ref.refresh(cartTotalProvider(currentUser.id));
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shopping Cart'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _clearCart(currentUser.id),
              tooltip: 'Clear Cart',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: cartItemsAsync.when(
                data: (cartItems) {
                  if (cartItems.isEmpty) {
                    return const Center(child: Text('Your cart is empty'));
                  }

                  return ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return _buildCartItemTile(cartItem, currentUser.id);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) =>
                        Center(child: Text('Error loading cart: $error')),
              ),
            ),
            _buildCouponSection(appliedCouponAsync),
            _buildCartSummary(cartTotalAsync, appliedCouponAsync),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement checkout functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout not implemented yet')),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: const Text('CHECKOUT'),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemTile(CartItem cartItem, int userId) {
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
          onDismissed: (_) => _removeFromCart(cartItem.id),
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
                  onPressed:
                      () => _updateQuantity(cartItem.id, cartItem.quantity - 1),
                ),
                Text('${cartItem.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed:
                      () => _updateQuantity(cartItem.id, cartItem.quantity + 1),
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

  Widget _buildCouponSection(AsyncValue<dynamic> appliedCouponAsync) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              decoration: InputDecoration(
                labelText: 'Coupon Code',
                hintText: 'Enter coupon code',
                errorText:
                    appliedCouponAsync.hasError
                        ? appliedCouponAsync.error.toString()
                        : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          ElevatedButton(
            onPressed:
                _appliedCouponCode != null
                    ? _clearAppliedCoupon
                    : () => _applyCoupon(_couponController.text),
            child: Text(_appliedCouponCode != null ? 'CLEAR' : 'APPLY'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(
    AsyncValue<double> cartTotalAsync,
    AsyncValue<dynamic> appliedCouponAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              cartTotalAsync.when(
                data: (total) => Text('\$${total.toStringAsFixed(2)}'),
                loading:
                    () => const CircularProgressIndicator(strokeWidth: 2.0),
                error: (error, _) => Text('Error: $error'),
              ),
            ],
          ),
          if (appliedCouponAsync.hasValue &&
              appliedCouponAsync.value != null) ...[
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount (${appliedCouponAsync.value!.discountPercentage}%):',
                ),
                cartTotalAsync.when(
                  data: (total) {
                    final discount =
                        total *
                        (appliedCouponAsync.value!.discountPercentage / 100);
                    return Text('-\$${discount.toStringAsFixed(2)}');
                  },
                  loading:
                      () => const CircularProgressIndicator(strokeWidth: 2.0),
                  error: (error, _) => Text('Error: $error'),
                ),
              ],
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              cartTotalAsync.when(
                data: (total) {
                  double finalTotal = total;
                  if (appliedCouponAsync.hasValue &&
                      appliedCouponAsync.value != null) {
                    final discount =
                        total *
                        (appliedCouponAsync.value!.discountPercentage / 100);
                    finalTotal = total - discount;
                  }
                  return Text(
                    '\$${finalTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
                loading:
                    () => const CircularProgressIndicator(strokeWidth: 2.0),
                error: (error, _) => Text('Error: $error'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateQuantity(int cartItemId, int newQuantity) async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) return;

      // If new quantity is 0, remove the item from cart instead of updating
      if (newQuantity <= 0) {
        _removeFromCart(cartItemId);
        return;
      }

      final cartNotifier = ref.read(
        cartNotifierProvider(currentUser.id).notifier,
      );
      await cartNotifier.updateQuantity(cartItemId, newQuantity);

      // Refresh all relevant providers to immediately update UI
      ref.refresh(cartItemsProvider(currentUser.id));
      ref.refresh(cartTotalProvider(currentUser.id));

      // Also refresh the cart notifier to ensure UI is updated
      await cartNotifier.loadCartItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating quantity: $e')));
      }
    }
  }

  void _removeFromCart(int cartItemId) async {
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error removing item: $e')));
      }
    }
  }

  void _clearCart(int userId) async {
    try {
      final cartNotifier = ref.read(cartNotifierProvider(userId).notifier);
      await cartNotifier.clearCart();
      _clearAppliedCoupon();

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart cleared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing cart: $e')));
      }
    }
  }

  void _applyCoupon(String code) async {
    if (code.isEmpty) return;

    try {
      final couponNotifier = ref.read(couponNotifierProvider.notifier);
      await couponNotifier.validateAndApplyCoupon(code);
      setState(() {
        _appliedCouponCode = code;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error applying coupon: $e')));
      }
    }
  }

  void _clearAppliedCoupon() {
    final couponNotifier = ref.read(couponNotifierProvider.notifier);
    couponNotifier.clearCoupon();
    setState(() {
      _appliedCouponCode = null;
      _couponController.clear();
    });
  }
}
