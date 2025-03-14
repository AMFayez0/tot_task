import 'package:cart_task/domain/entities/coupon.dart';

abstract class CouponRepository {
  // Get coupon by ID
  Future<Coupon?> getCoupon(int id);

  // Get coupon by code
  Future<Coupon?> getCouponByCode(String code);

  // Create a new coupon
  Future<Coupon> createCoupon(Coupon coupon);

  // Update existing coupon
  Future<Coupon> updateCoupon(Coupon coupon);

  // Delete coupon
  Future<void> deleteCoupon(int id);

  // Get all active coupons
  Future<List<Coupon>> getActiveCoupons();

  // Validate coupon
  Future<bool> isValidCoupon(String code);

  // Apply coupon to cart
  Future<double> applyCouponToCart(String code, double cartTotal);
}
