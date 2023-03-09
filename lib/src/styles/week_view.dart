import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/zoomable_header_widget.dart';

/// Allows to style a week view.
class WeekViewStyle extends ZoomableHeaderWidgetStyle {
  /// A day view width.
  ///
  /// Defaults to the entire width available for the week view widget.
  final double? dayViewWidth;

  /// The separator width between day views.
  ///
  /// Defaults to zero.
  final double dayViewSeparatorWidth;

  /// The separator color between day views.
  ///
  /// Defaults to [Colors.black12].
  final Color dayViewSeparatorColor;

  /// If true, render a horizontal scrollbar on the bottom of the widget. This
  /// is useful for devices without a mechanism built-in for horizontal
  /// scrolling, such as some Desktop computers.
  ///
  /// Defaults to false.
  final bool showHorizontalScrollbar;

  /// Creates a new week view style instance.
  const WeekViewStyle({
    double? headerSize,
    this.dayViewWidth,
    double? dayViewSeparatorWidth,
    this.dayViewSeparatorColor = Colors.black12,
    this.showHorizontalScrollbar = false,
  })  : dayViewSeparatorWidth = (dayViewSeparatorWidth ?? 0) < 0 ? 0 : (dayViewSeparatorWidth ?? 0),
        super(headerSize: headerSize);

  /// Allows to copy the current style instance with your own properties.
  WeekViewStyle copyWith({
    double? headerSize,
    double? dayViewWidth,
    double? dayViewSeparatorWidth,
    Color? dayViewSeparatorColor,
    bool? showHorizontalScrollbar,
  }) =>
      WeekViewStyle(
        headerSize: headerSize ?? this.headerSize,
        dayViewWidth: dayViewWidth ?? this.dayViewWidth,
        dayViewSeparatorWidth: dayViewSeparatorWidth ?? this.dayViewSeparatorWidth,
        dayViewSeparatorColor: dayViewSeparatorColor ?? this.dayViewSeparatorColor,
        showHorizontalScrollbar: showHorizontalScrollbar ?? this.showHorizontalScrollbar,
      );
}
