import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/zoomable_header_widget.dart';
import 'package:flutter_week_view/src/utils/builders.dart';

/// Allows to configure the hours column style.
class HoursColumnStyle {
  /// The hour formatter. Defaults to 24-hour HH:MM, e.g., 15:00.
  final TimeFormatter timeFormatter;

  /// The hours column text style. Defaults to light gray text.
  final TextStyle textStyle;

  /// The hours column width. Defaults to 60.
  final double width;

  /// The hours column background color. Defaults to [Colors.white].
  final Color? color;

  /// The hours column decoration. Defaults to null.
  final Decoration? decoration;

  /// The hours text alignment. Defaults to [Alignment.center].
  final Alignment textAlignment;

  /// The interval between two durations displayed on the hours column. Defaults to [Duration(hours: 1)].
  final Duration interval;

  /// Creates a new hour column style instance.
  const HoursColumnStyle({
    TimeFormatter? timeFormatter,
    TextStyle? textStyle,
    double? width,
    Color? color,
    this.decoration,
    Alignment? textAlignment,
    Duration? interval,
  })  : timeFormatter = timeFormatter ?? DefaultBuilders.defaultTimeFormatter,
        textStyle = textStyle ?? const TextStyle(color: Colors.black54),
        width = (width ?? 60) < 0 ? 0 : (width ?? 60),
        color = color ?? Colors.white,
        textAlignment = textAlignment ?? Alignment.center,
        interval = interval ?? const Duration(hours: 1);

  /// Allows to copy the current style instance with your own properties.
  HoursColumnStyle copyWith({
    TimeFormatter? timeFormatter,
    TextStyle? textStyle,
    double? width,
    Color? color,
    Decoration? decoration,
    Alignment? textAlignment,
    Duration? interval,
  }) =>
      HoursColumnStyle(
        timeFormatter: timeFormatter ?? this.timeFormatter,
        textStyle: textStyle ?? this.textStyle,
        width: width ?? this.width,
        color: color ?? this.color,
        decoration: decoration ?? this.decoration,
        textAlignment: textAlignment ?? this.textAlignment,
        interval: interval ?? this.interval,
      );
}
