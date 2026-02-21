import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/core/utils/currency_formatter.dart';
import 'package:luxe/features/retailer_inventory/presentation/providers/inventory_providers.dart';
import 'package:luxe/features/profile/presentation/providers/profile_providers.dart';
import 'package:luxe/features/profile/domain/user_role.dart';

class RetailerOrdersScreen extends ConsumerWidget {
  const RetailerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        title: const Text('Store Orders'),
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
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (err, _) => Center(child: Text('Error loading orders: $err')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.dividerColor),
                  const SizedBox(height: 16),
                  const Text('No sales yet.', style: TextStyle(color: AppTheme.secondaryText)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _SellerOrderItemCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _SellerOrderItemCard extends StatelessWidget {
  final dynamic item;

  const _SellerOrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final order = item['orders'];
    final product = item['products'];
    final price = (item['unit_price'] as num).toDouble();
    final qty = item['quantity'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ORD-${order['order_number']?.toString().split('-').last ?? '000'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, h:mm a').format(DateTime.parse(item['created_at'])),
                style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  child: product['image_url'] != null
                      ? Image.network(product['image_url'], fit: BoxFit.cover)
                      : const Icon(Icons.image_outlined, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Product',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepOnyx),
                    ),
                    Text(
                      'Quantity: $qty',
                      style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatKES(price * qty),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  Text(
                    '${order['status']}'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order['status'] ?? 'pending'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      default:
        return AppTheme.secondaryText;
    }
  }
}
