import 'package:cart_task/data/data_sources/local_db_service.dart';
import 'package:cart_task/domain/entities/coupon.dart';
import 'package:cart_task/domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final LocalDBService _dbService;

  CouponRepositoryImpl(this._dbService);

  @override
  Future<Coupon> createCoupon(Coupon coupon) async {
    final id = await _dbService.insert(
      LocalDBService.couponTable,
      coupon.toMap(),
    );
    return coupon.copyWith(id: id);
  }

  @override
  Future<void> deleteCoupon(int id) async {
    await _dbService.delete(
      LocalDBService.couponTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Coupon>> getActiveCoupons() async {
    final maps = await _dbService.query(
      LocalDBService.couponTable,
      where: 'isActive = ? AND expiryDate > ?',
      whereArgs: [1, DateTime.now().toIso8601String()],
    );
    return maps.map((map) => Coupon.fromMap(map)).toList();
  }

  @override
  Future<Coupon?> getCoupon(int id) async {
    final maps = await _dbService.query(
      LocalDBService.couponTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Coupon.fromMap(maps.first);
  }

  @override
  Future<Coupon?> getCouponByCode(String code) async {
    final maps = await _dbService.query(
      LocalDBService.couponTable,
      where: 'code = ?',
      whereArgs: [code],
    );

    if (maps.isEmpty) return null;
    return Coupon.fromMap(maps.first);
  }

  @override
  Future<bool> isValidCoupon(String code) async {
    final coupon = await getCouponByCode(code);
    if (coupon == null) return false;
    return coupon.isValid();
  }

  @override
  Future<double> applyCouponToCart(String code, double cartTotal) async {
    final coupon = await getCouponByCode(code);
    if (coupon == null || !coupon.isValid()) return cartTotal;

    final discount = coupon.calculateDiscount(cartTotal);
    return cartTotal - discount;
  }

  @override
  Future<Coupon> updateCoupon(Coupon coupon) async {
    await _dbService.update(
      LocalDBService.couponTable,
      coupon.toMap(),
      where: 'id = ?',
      whereArgs: [coupon.id],
    );
    return coupon;
  }
}
