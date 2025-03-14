import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/coupon.dart';
import 'package:cart_task/domain/repositories/coupon_repository.dart';

// Provider for the coupon repository
final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  // This will be overridden in the DISetup widget
  throw UnimplementedError('CouponRepository provider not implemented');
});

// Provider for all active coupons
final activeCouponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final repository = ref.watch(couponRepositoryProvider);
  return repository.getActiveCoupons();
});

// Provider for coupon by code
final couponByCodeProvider = FutureProvider.family<Coupon?, String>(
  (ref, code) async {
    final repository = ref.watch(couponRepositoryProvider);
    return repository.getCouponByCode(code);
  },
);

// Provider for coupon validation
final couponValidationProvider = FutureProvider.family<bool, String>(
  (ref, code) async {
    final repository = ref.watch(couponRepositoryProvider);
    return repository.isValidCoupon(code);
  },
);

// Notifier for coupon operations
class CouponNotifier extends StateNotifier<AsyncValue<Coupon?>> {
  final CouponRepository _repository;

  CouponNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> validateAndApplyCoupon(String code) async {
    state = const AsyncValue.loading();
    try {
      final isValid = await _repository.isValidCoupon(code);
      if (!isValid) {
        state = AsyncValue.error('Invalid coupon code', StackTrace.current);
        return;
      }
      
      final coupon = await _repository.getCouponByCode(code);
      state = AsyncValue.data(coupon);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<double> applyCouponToCart(String code, double cartTotal) async {
    try {
      return await _repository.applyCouponToCart(code, cartTotal);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return cartTotal; // Return original total if coupon application fails
    }
  }

  void clearCoupon() {
    state = const AsyncValue.data(null);
  }
}

// Provider for the coupon notifier
final couponNotifierProvider = StateNotifierProvider<CouponNotifier, AsyncValue<Coupon?>>(
  (ref) => CouponNotifier(ref.watch(couponRepositoryProvider)),
);