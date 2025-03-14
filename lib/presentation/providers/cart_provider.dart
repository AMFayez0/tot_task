import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/cart_item.dart';
import 'package:cart_task/domain/repositories/cart_repository.dart';
import 'package:cart_task/domain/usecases/add_product_to_cart.dart';
import 'package:cart_task/domain/usecases/remove_product_from_cart.dart';

// Provider for the cart repository
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  // This will be overridden in the DISetup widget
  throw UnimplementedError('CartRepository provider not implemented');
});

// Provider for the AddProductToCart use case
final addProductToCartProvider = Provider<AddProductToCart>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return AddProductToCart(repository);
});

// Provider for the RemoveProductFromCart use case
final removeProductFromCartProvider = Provider<RemoveProductFromCart>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return RemoveProductFromCart(repository);
});

// Provider for cart items by user ID
final cartItemsProvider = FutureProvider.family<List<CartItem>, int>(
  (ref, userId) async {
    final repository = ref.watch(cartRepositoryProvider);
    return repository.getCartItems(userId);
  },
);

// Provider for cart total
final cartTotalProvider = FutureProvider.family<double, int>(
  (ref, userId) async {
    final repository = ref.watch(cartRepositoryProvider);
    return repository.getCartTotal(userId);
  },
);

// Notifier for cart operations
class CartNotifier extends StateNotifier<AsyncValue<List<CartItem>>> {
  final CartRepository _repository;
  final int _userId;

  CartNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    // Load cart items when initialized
    loadCartItems();
  }

  Future<void> loadCartItems() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getCartItems(_userId);
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    try {
      final cartItem = CartItem(
        id: 0, // Will be set by database
        userId: _userId,
        productId: productId,
        quantity: quantity,
        createdAt: DateTime.now(),
      );
      await _repository.addToCart(cartItem);
      loadCartItems(); // Refresh cart items
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    try {
      await _repository.updateCartItemQuantity(cartItemId, quantity);
      loadCartItems(); // Refresh cart items
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      await _repository.removeFromCart(cartItemId);
      loadCartItems(); // Refresh cart items
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart(_userId);
      loadCartItems(); // Refresh cart items
    } catch (e) {
      rethrow;
    }
  }
}

// Provider for the cart notifier
final cartNotifierProvider = StateNotifierProvider.family<CartNotifier, AsyncValue<List<CartItem>>, int>(
  (ref, userId) => CartNotifier(ref.watch(cartRepositoryProvider), userId),
);