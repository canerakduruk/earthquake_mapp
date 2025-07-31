import 'package:intl/intl.dart';

class DateHelper {
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ss';
  static const String displayDateTimeFormat = 'dd.MM.yyyy HH:mm';
  static const String displayDateFormat = 'dd.MM.yyyy';

  static String formatDateForApi(DateTime date) {
    return DateFormat(apiDateFormat).format(date);
  }

  static String formatDateTimeForDisplay(DateTime date) {
    return DateFormat(displayDateTimeFormat).format(date);
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
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);

    return todayStart;
  }

  static DateTime getDefaultEndDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }
}
