/// Contains some useful methods for dates.
extension DateTimeUtils on DateTime {
  /// Returns a truncated date time (at the day).
  DateTime get yearMonthDay => DateTime(year, month, day);

  /// Returns a truncated date time (at the minute).
  DateTime get yearMonthDayHourMinute => DateTime(year, month, day, hour, minute);
}

/// Contains some useful methods.
class Utils {
  /// Makes the specified number to have at least two digits by adding a leading zero if needed.
  static String addLeadingZero(int number) => (number < 10 ? '0' : '') + number.toString();

  /// Checks whether the provided date is the same year, month and day than the target date.
  static bool sameDay(DateTime date, [DateTime? target]) {
    target = target ?? DateTime.now();
    return target.year == date.year && target.month == date.month && target.day == date.day;
  }

  /// Removes the last word from a string.
  static String removeLastWord(String string) {
    List<String> words = string.split(' ');
    if (words.isEmpty) {
      return '';
    }

    return words.getRange(0, words.length - 1).join(' ');
  }
}
