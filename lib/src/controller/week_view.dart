import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller/day_view.dart';
import 'package:flutter_week_view/src/controller/zoom_controller.dart';

/// Allows to control some parameters of a week view.
class WeekViewController extends ZoomController {
  /// All day view controllers.
  final Map<DateTime, DayViewController> _dayViewControllers = {};

  /// Creates a new week view controller.
  WeekViewController({
    double zoomCoefficient = 0.8,
    double? minZoom,
    double? maxZoom,
  }) : super(
          zoomCoefficient: zoomCoefficient,
          minZoom: minZoom,
          maxZoom: maxZoom,
        );

  /// Returns the day view controller associated with the specified date.
  DayViewController getDayViewController(DateTime date) {
    if (!_dayViewControllers.containsKey(date)) {
      _dayViewControllers[date] = DayViewController(
        zoomCoefficient: zoomCoefficient,
        minZoom: minZoom,
        maxZoom: maxZoom,
        onDisposed: _onDayViewControllerDisposed,
      )
        ..previousZoomFactor = previousZoomFactor
        ..zoomFactor = zoomFactor;
    }

    return _dayViewControllers[date]!;
  }

  @override
  void scaleStart(ScaleStartDetails details) {
    super.scaleStart(details);
    for (DayViewController controller in _dayViewControllers.values) {
      controller.scaleStart(details);
    }
  }

  @override
  void changeZoomFactor(double zoomFactor,
      {bool notify = true, ScaleUpdateDetails? details}) {
    super.changeZoomFactor(zoomFactor, notify: notify, details: details);
    for (DayViewController controller in _dayViewControllers.values) {
      controller.changeZoomFactor(zoomFactor, notify: notify, details: details);
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (DayViewController controller in _dayViewControllers.values) {
      controller.dispose();
    }
    _dayViewControllers.clear();
  }

  /// Triggered when a day view controller is disposed.
  void _onDayViewControllerDisposed(DayViewController dayViewController) =>
      _dayViewControllers
          .removeWhere((date, controller) => controller == dayViewController);
}
