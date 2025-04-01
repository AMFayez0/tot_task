import 'package:cart_task/presentation/providers/cart_item_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/presentation/providers/cart_provider.dart';
import 'package:cart_task/presentation/providers/coupon_provider.dart';
import 'package:cart_task/presentation/providers/user_provider.dart';
import 'package:cart_task/presentation/services/cart_service.dart';
import 'package:cart_task/presentation/widgets/cart/cart_item_tile.dart';
import 'package:cart_task/presentation/widgets/cart/coupon_section.dart';
import 'package:cart_task/presentation/widgets/cart/cart_summary.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCouponCode;
  late CartService _cartService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cartService = CartService(ref, context);
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cartService = CartService(ref, context);

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
      onWillPop: () => _cartService.handleBackButton(currentUser.id),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shopping Cart'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _cartService.clearCart(currentUser.id),
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
                      return CartItemTile(
                        cartItem: cartItem,
                        onUpdateQuantity:
                            (newQuantity) => _cartService.updateQuantity(
                              cartItem.id,
                              newQuantity,
                              currentUser.id,
                            ),
                        onRemoveItem:
                            (cartItemId) =>
                                _cartService.removeFromCart(cartItemId),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) =>
                        Center(child: Text('Error loading cart: $error')),
              ),
            ),
            CouponSection(
              appliedCouponAsync: appliedCouponAsync,
              couponController: _couponController,
              appliedCouponCode: _appliedCouponCode,
              onApplyCoupon: (code) async {
                await _cartService.applyCoupon(code);
                setState(() {
                  _appliedCouponCode = code;
                });
              },
              onClearCoupon: () {
                _cartService.clearAppliedCoupon();
                setState(() {
                  _appliedCouponCode = null;
                  _couponController.clear();
                });
              },
            ),
            CartSummary(
              cartTotalAsync: cartTotalAsync,
              appliedCouponAsync: appliedCouponAsync,
            ),
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
}
