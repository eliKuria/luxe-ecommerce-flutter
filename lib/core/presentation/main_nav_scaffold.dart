import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/features/cart/presentation/providers/cart_providers.dart';

class MainNavScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavScaffold({
    required this.navigationShell,
    super.key,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, ConsumerWidgetRef ref) {
    // Watch cart for badge count
    final cartAsync = ref.watch(cartProvider);
    final cartCount = cartAsync.valueOrNull?.fold<int>(0, (int sum, item) => sum + item.quantity) ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.pureWhite,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryText,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Shop',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Need to use ConsumerWidgetRef instead of WidgetRef for the ref parameter type
typedef ConsumerWidgetRef = WidgetRef;
