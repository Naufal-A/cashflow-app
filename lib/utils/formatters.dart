import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final DateFormat _date = DateFormat('d MMM yyyy');

  static String currency(double value) => _currency.format(value);

  static String signed(double value, {required bool isIncome}) =>
      '${isIncome ? '+' : '-'}${currency(value.abs())}';

  static String date(DateTime value) => _date.format(value);
}
