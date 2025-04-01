import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CouponSection extends StatelessWidget {
  final AsyncValue<dynamic> appliedCouponAsync;
  final TextEditingController couponController;
  final String? appliedCouponCode;
  final Function(String) onApplyCoupon;
  final VoidCallback onClearCoupon;

  const CouponSection({
    super.key,
    required this.appliedCouponAsync,
    required this.couponController,
    required this.appliedCouponCode,
    required this.onApplyCoupon,
    required this.onClearCoupon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: couponController,
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
                appliedCouponCode != null
                    ? onClearCoupon
                    : () => onApplyCoupon(couponController.text),
            child: Text(appliedCouponCode != null ? 'CLEAR' : 'APPLY'),
          ),
        ],
      ),
    );
  }
}
