import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/features/cart/presentation/providers/cart_providers.dart';
import 'package:luxe/features/profile/domain/user_role.dart';
import 'package:luxe/features/profile/presentation/providers/profile_providers.dart';

class MainNavScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavScaffold({
    required this.navigationShell,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    
    // Watch cart for badge count
    final cartAsync = ref.watch(cartProvider);
    final cartCount = cartAsync.valueOrNull?.fold<int>(0, (int sum, item) => sum + item.quantity) ?? 0;

    // Define items based on role
    final List<BottomNavigationBarItem> items;
    final List<int> branchIndices;

    if (role == UserRole.retailer) {
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded),
          activeIcon: Icon(Icons.bar_chart_rounded),
          label: 'Insights',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2_rounded),
          label: 'Inventory',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Orders',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ];
      branchIndices = [4, 5, 6, 3];
    } else {
      items = [
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
      ];
      branchIndices = [0, 1, 2, 3];
    }

    // Determine current index in the context of the bottom navigation bar
    final currentIndex = branchIndices.indexOf(navigationShell.currentIndex);
    // Fallback if not found (shouldn't happen with correct mapping)
    final safeIndex = currentIndex != -1 ? currentIndex : 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (index) {
          navigationShell.goBranch(
            branchIndices[index],
            initialLocation: branchIndices[index] == navigationShell.currentIndex,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.pureWhite,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryText,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: items,
      ),
    );
  }
}

// Need to use ConsumerWidgetRef instead of WidgetRef for the ref parameter type
typedef ConsumerWidgetRef = WidgetRef;
