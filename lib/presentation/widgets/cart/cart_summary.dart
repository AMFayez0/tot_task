import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartSummary extends StatelessWidget {
  final AsyncValue<double> cartTotalAsync;
  final AsyncValue<dynamic> appliedCouponAsync;

  const CartSummary({
    super.key,
    required this.cartTotalAsync,
    required this.appliedCouponAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              cartTotalAsync.when(
                data: (total) => Text('\$${total.toStringAsFixed(2)}'),
                loading:
                    () => const CircularProgressIndicator(strokeWidth: 2.0),
                error: (error, _) => Text('Error: $error'),
              ),
            ],
          ),
          if (appliedCouponAsync.hasValue &&
              appliedCouponAsync.value != null) ...[
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount (${appliedCouponAsync.value!.discountPercentage}%):',
                ),
                cartTotalAsync.when(
                  data: (total) {
                    final discount =
                        total *
                        (appliedCouponAsync.value!.discountPercentage / 100);
                    return Text('-\$${discount.toStringAsFixed(2)}');
                  },
                  loading:
                      () => const CircularProgressIndicator(strokeWidth: 2.0),
                  error: (error, _) => Text('Error: $error'),
                ),
              ],
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              cartTotalAsync.when(
                data: (total) {
                  double finalTotal = total;
                  if (appliedCouponAsync.hasValue &&
                      appliedCouponAsync.value != null) {
                    final discount =
                        total *
                        (appliedCouponAsync.value!.discountPercentage / 100);
                    finalTotal = total - discount;
                  }
                  return Text(
                    '\$${finalTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
                loading:
                    () => const CircularProgressIndicator(strokeWidth: 2.0),
                error: (error, _) => Text('Error: $error'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
