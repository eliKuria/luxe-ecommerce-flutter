import 'package:intl/intl.dart';

/// Formats a numeric amount as Kenyan Shillings.
///
/// Examples:
///   formatKES(25500)  → 'KES 25,500'
///   formatKES(9800)   → 'KES 9,800'
///   formatKES(0)      → 'KES 0'
String formatKES(double amount) {
  final formatter = NumberFormat('#,##0', 'en_US');
  return 'KES ${formatter.format(amount.round())}';
}
