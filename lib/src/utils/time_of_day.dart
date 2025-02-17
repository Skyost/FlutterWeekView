import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/utils/utils.dart';

/// Contains various useful methods to work with [TimeOfDay]s.
extension TimeOfDayUtils on TimeOfDay {
  /// "Zero" time.
  static const TimeOfDay zero = TimeOfDay(hour: 0, minute: 0);

  /// "Min" time.
  static const TimeOfDay min = zero;

  /// "Max" time.
  static const TimeOfDay max = TimeOfDay(hour: 24, minute: 0);

  /// Creates a new hour minute time instance from a given date time object.
  static TimeOfDay fromDuration({
    required Duration duration,
  }) {
    int hour = 0;
    int minute = duration.inMinutes;
    while (minute >= 60) {
      hour += 1;
      minute -= 60;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Calculates the sum of this time of day and the specified [duration].
  TimeOfDay add(Duration duration) {
    int hour = this.hour + duration.inHours;
    int minute = this.minute + (duration.inMinutes - 60 * duration.inHours);
    while (minute > 59) {
      hour++;
      minute -= 60;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Calculates the difference of this time of day and the specified [duration].
  TimeOfDay subtract(Duration duration) {
    int hour = this.hour - duration.inHours;
    if (hour < 0) {
      return zero;
    }
    int minute = this.minute - (duration.inMinutes - 60 * duration.inHours);
    while (minute < 0) {
      if (hour == 0) {
        return zero;
      }
      hour--;
      minute += 60;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Attaches this instant to a provided date.
  DateTime atDate(DateTime date) => date.yearMonthDay.add(asDuration);

  /// Converts this instance into a duration.
  Duration get asDuration => Duration(hours: hour, minutes: minute);
}
