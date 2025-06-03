import 'package:intl/intl.dart';

String formatRupiah(dynamic value) {
  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0, // Ubah ke 2 kalau mau ada koma (misal Rp 10.000,50)
  );

  if (value is int || value is double) {
    return formatCurrency.format(value);
  } else if (value is String) {
    return formatCurrency.format(double.tryParse(value) ?? 0);
  } else {
    return 'Rp 0';
  }
}
