import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/zoomable_header_widget.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/utils.dart';

/// Allows to configure the day bar style.
class DayBarStyle {
  /// The day formatter. Defaults to YYYY-MM-DD, e.g., 2020-01-15.
  final DateFormatter dateFormatter;

  /// The day bar text style. Defaults to null, which will then format according to [DayBar.textStyle].
  final TextStyle? textStyle;

  /// The day bar background color. Defaults to light gray.
  final Color color;

  /// The day bar decoration. Defaults to null.
  final Decoration? decoration;

  /// The day bar text alignment. Defaults to [Alignment.center].
  final Alignment textAlignment;

  /// Creates a new day bar style instance.
  const DayBarStyle({
    DateFormatter? dateFormatter,
    this.textStyle,
    Color? color,
    this.decoration,
    Alignment? textAlignment,
  })  : dateFormatter = dateFormatter ?? DefaultBuilders.defaultDateFormatter,
        color = color ?? const Color(0xFFEBEBEB),
        textAlignment = textAlignment ?? Alignment.center;

  /// Creates a new day bar style according to the specified date.
  DayBarStyle.fromDate({
    required DateTime date,
    DateFormatter? dateFormatter,
    TextStyle? textStyle,
    Color? color,
    Decoration? decoration,
    Alignment? textAlignment,
  }) : this(
          dateFormatter: dateFormatter,
          textStyle: textStyle ??
              TextStyle(
                color: Utils.sameDay(date) ? Colors.blue[800] : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
          color: color,
          decoration: decoration,
          textAlignment: textAlignment,
        );

  /// Allows to copy the current style instance with your own properties.
  DayBarStyle copyWith({
    DateFormatter? dateFormatter,
    TextStyle? textStyle,
    Color? color,
    Decoration? decoration,
    Alignment? textAlignment,
  }) =>
      DayBarStyle(
        dateFormatter: dateFormatter ?? this.dateFormatter,
        textStyle: textStyle ?? this.textStyle,
        color: color ?? this.color,
        decoration: decoration ?? this.decoration,
        textAlignment: textAlignment ?? this.textAlignment,
      );
}
