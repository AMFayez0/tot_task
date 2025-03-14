class CartItem {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final DateTime createdAt;

  const CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
  });

  // Convert CartItem to Map for database operations
  Map<String, dynamic> toMap() {
    // Create a map without the ID field initially
    final map = {
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
    };
    
    // Only include the ID if it's not zero (not a new item)
    if (id != 0) {
      map['id'] = id;
    }
    
    return map;
  }

  // Create CartItem from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as int,
      userId: map['userId'] as int,
      productId: map['productId'] as int,
      quantity: map['quantity'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Copy with method for immutability
  CartItem copyWith({
    int? id,
    int? userId,
    int? productId,
    int? quantity,
    DateTime? createdAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Calculate total price (will be used with Product entity)
  double calculateTotal(double productPrice) {
    return productPrice * quantity;
  }
}
