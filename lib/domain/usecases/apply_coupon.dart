import 'package:cart_task/domain/repositories/coupon_repository.dart';

class ApplyCoupon {
  final CouponRepository _couponRepository;

  ApplyCoupon(this._couponRepository);

  Future<double> execute(String code, double cartTotal) async {
    // Validate coupon
    final isValid = await _couponRepository.isValidCoupon(code);
    if (!isValid) {
      throw Exception('Invalid or expired coupon');
    }

    // Apply coupon to cart total
    return await _couponRepository.applyCouponToCart(code, cartTotal);
  }
}
