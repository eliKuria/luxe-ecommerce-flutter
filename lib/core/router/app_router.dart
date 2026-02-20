import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe/core/presentation/main_nav_scaffold.dart';
import 'package:luxe/features/catalog/presentation/product_list_screen.dart';
import 'package:luxe/features/catalog/presentation/product_detail_screen.dart';
import 'package:luxe/features/cart/presentation/cart_screen.dart';
import 'package:luxe/features/search/presentation/search_screen.dart';
import 'package:luxe/features/profile/presentation/profile_screen.dart';
import 'package:luxe/features/splash/presentation/splash_screen.dart';
import 'package:luxe/features/auth/presentation/screens/login_screen.dart';
import 'package:luxe/features/auth/presentation/screens/signup_screen.dart';
import 'package:luxe/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:luxe/features/checkout/presentation/checkout_screen.dart';


final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _catalogNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'catalog');
final GlobalKey<NavigatorState> _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final GlobalKey<NavigatorState> _cartNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cart');
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash Route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      // Login Route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Signup Route
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      // Forgot Password Route
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Checkout Route (full-screen, outside shell)
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      // Main Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Catalog (was Shop)
          StatefulShellBranch(
            navigatorKey: _catalogNavigatorKey,
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) => const ProductListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return ProductDetailScreen(productId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Branch 2: Search
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),

          // Branch 3: Cart
          StatefulShellBranch(
            navigatorKey: _cartNavigatorKey,
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
