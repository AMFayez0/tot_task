import 'package:cart_task/data/data_sources/local_db_service.dart';
import 'package:cart_task/domain/entities/cart_item.dart';
import 'package:cart_task/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final LocalDBService _dbService;

  CartRepositoryImpl(this._dbService);

  @override
  Future<CartItem> addToCart(CartItem item) async {
    final id = await _dbService.insert(
      LocalDBService.cartItemTable,
      item.toMap(),
    );
    return item.copyWith(id: id);
  }

  @override
  Future<void> clearCart(int userId) async {
    await _dbService.delete(
      LocalDBService.cartItemTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  @override
  Future<CartItem?> getCartItem(int cartItemId) async {
    final maps = await _dbService.query(
      LocalDBService.cartItemTable,
      where: 'id = ?',
      whereArgs: [cartItemId],
    );

    if (maps.isEmpty) return null;
    return CartItem.fromMap(maps.first);
  }

  @override
  Future<List<CartItem>> getCartItems(int userId) async {
    final maps = await _dbService.query(
      LocalDBService.cartItemTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => CartItem.fromMap(map)).toList();
  }

  @override
  Future<double> getCartTotal(int userId) async {
    final cartItems = await getCartItems(userId);
    double total = 0;

    for (var item in cartItems) {
      final productMaps = await _dbService.query(
        LocalDBService.productTable,
        where: 'id = ?',
        whereArgs: [item.productId],
      );

      if (productMaps.isNotEmpty) {
        final price = productMaps.first['price'] as double;
        total += item.calculateTotal(price);
      }
    }

    return total;
  }

  @override
  Future<bool> isProductInCart(int userId, int productId) async {
    final maps = await _dbService.query(
      LocalDBService.cartItemTable,
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, productId],
    );
    return maps.isNotEmpty;
  }

  @override
  Future<void> removeFromCart(int cartItemId) async {
    await _dbService.delete(
      LocalDBService.cartItemTable,
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  @override
  Future<CartItem> updateCartItemQuantity(int cartItemId, int quantity) async {
    final cartItem = await getCartItem(cartItemId);
    if (cartItem == null) {
      throw Exception('Cart item not found');
    }

    final updatedItem = cartItem.copyWith(quantity: quantity);
    await _dbService.update(
      LocalDBService.cartItemTable,
      updatedItem.toMap(),
      where: 'id = ?',
      whereArgs: [cartItemId],
    );

    return updatedItem;
  }
}
