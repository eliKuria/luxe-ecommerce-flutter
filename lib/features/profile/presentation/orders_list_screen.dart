import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/core/utils/currency_formatter.dart';
import 'package:luxe/features/profile/domain/order.dart';
import 'package:luxe/features/profile/presentation/providers/profile_providers.dart';

/// Full-screen view showing all of the user's orders.
class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
              const SizedBox(height: 16),
              const Text('Could not load orders',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => ref.invalidate(ordersProvider),
                child: const Text('Retry',
                    style: TextStyle(color: AppTheme.primaryColor)),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 72, color: AppTheme.dividerColor),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepOnyx),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your order history will appear here',
                    style:
                        TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _AllOrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _AllOrderCard extends StatelessWidget {
  final Order order;

  const _AllOrderCard({required this.order});

  Color get _statusColor {
    switch (order.status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF22C55E);
      case 'shipped':
        return AppTheme.primaryColor;
      case 'processing':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepOnyx,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('MMM d, y').format(order.createdAt),
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.secondaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatKES(order.total),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepOnyx,
                    ),
                  ),
                ],
              ),
            ),
            // Status chip
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppTheme.secondaryText),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
