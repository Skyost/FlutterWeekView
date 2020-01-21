import 'dart:math' as Math;
import 'dart:collection';

import 'package:flutter/material.dart';

/// Allows to control some parameters of a day view.
class DayViewController {
  /// The day view scroll controller.
  final ScrollController scrollController;

  /// The zoom coefficient (<= 0 to disable).
  final double zoomCoefficient;

  /// The minimum zoom factor.
  final double minZoom;

  /// The maximum zoom factor.
  final double maxZoom;

  /// Whether this controller is disposable.
  final bool disposable;

  /// The previous zoom factor.
  double _previousZoomFactor = 1;

  /// The current zoom factor.
  double _zoomFactor = 1;

  /// All controller listeners.
  Set<DayViewControllerListener> listeners = HashSet();

  /// Creates a new day view controller instance.
  DayViewController({
    ScrollController scrollController,
    double zoomCoefficient = 0.8,
    this.minZoom = 0.4,
    this.maxZoom = 1.6,
    this.disposable = true,
  })  : this.scrollController = scrollController ?? ScrollController(),
        this.zoomCoefficient = Math.max(0, zoomCoefficient ?? 0),
        assert(zoomCoefficient != null),
        assert(minZoom != null),
        assert(maxZoom != null),
        assert(minZoom <= maxZoom),
        assert(disposable != null);

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
  void scaleStart() => _previousZoomFactor = _zoomFactor;

  /// Should be called when the scale operation has an update.
  void scaleUpdate(ScaleUpdateDetails details) {
    double zoomFactor = calculateZoomFactor(details.scale);
    bool hasChanged = _zoomFactor != zoomFactor;
    if (hasChanged) {
      _zoomFactor = zoomFactor;
      listeners.forEach((listener) => listener.onZoomFactorChanged(this, details));
    }
  }

  /// Returns the current scale.
  double get scale => _zoomFactor / (_previousZoomFactor * zoomCoefficient);

  /// Returns the current zoom factor.
  double get zoomFactor => _zoomFactor;

  /// Disposes this controller.
  /// You should not use it anymore after having called this method.
  void dispose() {
    if (disposable) {
      listeners.clear();
      scrollController.dispose();
    }
  }
}

/// A day view controller listener.
mixin DayViewControllerListener {
  /// Triggered when the day view zoom factor has changed.
  void onZoomFactorChanged(DayViewController controller, ScaleUpdateDetails details);
}

/// Allows to control some parameters of a week view.
class WeekViewController {
  /// All day view controllers.
  final List<DayViewController> dayViewControllers;

  /// The horizontal scroll controller.
  final ScrollController horizontalScrollController;

  /// The vertical scroll controller.
  final ScrollController verticalScrollController;

  /// All controller listeners.
  Set<WeekViewControllerListener> listeners = HashSet();

  /// Creates a new week view controller.
  WeekViewController({
    @required int dayViewsCount,
    ScrollController horizontalScrollController,
    ScrollController verticalScrollController,
    double zoomCoefficient = 0.8,
    double minZoom = 0.4,
    double maxZoom = 1.6,
  })  : this.horizontalScrollController = horizontalScrollController ?? ScrollController(),
        this.verticalScrollController = verticalScrollController ?? ScrollController(),
        assert(dayViewsCount != null && dayViewsCount > 0),
        this.dayViewControllers = List.generate(
          dayViewsCount,
          (_) => DayViewController(
            zoomCoefficient: zoomCoefficient,
            minZoom: minZoom,
            maxZoom: maxZoom,
            disposable: false,
          ),
        );

  /// Calculates a zoom factor according to the specified scale.
  double calculateZoomFactor(double scale) => dayViewControllers.first.calculateZoomFactor(scale);

  /// Should be called when the scale operation start.
  void scaleStart() => dayViewControllers.forEach((controller) => controller.scaleStart());

  /// Should be called when the scale operation has an update.
  void scaleUpdate(ScaleUpdateDetails details) {
    double zoomFactor = calculateZoomFactor(details.scale);
    bool hasChanged = this.zoomFactor != zoomFactor;
    if (hasChanged) {
      dayViewControllers.forEach((controller) => controller.scaleUpdate(details));
      listeners.forEach((listener) => listener.onZoomFactorChanged(this, details));
    }
  }

  /// Returns the current scale.
  double get scale => dayViewControllers.first.scale;

  /// Returns the current zoom factor.
  double get zoomFactor => dayViewControllers.first.zoomFactor;

  /// Disposes this controller.
  /// You should not use it anymore after having called this method.
  void dispose() {
    listeners.clear();
    dayViewControllers.forEach((controller) => controller.dispose());
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
  }
}

/// A week view controller listener.
mixin WeekViewControllerListener {
  /// Triggered when the day view zoom factor has changed.
  void onZoomFactorChanged(WeekViewController controller, ScaleUpdateDetails details);
}
