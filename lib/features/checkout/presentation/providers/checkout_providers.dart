import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luxe/features/checkout/domain/checkout_repository.dart';
import 'package:luxe/features/checkout/data/checkout_repository_impl.dart';

/// Repository provider
final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepositoryImpl(Supabase.instance.client);
});

/// Selected payment method
enum PaymentMethod { mpesa, cashOnDelivery }

final paymentMethodProvider = StateProvider<PaymentMethod>((ref) => PaymentMethod.mpesa);

/// Payment flow state
enum PaymentState { idle, creatingOrder, awaitingPayment, polling, success, failed }

class PaymentStatus {
  final PaymentState state;
  final String? message;
  final int? orderId;
  final String? checkoutRequestId;

  const PaymentStatus({
    this.state = PaymentState.idle,
    this.message,
    this.orderId,
    this.checkoutRequestId,
  });

  PaymentStatus copyWith({
    PaymentState? state,
    String? message,
    int? orderId,
    String? checkoutRequestId,
  }) {
    return PaymentStatus(
      state: state ?? this.state,
      message: message ?? this.message,
      orderId: orderId ?? this.orderId,
      checkoutRequestId: checkoutRequestId ?? this.checkoutRequestId,
    );
  }
}

/// Checkout controller
final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, PaymentStatus>(() {
  return CheckoutController();
});

class CheckoutController extends AsyncNotifier<PaymentStatus> {
  Timer? _pollTimer;

  @override
  Future<PaymentStatus> build() async {
    ref.onDispose(() => _pollTimer?.cancel());
    return const PaymentStatus();
  }

  /// Start M-Pesa payment flow
  Future<void> startMpesaPayment({
    required String phone,
    required double amount,
  }) async {
    final repo = ref.read(checkoutRepositoryProvider);

    try {
      // Step 1: Create order
      state = const AsyncData(PaymentStatus(
        state: PaymentState.creatingOrder,
        message: 'Creating your order...',
      ));

      final orderId = await repo.createOrder(
        total: amount,
        paymentMethod: 'mpesa',
        phone: phone,
      );

      // Step 2: Initiate STK Push
      state = AsyncData(PaymentStatus(
        state: PaymentState.awaitingPayment,
        message: 'Check your phone for the M-Pesa prompt...',
        orderId: orderId,
      ));

      final checkoutRequestId = await repo.initiatePayment(
        orderId: orderId,
        phone: phone,
        amount: amount,
      );

      // Step 3: Poll for payment confirmation
      state = AsyncData(PaymentStatus(
        state: PaymentState.polling,
        message: 'Waiting for payment confirmation...',
        orderId: orderId,
        checkoutRequestId: checkoutRequestId,
      ));

      _startPolling(orderId);
    } catch (e) {
      state = AsyncData(PaymentStatus(
        state: PaymentState.failed,
        message: _cleanErrorMessage(e.toString()),
      ));
    }
  }

  /// Place order for cash on delivery
  Future<void> placeOrderCashOnDelivery({
    String? phone,
    required double amount,
  }) async {
    final repo = ref.read(checkoutRepositoryProvider);

    try {
      state = const AsyncData(PaymentStatus(
        state: PaymentState.creatingOrder,
        message: 'Placing your order...',
      ));

      final orderId = await repo.createOrder(
        total: amount,
        paymentMethod: 'cash_on_delivery',
        phone: phone,
      );

      await repo.clearCart();

      state = AsyncData(PaymentStatus(
        state: PaymentState.success,
        message: 'Order placed! Pay KES ${amount.toInt()} on delivery.',
        orderId: orderId,
      ));
    } catch (e) {
      state = AsyncData(PaymentStatus(
        state: PaymentState.failed,
        message: _cleanErrorMessage(e.toString()),
      ));
    }
  }

  void _startPolling(int orderId) {
    int attempts = 0;
    const maxAttempts = 30; // 30 × 3s = 90 seconds max

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      attempts++;
      if (attempts > maxAttempts) {
        timer.cancel();
        state = const AsyncData(PaymentStatus(
          state: PaymentState.failed,
          message: 'Payment timed out. Please check your M-Pesa messages and try again.',
        ));
        return;
      }

      try {
        final repo = ref.read(checkoutRepositoryProvider);
        final status = await repo.checkPaymentStatus(orderId);

        if (status == 'completed') {
          timer.cancel();
          await repo.clearCart();
          state = AsyncData(PaymentStatus(
            state: PaymentState.success,
            message: 'Payment received! Your order is on its way.',
            orderId: orderId,
          ));
        } else if (status == 'failed') {
          timer.cancel();
          state = AsyncData(PaymentStatus(
            state: PaymentState.failed,
            message: 'Payment was not completed. Please try again.',
            orderId: orderId,
          ));
        }
        // If still 'pending', keep polling
      } catch (e) {
        // Ignore polling errors, keep trying
      }
    });
  }

  void reset() {
    _pollTimer?.cancel();
    state = const AsyncData(PaymentStatus());
  }

  /// Strip "Exception: " prefix from error messages
  String _cleanErrorMessage(String raw) {
    return raw.replaceFirst('Exception: ', '');
  }
}
