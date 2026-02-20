import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luxe/features/checkout/domain/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final SupabaseClient _client;

  CheckoutRepositoryImpl(this._client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<int> createOrder({
    required double total,
    required String paymentMethod,
    String? phone,
  }) async {
    final orderNumber = 'LX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final insertData = <String, dynamic>{
      'user_id': _userId,
      'order_number': orderNumber,
      'total': total,
      'status': 'processing',
      'payment_status': paymentMethod == 'cash_on_delivery' ? 'cash_on_delivery' : 'pending',
    };

    if (phone != null) {
      insertData['phone_number'] = phone;
    }

    try {
      final res = await _client
          .from('orders')
          .insert(insertData)
          .select('id')
          .single();

      return res['id'] as int;
    } on PostgrestException catch (e) {
      throw Exception(_friendlyDbError(e.message));
    } catch (e) {
      throw Exception('We couldn\'t create your order. Please check your connection and try again.');
    }
  }

  @override
  Future<String> initiatePayment({
    required int orderId,
    required String phone,
    required double amount,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'mpesa-stk-push',
        body: {
          'phone': phone,
          'amount': amount,
          'orderId': orderId,
        },
      );

      final data = res.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return data['checkoutRequestId'] as String;
      } else {
        final error = data['error']?.toString() ?? '';
        throw Exception(_friendlyPaymentError(error));
      }
    } on FunctionException {
      throw Exception(
        'We couldn\'t connect to the payment service. Please try again in a moment.',
      );
    } catch (e) {
      if (e is Exception && e.toString().contains('Exception: ')) {
        rethrow;
      }
      throw Exception(
        'Something went wrong while processing your payment. Please try again.',
      );
    }
  }

  @override
  Future<String> checkPaymentStatus(int orderId) async {
    try {
      final res = await _client
          .from('orders')
          .select('payment_status')
          .eq('id', orderId)
          .single();

      return res['payment_status'] as String;
    } catch (_) {
      return 'pending'; // Silently retry on poll errors
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _client.from('cart_items').delete().eq('user_id', _userId);
    } catch (_) {
      // Cart clear failure is non-critical — order was still placed
    }
  }

  /// Convert raw DB errors to friendly messages
  String _friendlyDbError(String raw) {
    if (raw.contains('violates foreign key')) {
      return 'Your session may have expired. Please log in again.';
    }
    if (raw.contains('duplicate key')) {
      return 'This order already exists. Please refresh and try again.';
    }
    return 'We couldn\'t process your request. Please try again.';
  }

  /// Convert raw payment errors to friendly messages
  String _friendlyPaymentError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid') && lower.contains('jwt')) {
      return 'Your session has expired. Please log in again and retry.';
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'The payment service is taking too long. Please try again.';
    }
    if (lower.contains('insufficient')) {
      return 'Insufficient M-Pesa balance. Please top up and try again.';
    }
    if (lower.contains('invalid phone') || lower.contains('invalid number')) {
      return 'The phone number you entered is invalid. Please check and try again.';
    }
    return 'We couldn\'t process your M-Pesa payment. Please try again.';
  }
}
