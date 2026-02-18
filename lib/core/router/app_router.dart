import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe/main_nav_scaffold.dart';
import 'package:luxe/features/catalog/presentation/product_list_screen.dart';
import 'package:luxe/features/cart/presentation/cart_screen.dart';
import 'package:luxe/core/presentation/placeholder_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shopNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shop');
final GlobalKey<NavigatorState> _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final GlobalKey<NavigatorState> _cartNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cart');
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/shop',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Shop
          StatefulShellBranch(
            navigatorKey: _shopNavigatorKey,
            routes: [
              GoRoute(
                path: '/shop',
                builder: (context, state) => const ProductListScreen(),
              ),
            ],
          ),
          
          // Branch 2: Search
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const PlaceholderScreen('Search'),
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
                builder: (context, state) => const PlaceholderScreen('Profile'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
