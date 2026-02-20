import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/features/profile/domain/order.dart';
import 'package:luxe/features/profile/domain/user_profile.dart';
import 'package:luxe/features/profile/presentation/constants/profile_strings.dart';
import 'package:luxe/features/profile/presentation/providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        title: const Text(
          ProfileStrings.profileTitle,
          style: TextStyle(
            color: AppTheme.deepOnyx,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.deepOnyx),
            onPressed: () {},
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
              const SizedBox(height: 16),
              const Text('Unable to load your profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Text('Please check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.secondaryText, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(profileControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (user) => _ProfileBody(user: user, ordersState: ordersState),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final UserProfile user;
  final AsyncValue<List<Order>> ordersState;

  const _ProfileBody({required this.user, required this.ordersState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header Section ──
          _buildHeader(context),

          const SizedBox(height: 24),

          // ── Action Buttons ──
          _buildActionButtons(context),

          const SizedBox(height: 32),

          // ── Order History ──
          _buildOrderHistorySection(context),

          const SizedBox(height: 32),

          // ── Sign Out ──
          _buildSignOutButton(context, ref),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Avatar with edit badge
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _buildAvatarImage(),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            user.fullName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepOnyx,
            ),
          ),

          const SizedBox(height: 4),

          // Member since
          if (user.createdAt != null)
            Text(
              '${ProfileStrings.memberSince} ${user.createdAt!.year}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return Image.network(
        user.avatarUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
      );
    }
    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    final initial = (user.email.isNotEmpty) ? user.email[0].toUpperCase() : '?';
    return Container(
      width: 120,
      height: 120,
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Edit Profile — Filled
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  ProfileStrings.editProfile,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // My Wallet — Outlined
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.secondaryAction,
                  side: const BorderSide(color: AppTheme.secondaryAction),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  ProfileStrings.myWallet,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistorySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                ProfileStrings.orderHistory,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepOnyx,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  ProfileStrings.viewAll,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Order list
          ordersState.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (err, _) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Could not load orders',
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 14,
                ),
              ),
            ),
            data: (orders) {
              if (orders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      ProfileStrings.noOrders,
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length > 4 ? 4 : orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _OrderCard(order: orders[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.errorColor,
            side: const BorderSide(color: AppTheme.errorColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout, size: 20),
          label: const Text(
            ProfileStrings.signOut,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: () async {
            await ref.read(profileControllerProvider.notifier).signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      ),
    );
  }
}

// ── Order Card Widget ──

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          // Truck icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // Order info
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
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, y').format(order.createdAt),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          _StatusBadge(status: order.status),

          const SizedBox(width: 8),

          const Icon(
            Icons.chevron_right,
            color: AppTheme.secondaryText,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ── Status Badge ──

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
