import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An abstract zoom controller.
abstract class ZoomController {
  /// The zoom coefficient (<= 0 to disable).
  final double zoomCoefficient;

  /// The minimum zoom factor.
  final double minZoom;

  /// The maximum zoom factor.
  final double maxZoom;

  /// All controller listeners.
  final Set<ZoomControllerListener> _listeners = HashSet();

  /// The previous zoom factor.
  double _previousZoomFactor = 1;

  /// The current zoom factor.
  double _zoomFactor = 1;

  /// Creates a zoom controller instance.
  ZoomController({
    double zoomCoefficient = 0.8,
    double minZoom,
    double maxZoom,
  })  : zoomCoefficient = math.max(0, zoomCoefficient ?? 0),
        minZoom = math.max(0, minZoom ?? 0.4),
        maxZoom = math.max(0, minZoom ?? 1.6) {
    assert(this.minZoom <= this.maxZoom);
  }

  /// Adds a listener.
  void addListener(ZoomControllerListener listener) => _listeners.add(listener);

  /// Removes a listener.
  void removeListener(ZoomControllerListener listener) => _listeners.remove(listener);

  /// Calculates a zoom factor according to the specified scale.
  double calculateZoomFactor(double scale) {
    double zoomFactor = _previousZoomFactor * scale * zoomCoefficient;
    if (zoomFactor < minZoom) {
      zoomFactor = minZoom;
    }

    if (zoomFactor > maxZoom) {
      zoomFactor = maxZoom;
    }

    return zoomFactor;
  }

  /// Should be called when the scale operation start.
  void scaleStart() => _previousZoomFactor = zoomFactor;

  /// Should be called when the scale operation has an update.
  void scaleUpdate(ScaleUpdateDetails details) => changeZoomFactor(calculateZoomFactor(details.scale), details: details);

  /// Returns the current scale.
  double get scale => zoomFactor / (_previousZoomFactor * zoomCoefficient);

  /// Returns the current zoom factor.
  double get zoomFactor => _zoomFactor;

  /// Changes the current zoom factor.
  void changeZoomFactor(double zoomFactor, {bool notify = true, ScaleUpdateDetails details}) {
    bool hasChanged = this.zoomFactor != zoomFactor;
    if (hasChanged) {
      _zoomFactor = zoomFactor;
      if (notify) {
        details ??= ScaleUpdateDetails(scale: scale);
        _listeners.forEach((listener) => listener.onZoomFactorChanged(this, details));
      }
    }
  }

  /// Disposes this controller if enabled.
  /// You should not use it anymore after having called this method.
  void dispose() {
    _listeners.clear();
  }
}

/// A day view controller listener.
mixin ZoomControllerListener {
  /// Triggered when the day view zoom factor has changed.
  void onZoomFactorChanged(covariant ZoomController controller, ScaleUpdateDetails details);
}

/// Allows to control some parameters of a day view.
class DayViewController extends ZoomController {
  /// Called when this controller has been disposed.
  final Function(DayViewController controller) onDisposed;

  /// Creates a new day view controller instance.
  DayViewController({
    double zoomCoefficient = 0.8,
    double minZoom,
    double maxZoom,
    this.onDisposed,
  }) : super(
          zoomCoefficient: zoomCoefficient,
          minZoom: minZoom,
          maxZoom: maxZoom,
        );

  @override
  void dispose() {
    super.dispose();
    if (onDisposed != null) {
      onDisposed(this);
    }
  }
}

/// Allows to control some parameters of a week view.
class WeekViewController extends ZoomController {
  /// All day view controllers.
  final Map<DateTime, DayViewController> _dayViewControllers = {};

  /// Creates a new week view controller.
  WeekViewController({
    double zoomCoefficient = 0.8,
    double minZoom,
    double maxZoom,
  })  : super(
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
        .._previousZoomFactor = _previousZoomFactor
        .._zoomFactor = _zoomFactor;
    }

    return _dayViewControllers[date];
  }

  @override
  void scaleStart() {
    super.scaleStart();
    _dayViewControllers.values.forEach((controller) => controller.scaleStart());
  }

  @override
  void changeZoomFactor(double zoomFactor, {bool notify = true, ScaleUpdateDetails details}) {
    super.changeZoomFactor(zoomFactor, notify: notify, details: details);
    _dayViewControllers.values.forEach((controller) => controller.changeZoomFactor(zoomFactor, notify: notify, details: details));
  }

  @override
  void dispose() {
    super.dispose();
    _dayViewControllers.values.forEach((controller) => controller.dispose());
  }

  /// Triggered when a day view controller is disposed.
  void _onDayViewControllerDisposed(DayViewController dayViewController) => _dayViewControllers.removeWhere((date, controller) => controller == dayViewController);
}
