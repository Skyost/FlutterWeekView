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

  /// Creates a new week view style instance.
  const WeekViewStyle({
    double? headerSize,
    this.dayViewWidth,
    double? dayViewSeparatorWidth,
    this.dayViewSeparatorColor = Colors.black12,
  })  : dayViewSeparatorWidth =
            (dayViewSeparatorWidth ?? 0) < 0 ? 0 : (dayViewSeparatorWidth ?? 0),
        super(headerSize: headerSize);

  /// Allows to copy the current style instance with your own properties.
  WeekViewStyle copyWith({
    double? headerSize,
    double? dayViewWidth,
    double? dayViewSeparatorWidth,
    Color? dayViewSeparatorColor,
  }) =>
      WeekViewStyle(
        headerSize: headerSize ?? this.headerSize,
        dayViewWidth: dayViewWidth ?? this.dayViewWidth,
        dayViewSeparatorWidth:
            dayViewSeparatorWidth ?? this.dayViewSeparatorWidth,
        dayViewSeparatorColor:
            dayViewSeparatorColor ?? this.dayViewSeparatorColor,
      );
}
