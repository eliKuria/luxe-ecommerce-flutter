abstract class CheckoutRepository {
  /// Creates an order from current cart items, returns the order ID.
  Future<int> createOrder({
    required double total,
    required String paymentMethod,
    required List<dynamic> items,
    String? phone,
  });

  /// Initiates M-Pesa STK Push for the given order.
  /// Returns the CheckoutRequestID on success.
  Future<String> initiatePayment({
    required int orderId,
    required String phone,
    required double amount,
  });

  /// Checks payment status from Supabase orders table.
  /// Returns the payment_status string: 'pending', 'completed', 'failed'.
  Future<String> checkPaymentStatus(int orderId);

  /// Clears the user's cart after successful payment.
  Future<void> clearCart();
}
