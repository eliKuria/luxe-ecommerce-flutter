import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/core/utils/currency_formatter.dart';
import 'package:luxe/features/profile/domain/order.dart';
import 'package:luxe/features/profile/presentation/providers/profile_providers.dart';

class OrderProgressScreen extends ConsumerWidget {
  final int orderId;

  const OrderProgressScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Could not load order details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                child: const Text('Retry', style: TextStyle(color: AppTheme.primaryColor)),
              ),
            ],
          ),
        ),
        data: (order) => _OrderProgressBody(order: order),
      ),
    );
  }
}

class _OrderProgressBody extends StatelessWidget {
  final Order order;

  const _OrderProgressBody({required this.order});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Order Summary Card ──
          _OrderSummaryCard(order: order),

          const SizedBox(height: 24),

          // ── Progress Tracker ──
          const Text(
            'Order Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepOnyx,
            ),
          ),
          const SizedBox(height: 16),
          _OrderStepTracker(status: order.status),

          const SizedBox(height: 24),

          // ── Estimated Delivery ──
          _EstimatedDeliveryCard(order: order),

          const SizedBox(height: 24),

          // ── Help Section ──
          _HelpSection(),
        ],
      ),
    );
  }
}

// ── Order Summary Card ──

class _OrderSummaryCard extends StatelessWidget {
  final Order order;

  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepOnyx,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(order.createdAt),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
              _StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Total',
                style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
              ),
              Text(
                formatKES(order.total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepOnyx,
                ),
              ),
            ],
          ),
          if (order.itemCount != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                ),
                Text(
                  '${order.itemCount} item${order.itemCount! > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepOnyx,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Step Tracker ──

class _OrderStepTracker extends StatelessWidget {
  final String status;

  const _OrderStepTracker({required this.status});

  int get _currentStep {
    switch (status.toLowerCase()) {
      case 'placed':
        return 0;
      case 'processing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  static const _steps = [
    _StepData(
      icon: Icons.check_circle_outline_rounded,
      title: 'Order Placed',
      subtitle: 'Your order has been confirmed',
    ),
    _StepData(
      icon: Icons.inventory_2_outlined,
      title: 'Processing',
      subtitle: 'We\'re preparing your items',
    ),
    _StepData(
      icon: Icons.local_shipping_outlined,
      title: 'Shipped',
      subtitle: 'Your order is on the way',
    ),
    _StepData(
      icon: Icons.home_outlined,
      title: 'Delivered',
      subtitle: 'Enjoy your purchase!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _currentStep;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(_steps.length, (i) {
          final isCompleted = i <= current;
          final isActive = i == current;
          final isLast = i == _steps.length - 1;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step icon + connector line
                  Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppTheme.primaryColor
                              : const Color(0xFFF3F4F6),
                        ),
                        child: Icon(
                          _steps[i].icon,
                          color: isCompleted ? Colors.white : AppTheme.secondaryText,
                          size: 22,
                        ),
                      ),
                      if (!isLast)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 2,
                          height: 36,
                          color: i < current
                              ? AppTheme.primaryColor
                              : AppTheme.dividerColor,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Step text
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _steps[i].title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isCompleted
                                  ? AppTheme.deepOnyx
                                  : AppTheme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _steps[i].subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: isCompleted
                                  ? AppTheme.secondaryText
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Checkmark for completed
                  if (isCompleted && !isActive)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                ],
              ),
              if (!isLast) const SizedBox(height: 0),
            ],
          );
        }),
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String title;
  final String subtitle;
  const _StepData({required this.icon, required this.title, required this.subtitle});
}

// ── Estimated Delivery Card ──

class _EstimatedDeliveryCard extends StatelessWidget {
  final Order order;

  const _EstimatedDeliveryCard({required this.order});

  String get _estimatedDate {
    final base = order.createdAt.add(const Duration(days: 5));
    return DateFormat('EEEE, MMM d, y').format(base);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated Delivery',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _estimatedDate,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepOnyx,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Help Section ──

class _HelpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need Help?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepOnyx,
            ),
          ),
          const SizedBox(height: 12),
          _HelpItem(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Contact Support',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _HelpItem(
            icon: Icons.undo_rounded,
            title: 'Return or Exchange',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HelpItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.secondaryText),
        ],
      ),
    );
  }
}

// ── Status Chip ──

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
