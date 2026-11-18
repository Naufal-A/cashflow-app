import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final DateFormat _date = DateFormat('d MMM yyyy');

  /// e.g. Rp 50.000
  static String currency(double value) => _currency.format(value);

  /// e.g. +Rp 50.000 or -Rp 50.000
  static String signed(double value, {required bool isIncome}) =>
      '${isIncome ? '+' : '-'}${currency(value.abs())}';

  /// e.g. 19 Nov 2026
  static String date(DateTime value) => _date.format(value);
}
