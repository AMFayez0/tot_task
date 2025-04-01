import 'package:flutter/material.dart';
import 'package:cart_task/presentation/pages/home_page.dart';
import 'package:cart_task/presentation/pages/cart_page.dart';
import 'package:cart_task/di_setup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DISetup(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping Cart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/cart': (context) => const CartPage(),
      },
    );
  }
}
