import 'package:flutter/material.dart';
import 'package:luxe/core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepOnyx)),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatCard(title: 'Sales', value: 'KES 0', icon: Icons.payments_outlined),
                const SizedBox(width: 16),
                _StatCard(title: 'Orders', value: '0', icon: Icons.shopping_bag_outlined),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(title: 'Products', value: '0', icon: Icons.inventory_2_outlined),
                const SizedBox(width: 16),
                _StatCard(title: 'Rating', value: 'N/A', icon: Icons.star_outline_rounded),
              ],
            ),
          ],
        ),
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
