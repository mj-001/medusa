import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/checkout/mpesa_payment_screen.dart';
import 'features/checkout/order_success_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/orders/order_detail_screen.dart';
import 'features/orders/orders_screen.dart';
import 'features/products/product_detail_screen.dart';
import 'features/products/product_list_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/splash/splash_screen.dart';
import 'shared/scaffold_with_nav.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (ctx, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (ctx, state) => const RegisterScreen(),
      ),
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/cart',
        parentNavigatorKey: _rootKey,
        builder: (ctx, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootKey,
        builder: (ctx, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/checkout/payment',
        parentNavigatorKey: _rootKey,
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return MpesaPaymentScreen(cartId: extra['cartId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: '/checkout/success',
        parentNavigatorKey: _rootKey,
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OrderSuccessScreen(
              orderId: extra['orderId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: '/orders/:id',
        parentNavigatorKey: _rootKey,
        builder: (ctx, state) =>
            OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/products/:id',
        parentNavigatorKey: _rootKey,
        builder: (ctx, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      // Shell with bottom nav
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (ctx, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (ctx, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (ctx, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (ctx, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (ctx, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class FreshKeApp extends ConsumerWidget {
  const FreshKeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'FreshKe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
