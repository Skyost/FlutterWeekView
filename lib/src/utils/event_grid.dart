import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/utils/hour_minute.dart';
import 'package:flutter_week_view/src/widgets/day_view.dart';

/// An useful class that allows to position events in a grid.
/// Thanks to https://stackoverflow.com/a/11323909/3608831.
class EventGrid {
  /// Events draw properties added to the grid.
  List<EventDrawProperties> drawPropertiesList = [];

  /// Adds a flutter week view event draw properties.
  void add(EventDrawProperties drawProperties) =>
      drawPropertiesList.add(drawProperties);

  /// Processes all display properties added to the grid.
  void processEvents(double hoursColumnWidth, double eventsColumnWidth) {
    List<List<EventDrawProperties>> columns = [];
    DateTime? lastEventEnding;
    for (EventDrawProperties drawProperties in drawPropertiesList) {
      if (lastEventEnding != null &&
          drawProperties.start!.isAfter(lastEventEnding)) {
        packEvents(columns, hoursColumnWidth, eventsColumnWidth);
        columns.clear();
        lastEventEnding = null;
      }

      bool placed = false;
      for (List<EventDrawProperties> column in columns) {
        if (!column.last.collidesWith(drawProperties)) {
          column.add(drawProperties);
          placed = true;
          break;
        }
      }

      if (!placed) {
        columns.add([drawProperties]);
      }

      if (lastEventEnding == null ||
          drawProperties.end!.compareTo(lastEventEnding) > 0) {
        lastEventEnding = drawProperties.end;
      }
    }

    if (columns.isNotEmpty) {
      packEvents(columns, hoursColumnWidth, eventsColumnWidth);
    }
  }

  /// Sets the left and right positions for each event in the connected group.
  void packEvents(List<List<EventDrawProperties>> columns,
      double hoursColumnWidth, double eventsColumnWidth) {
    for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
      List<EventDrawProperties> column = columns[columnIndex];
      for (EventDrawProperties drawProperties in column) {
        drawProperties.left = hoursColumnWidth +
            (columnIndex / columns.length) * eventsColumnWidth;
        int colSpan = calculateColSpan(columns, drawProperties, columnIndex);
        drawProperties.width = (eventsColumnWidth * colSpan) / (columns.length);
      }
    }
  }

  /// Checks how many columns the event can expand into, without colliding with other events.
  int calculateColSpan(List<List<EventDrawProperties>> columns,
      EventDrawProperties drawProperties, int column) {
    int colSpan = 1;
    for (int columnIndex = column + 1;
        columnIndex < columns.length;
        columnIndex++) {
      List<EventDrawProperties> column = columns[columnIndex];
      for (EventDrawProperties other in column) {
        if (drawProperties.collidesWith(other)) {
          return colSpan;
        }
      }
      colSpan++;
    }

    return colSpan;
  }
}

/// An utility class that allows to display the events in the events column.
class EventDrawProperties {
  /// The top position.
  double? top;

  /// The event rectangle height.
  double? height;

  /// The left position.
  double? left;

  /// The event rectangle width.
  double? width;

  /// The start time.
  DateTime? start;

  /// The end time.
  DateTime? end;

  /// Whether the event should be aligned from right to left.
  final bool isRTL;

  /// Creates a new flutter week view event draw properties from the specified day view and the specified day view event.
  EventDrawProperties(DayView dayView, FlutterWeekViewEvent event, this.isRTL) {
    DateTime minimum = dayView.minimumTime.atDate(dayView.date);
    DateTime maximum = dayView.maximumTime.atDate(dayView.date);

    if (shouldDraw ||
        (event.start.isBefore(minimum) && event.end.isBefore(minimum)) ||
        (event.start.isAfter(maximum) && event.end.isAfter(maximum))) {
      return;
    }

    start = event.start;
    end = event.end;

    if (start!.isBefore(minimum)) {
      start = minimum;
    }

    if (end!.isAfter(maximum)) {
      end = maximum;
    }
  }

  /// Whether this event should be drawn.
  bool get shouldDraw => start != null && end != null;

  /// Calculates the top and the height of the event rectangle.
  void calculateTopAndHeight(
      double Function(HourMinute time, {HourMinute minimumTime})
          topOffsetCalculator) {
    if (!shouldDraw) {
      return;
    }

    top = topOffsetCalculator(HourMinute.fromDateTime(dateTime: start!));
    height = topOffsetCalculator(
            HourMinute.fromDuration(duration: end!.difference(start!)),
            minimumTime: HourMinute.min) +
        1;
  }

  /// Returns whether this draw properties overlaps another.
  bool collidesWith(EventDrawProperties other) {
    if (!shouldDraw || !other.shouldDraw) {
      return false;
    }

    return end!.isAfter(other.start!) && start!.isBefore(other.end!);
  }

  /// Creates the event widget.
  Widget createWidget(
          BuildContext context, DayView dayView, FlutterWeekViewEvent event) =>
      Positioned(
        top: top,
        height: height,
        left: isRTL ? null : left,
        right: isRTL ? left : null,
        width: width,
        child: event.build(context, dayView, height!, width!),
      );
}
