import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Simply represents a hour and a minute.
/// This is not a duration but more of an instant in the current day.
class HourMinute {
  /// "Zero" time.
  static const HourMinute ZERO = HourMinute._internal(hour: 0, minute: 0);

  /// "Min" time.
  static const HourMinute MIN = ZERO;

  /// "Max" time.
  static const HourMinute MAX = HourMinute._internal(hour: 24, minute: 0);

  /// The current hour.
  final int hour;

  /// The current minute.
  final int minute;

  /// Allows to internally create a new hour minute time instance.
  const HourMinute._internal({
    @required this.hour,
    @required this.minute,
  });

  /// Creates a new hour minute time instance.
  const HourMinute({
    int hour = 0,
    int minute = 0,
  }) : this._internal(
          hour: hour == null ? 0 : (hour < 0 ? 0 : (hour > 23 ? 23 : hour)),
          minute: minute == null ? 0 : (minute < 0 ? 0 : (minute > 59 ? 59 : minute)),
        );

  /// Creates a new hour minute time instance from a given date time object.
  HourMinute.fromDateTime({
    @required DateTime dateTime,
  }) : this._internal(hour: dateTime.hour, minute: dateTime.minute);

  /// Creates a new hour minute time instance from a given date time object.
  factory HourMinute.fromDuration({
    @required Duration duration,
  }) {
    int hour = 0;
    int minute = duration.inMinutes;
    while (minute >= 60) {
      hour += 1;
      minute -= 60;
    }
    return HourMinute._internal(hour: hour, minute: minute);
  }

  /// Creates a new hour minute time instance.
  HourMinute.now() : this.fromDateTime(dateTime: DateTime.now());

  /// Calculates the difference between this hour minute and another.
  HourMinute add(HourMinute other) {
    int hour = this.hour + other.hour;
    int minute = this.minute + other.minute;
    while (minute > 59) {
      hour++;
      minute -= 60;
    }
    return HourMinute._internal(hour: hour, minute: minute);
  }

  /// Calculates the difference between this hour minute and another.
  HourMinute subtract(HourMinute other) {
    int hour = math.max(this.hour - other.hour, 0);
    int minute = this.minute - other.minute;
    while (minute < 0) {
      if (hour == 0) {
        return HourMinute.ZERO;
      }
      hour--;
      minute += 60;
    }
    return HourMinute._internal(hour: hour, minute: minute);
  }

  @override
  String toString() => jsonEncode({'hour': hour, 'minute': minute});

  @override
  bool operator ==(other) {
    if (other is! HourMinute) {
      return false;
    }
    return identical(this, other) || (hour == other.hour && minute == other.minute);
  }

  bool operator <(other) {
    if (other is! HourMinute) {
      return false;
    }

    return _calculateDifference(other) < 0;
  }

  bool operator <=(other) {
    if (other is! HourMinute) {
      return false;
    }
    return _calculateDifference(other) <= 0;
  }

  bool operator >(other) {
    if (other is! HourMinute) {
      return false;
    }
    return _calculateDifference(other) > 0;
  }

  bool operator >=(other) {
    if (other is! HourMinute) {
      return false;
    }
    return _calculateDifference(other) >= 0;
  }

  @override
  int get hashCode => hour.hashCode + minute.hashCode;

  /// Returns the difference in minutes between this and another hour minute time instance.
  int _calculateDifference(HourMinute other) => (hour * 60 - other.hour * 60) + (minute - other.minute);
}
