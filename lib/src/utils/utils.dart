/// Contains some useful methods for dates.
extension DateTimeUtils on DateTime {
  /// Returns a truncated date time (at the day).
  DateTime get yearMonthDay => DateTime(year, month, day);

  /// Returns a truncated date time (at the minute).
  DateTime get yearMonthDayHourMinute =>
      DateTime(year, month, day, hour, minute);
}

/// Contains some useful methods.
class Utils {
  /// Makes the specified number to have at least two digits by adding a leading zero if needed.
  static String addLeadingZero(int number) =>
      (number < 10 ? '0' : '') + number.toString();

  /// Checks whether the provided date is the same year, month and day than the target date.
  static bool sameDay(DateTime date, [DateTime? target]) {
    target = target ?? dateTimeGetter.now();
    return target.year == date.year &&
        target.month == date.month &&
        target.day == date.day;
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

/// A class that allows getting the current time, with the benefit that it can be mocked in tests.
///
/// Instead of using DateTime.now() directly, use DateTimeGetter.now() ([dateTimeGetter] is a global
/// variable set below). Then, on tests, DateTimeGetter can be replaced with a mock that returns
/// predictable values.
class NowDateTimeGetter {
  DateTime now() => DateTime.now();
}

NowDateTimeGetter dateTimeGetter = NowDateTimeGetter();

/// This method is just for extra clarity the [dateTimeGetter] should only be modified on tests.
void injectDateTimeGetterForTest(NowDateTimeGetter testDateTimeGetter) {
  dateTimeGetter = testDateTimeGetter;
}
