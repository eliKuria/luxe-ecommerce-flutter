import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/core/utils/currency_formatter.dart';
import 'package:luxe/features/retailer_inventory/presentation/providers/inventory_providers.dart';
import 'package:luxe/features/profile/presentation/providers/profile_providers.dart';
import 'package:luxe/features/profile/domain/user_role.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        title: const Text('Insights'),
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
        error: (err, _) => Center(child: Text('Error loading insights: $err')),
        data: (items) {
          final totalRevenue = items.fold<double>(0, (sum, item) {
            final price = (item['unit_price'] as num).toDouble();
            final qty = item['quantity'] as int;
            return sum + (price * qty);
          });
          
          final orderCount = items.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Performance Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepOnyx)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _StatCard(title: 'Revenue', value: formatKES(totalRevenue), icon: Icons.payments_outlined),
                    const SizedBox(width: 16),
                    _StatCard(title: 'Sales', value: '$orderCount', icon: Icons.shopping_bag_outlined),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Recent Growth', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.deepOnyx)),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: const Center(
                    child: Text('Chart tracking will appear as you grow.', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepOnyx)),
          ],
        ),
      ),
    );
  }
}
