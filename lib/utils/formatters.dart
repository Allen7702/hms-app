import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_TZ',
    symbol: 'TZS ',
    decimalDigits: 0,
  );

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');
  static final _timeFormat = DateFormat('h:mm a');
  static final _shortDateFormat = DateFormat('MMM d');
  static final _isoDateFormat = DateFormat('yyyy-MM-dd');

  /// Format amount as TZS currency
  static String currency(num? amount) {
    if (amount == null) return 'TZS 0';
    return _currencyFormat.format(amount);
  }

  /// Format date as "Jan 1, 2025"
  static String date(DateTime? date) {
    if (date == null) return '-';
    return _dateFormat.format(date.toLocal());
  }

  /// Format datetime as "Jan 1, 2025 2:30 PM"
  static String dateTime(DateTime? date) {
    if (date == null) return '-';
    return _dateTimeFormat.format(date.toLocal());
  }

  /// Format time as "2:30 PM"
  static String time(DateTime? date) {
    if (date == null) return '-';
    return _timeFormat.format(date.toLocal());
  }

  /// Format date as "Jan 1"
  static String shortDate(DateTime? date) {
    if (date == null) return '-';
    return _shortDateFormat.format(date.toLocal());
  }

  /// Format date as "2025-01-01" for API
  static String isoDate(DateTime date) {
    return _isoDateFormat.format(date);
  }

  /// Format relative time as "2 hours ago"
  static String relative(DateTime? date) {
    if (date == null) return '-';
    return timeago.format(date);
  }

  /// Calculate night count between two dates
  static int nightCount(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  /// Format phone number
  static String phone(String? phone) {
    if (phone == null || phone.isEmpty) return '-';
    return phone;
  }

  /// Format occupancy percentage
  static String percentage(double? value) {
    if (value == null) return '0%';
    return '${value.toStringAsFixed(1)}%';
  }

  /// Compact number (e.g. 1.2K, 3.4M)
  static String compactNumber(num value) {
    return NumberFormat.compact().format(value);
  }
}
