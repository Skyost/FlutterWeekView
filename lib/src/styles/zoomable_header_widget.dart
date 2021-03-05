import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/utils/hour_minute.dart';

/// Returns a string from a specified date.
typedef DateFormatter = String Function(int year, int month, int day);

/// Returns a string from a specified hour.
typedef TimeFormatter = String Function(HourMinute time);

/// Allows to builder a vertical divider according to the specified date.
typedef VerticalDividerBuilder = VerticalDivider Function(DateTime date);

/// Allows to style a zoomable header widget style.
class ZoomableHeaderWidgetStyle {
  /// The header size (usually limited to the day bar). Defaults to 60.
  final double headerSize;

  /// Creates a new zoomable header widget style instance.
  const ZoomableHeaderWidgetStyle({
    double? headerSize,
  }) : headerSize = (headerSize ?? 40) < 0 ? 0 : (headerSize ?? 40);
}
