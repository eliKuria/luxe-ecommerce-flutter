import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/features/retailer_inventory/presentation/providers/inventory_providers.dart';
import 'package:luxe/features/profile/presentation/providers/profile_providers.dart';
import 'package:luxe/features/profile/domain/user_role.dart';
import 'package:intl/intl.dart';

class RetailerInventoryScreen extends ConsumerWidget {
  const RetailerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(myProductsProvider);

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(profileControllerProvider.notifier).updateRole(UserRole.customer);
            },
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: const Text('Shop', style: TextStyle(fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primaryColor),
            onPressed: () => context.push('/add-product'),
          ),
        ],
      ),
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.secondaryText.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No products listed yet.', 
                    style: TextStyle(fontSize: 16, color: AppTheme.secondaryText)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add-product'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add My First Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return _InventoryItemCard(product: product);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final dynamic product;

  const _InventoryItemCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              child: product.imageUrl != null 
                ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined))
                : const Icon(Icons.image_outlined, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.deepOnyx)),
                const SizedBox(height: 4),
                Text(product.category ?? 'Uncategorized', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(symbol: 'KES ').format(product.price),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 15),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
        ],
      ),
    );
  }
}
