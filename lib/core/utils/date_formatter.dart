import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) {
      return '';
    }

    final DateTime? parsed = DateTime.tryParse(isoDate);
    if (parsed == null) {
      return '';
    }

    return DateFormat('d MMM yyyy').format(parsed.toLocal());
  }
}
