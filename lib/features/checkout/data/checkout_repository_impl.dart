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
    required List<dynamic> items,
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
      // 1. Create the main order record
      final res = await _client
          .from('orders')
          .insert(insertData)
          .select('id')
          .single();

      final orderId = res['id'] as int;

      // 2. Create the individual order items for retailer tracking
      final itemsToInsert = items.map((item) => {
        'order_id': orderId,
        'product_id': item.product.id,
        'seller_id': item.product.sellerId,
        'quantity': item.quantity,
        'unit_price': item.product.price,
      }).toList();

      await _client.from('order_items').insert(itemsToInsert);

      return orderId;
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

      final data = res.data;

      if (data is Map<String, dynamic>) {
        if (data['success'] == true) {
          return data['checkoutRequestId'] as String;
        } else {
          final error = data['error']?.toString() ??
              data['message']?.toString() ??
              '';
          throw Exception(
            error.isNotEmpty ? _friendlyPaymentError(error) : _friendlyPaymentError(''),
          );
        }
      }

      throw Exception(
        'We received an unexpected response from the payment service. Please try again.',
      );
    } on FunctionException catch (e) {
      final details = e.details?.toString() ?? '';
      if (details.isNotEmpty) throw Exception(_friendlyPaymentError(details));
      throw Exception(
        'We couldn\'t reach the payment service. Please check your connection and try again.',
      );
    } catch (e) {
      if (e is Exception && e.toString().contains('Exception: ')) rethrow;
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
      return 'pending';
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _client.from('cart_items').delete().eq('user_id', _userId);
    } catch (_) {
    }
  }

  String _friendlyDbError(String raw) {
    if (raw.contains('violates foreign key')) {
      return 'Your session may have expired. Please log in again.';
    }
    if (raw.contains('duplicate key')) {
      return 'This order already exists. Please refresh and try again.';
    }
    return 'We couldn\'t process your request. Please try again.';
  }

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
