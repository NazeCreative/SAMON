import 'package:intl/intl.dart';

class Formatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatNumber(double number) {
    return NumberFormat('#,###').format(number);
  }
}
