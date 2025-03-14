import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/presentation/di/dependency_injection.dart' as di;
import 'package:cart_task/presentation/providers/product_provider.dart';
import 'package:cart_task/presentation/providers/user_provider.dart';
import 'package:cart_task/presentation/providers/cart_provider.dart';
import 'package:cart_task/presentation/providers/coupon_provider.dart';

/// This class is responsible for setting up the dependency injection
/// It overrides the providers in the app to use the implementations from dependency_injection.dart
class DISetup extends StatelessWidget {
  final Widget child;

  const DISetup({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Override the repository providers with the implementations
        productRepositoryProvider.overrideWithProvider(di.productRepositoryProvider),
        userRepositoryProvider.overrideWithProvider(di.userRepositoryProvider),
        cartRepositoryProvider.overrideWithProvider(di.cartRepositoryProvider),
        couponRepositoryProvider.overrideWithProvider(di.couponRepositoryProvider),
      ],
      child: child,
    );
  }
}