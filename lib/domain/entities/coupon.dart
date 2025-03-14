class Coupon {
  final int id;
  final String code;
  final double discountPercentage;
  final DateTime expiryDate;
  final bool isActive;

  const Coupon({
    required this.id,
    required this.code,
    required this.discountPercentage,
    required this.expiryDate,
    this.isActive = true,
  });

  // Convert Coupon to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'discountPercentage': discountPercentage,
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  // Create Coupon from Map
  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] as int,
      code: map['code'] as String,
      discountPercentage: map['discountPercentage'] as double,
      expiryDate: DateTime.parse(map['expiryDate'] as String),
      isActive: map['isActive'] == 1,
    );
  }

  // Copy with method for immutability
  Coupon copyWith({
    int? id,
    String? code,
    double? discountPercentage,
    DateTime? expiryDate,
    bool? isActive,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }

  // Check if coupon is valid
  bool isValid() {
    return isActive && DateTime.now().isBefore(expiryDate);
  }

  // Calculate discounted amount
  double calculateDiscount(double originalPrice) {
    if (!isValid()) return 0;
    return originalPrice * (discountPercentage / 100);
  }
}
