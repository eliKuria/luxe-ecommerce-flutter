import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/core/utils/currency_formatter.dart';
import 'package:luxe/features/cart/domain/cart_item.dart';
import 'package:luxe/features/cart/presentation/providers/cart_providers.dart';
import 'package:luxe/features/checkout/presentation/providers/checkout_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Convert 10-digit 07xx to 2547xx format for M-Pesa API
  String _toMpesaFormat(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0') && digits.length == 10) {
      return '254${digits.substring(1)}';
    }
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final paymentAsync = ref.watch(checkoutControllerProvider);
    final paymentMethod = ref.watch(paymentMethodProvider);

    ref.listen<AsyncValue<PaymentStatus>>(checkoutControllerProvider, (prev, next) {
      final status = next.valueOrNull;
      if (status == null) return;
      if (status.state == PaymentState.success) {
        ref.invalidate(cartProvider);
      }
    });

    final paymentStatus = paymentAsync.valueOrNull ?? const PaymentStatus();
    final isProcessing = paymentStatus.state != PaymentState.idle &&
        paymentStatus.state != PaymentState.failed &&
        paymentStatus.state != PaymentState.success;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isProcessing
              ? null
              : () {
                  ref.read(checkoutControllerProvider.notifier).reset();
                  context.pop();
                },
        ),
      ),
      body: paymentStatus.state == PaymentState.success
          ? _buildSuccessView(paymentStatus)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(cartAsync),
                  const SizedBox(height: 24),
                  _buildPaymentMethodSelector(paymentMethod, isProcessing),
                  const SizedBox(height: 24),
                  _buildPhoneInput(isProcessing, paymentMethod),
                  const SizedBox(height: 16),
                  if (paymentStatus.state != PaymentState.idle)
                    _buildStatusBanner(paymentStatus, isProcessing),
                  if (paymentStatus.state != PaymentState.idle)
                    const SizedBox(height: 16),
                  _buildPayButton(isProcessing, paymentStatus, paymentMethod, cartAsync),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // ── Order Summary ───────────────────────────────────────────────

  Widget _buildOrderSummary(AsyncValue<List<CartItem>> cartAsync) {
    return cartAsync.when(
      data: (cartItems) {
        final subtotal = cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
        const shipping = 1300.0;
        final total = subtotal + shipping;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
              ),
              const SizedBox(height: 16),
              ...cartItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.displayImage,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image_outlined, size: 20, color: AppTheme.secondaryText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '×${item.quantity}',
                            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatKES(item.totalPrice),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              )),
              const Divider(color: AppTheme.dividerColor),
              const SizedBox(height: 8),
              _summaryRow('Subtotal', formatKES(subtotal)),
              const SizedBox(height: 6),
              _summaryRow('Shipping', formatKES(shipping)),
              const Divider(color: AppTheme.dividerColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    formatKES(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 48, color: AppTheme.secondaryText),
            SizedBox(height: 12),
            Text(
              'Unable to load your cart',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Please check your connection and try again.',
              style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  // ── Payment Method Selector ─────────────────────────────────────

  Widget _buildPaymentMethodSelector(PaymentMethod selected, bool isProcessing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _paymentOption(
                icon: Icons.phone_android,
                label: 'M-Pesa',
                subtitle: 'Pay now',
                isSelected: selected == PaymentMethod.mpesa,
                enabled: !isProcessing,
                onTap: () =>
                    ref.read(paymentMethodProvider.notifier).state = PaymentMethod.mpesa,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _paymentOption(
                icon: Icons.local_shipping_outlined,
                label: 'Cash',
                subtitle: 'Pay on delivery',
                isSelected: selected == PaymentMethod.cashOnDelivery,
                enabled: !isProcessing,
                onTap: () =>
                    ref.read(paymentMethodProvider.notifier).state = PaymentMethod.cashOnDelivery,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _paymentOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.06) : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryText),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryColor : AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Phone Input ─────────────────────────────────────────────────

  Widget _buildPhoneInput(bool isProcessing, PaymentMethod paymentMethod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          paymentMethod == PaymentMethod.mpesa ? 'M-Pesa Phone Number' : 'Delivery Contact',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
        ),
        const SizedBox(height: 4),
        Text(
          paymentMethod == PaymentMethod.mpesa
              ? 'Enter the Safaricom number to receive the M-Pesa prompt'
              : 'We\'ll call this number for delivery',
          style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
        ),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _phoneController,
            enabled: !isProcessing,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
              _KenyanPhoneFormatter(),
            ],
            decoration: InputDecoration(
              hintText: '0712 345 678',
              hintStyle: const TextStyle(color: AppTheme.secondaryText),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇰🇪', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text('+254', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.errorColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your phone number';
              final digits = value.replaceAll(RegExp(r'\D'), '');
              if (digits.length != 10) return 'Enter all 10 digits (e.g. 0712 345 678)';
              if (!digits.startsWith('07') && !digits.startsWith('01')) {
                return 'Enter a valid Safaricom number starting with 07 or 01';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // ── Status Banner ────────────────────────────────────────────────

  Widget _buildStatusBanner(PaymentStatus status, bool isProcessing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _statusBgColor(status.state),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _statusBorderColor(status.state)),
      ),
      child: Row(
        children: [
          if (isProcessing)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
            )
          else
            Icon(
              status.state == PaymentState.success ? Icons.check_circle : Icons.info_outline,
              color: status.state == PaymentState.success
                  ? const Color(0xFF4CAF50)
                  : AppTheme.errorColor,
              size: 18,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status.message ?? '',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pay Button ──────────────────────────────────────────────────

  Widget _buildPayButton(
    bool isProcessing,
    PaymentStatus status,
    PaymentMethod method,
    AsyncValue<List<CartItem>> cartAsync,
  ) {
    final buttonLabel = status.state == PaymentState.failed
        ? 'Try Again'
        : method == PaymentMethod.mpesa
            ? 'Pay with M-Pesa'
            : 'Place Order';

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isProcessing || status.state == PaymentState.success
            ? null
            : () => _handlePay(cartAsync, method),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(buttonLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── Success View ────────────────────────────────────────────────

  Widget _buildSuccessView(PaymentStatus status) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF4CAF50), size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Placed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              status.message ?? 'Your order is being processed.',
              style: const TextStyle(color: AppTheme.secondaryText, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            if (status.orderId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Order #${status.orderId}',
                style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(checkoutControllerProvider.notifier).reset();
                  ref.invalidate(cartProvider);
                  context.go('/catalog');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Continue Shopping', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Handlers ────────────────────────────────────────────────────

  void _handlePay(AsyncValue<List<CartItem>> cartAsync, PaymentMethod method) {
    if (!_formKey.currentState!.validate()) return;

    final cartItems = cartAsync.valueOrNull;
    if (cartItems == null || cartItems.isEmpty) return;

    final subtotal = cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    const shipping = 1300.0;
    final total = subtotal + shipping;

    final rawDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');

    if (method == PaymentMethod.mpesa) {
      ref.read(checkoutControllerProvider.notifier).startMpesaPayment(
        phone: _toMpesaFormat(rawDigits),
        amount: total,
      );
    } else {
      ref.read(checkoutControllerProvider.notifier).placeOrderCashOnDelivery(
        phone: _toMpesaFormat(rawDigits),
        amount: total,
      );
    }
  }

  Color _statusBgColor(PaymentState state) {
    switch (state) {
      case PaymentState.success:
        return const Color(0xFFE8F5E9);
      case PaymentState.failed:
        return const Color(0xFFFBE9E7);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  Color _statusBorderColor(PaymentState state) {
    switch (state) {
      case PaymentState.success:
        return const Color(0xFFC8E6C9);
      case PaymentState.failed:
        return const Color(0xFFFFCCBC);
      default:
        return const Color(0xFFFFE0B2);
    }
  }
}

/// Formatter that groups digits as: 0712 345 678
class _KenyanPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
