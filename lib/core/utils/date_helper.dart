import 'package:intl/intl.dart';

class DateHelper {
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ss';
  static const String displayDateFormat = 'dd.MM.yyyy HH:mm';

  static String formatDateForApi(DateTime date) {
    return DateFormat(apiDateFormat).format(date);
  }

  static String formatDateForDisplay(DateTime date) {
    return DateFormat(displayDateFormat).format(date);
  }

  static DateTime? parseApiDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateFormat(apiDateFormat).parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  static DateTime getDefaultStartDate() {
    return DateTime.now().subtract(const Duration(days: 7));
  }

  static DateTime getDefaultEndDate() {
    return DateTime.now();
  }
}
